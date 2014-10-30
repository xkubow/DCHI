//
//  TrabantViewController.m
//  DMSTrabant
//
//  Created by Jan Kubis on 1/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "vcTrabantInfo.h"
#import "vcLogin.h"
#import "DMSetting.h"
#import "vcVozHistory.h"
#import "tbcBarController.h"
//#import "vcShowInfo.h"
#import "TrabantAppDelegate.h"
//#import "vcSplitView.h"czy
#import "VCBaseGrid.h"
#import "VCVozVyber.h"
#import "WSDCHIDataTransfer.h"
#import "DejalActivityView.h"
#import "OBDIICom.h"
#import "DMOBDII.h"
#import "vcNabidky.h"
#import "VCOBDIIGrig.h"

#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])
#define ROOTNAVIGATOR ([TRABANT_APP_DELEGATE rootNavController])

#define VINREGULAR @"^([A-Z0-9]{3})([A-Z0-9]{0,3})([A-Z0-9]{0,2})([A-Z0-9]{0,3})([A-Z0-9]{0,6})(\\w*)"
#define getDictIntValue(dic, enum)([dic valueForKey:enum]!=nil)?[[dic valueForKey:enum] intValue]:-1;

@interface vcTrabantInfo() <VozVyberDelegate, BaseGridDelegate>
{
    __weak IBOutlet UIButton *btnPZ;
    __weak IBOutlet UIButton *btnSDA;
    __weak IBOutlet UIButton *btnOdlozPoloz;
    __weak IBOutlet UIButton *btnPalivo;
    __weak IBOutlet UILabel *lblCheckinNr;
}
- (void) showPlanVozidla;
- (void) loadPovinPole;
-(void) changedValue;
@end

@implementation vcTrabantInfo
@synthesize showPlanVoz;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(NSString *)getScenarString
{
    return txtScenar.text;
}

- (void) refreshData
{
    [super refreshData];
    BOOL strShoulAutoShowPlaned = [[[DMSetting sharedDMSetting].setting valueForKey:@"AUTO_SHOW_PLANNED"] boolValue];
    if(showPlanVoz && strShoulAutoShowPlaned)
    {
        [self performSelectorOnMainThread:@selector(loadPlanovaneZakazky) withObject:self waitUntilDone:YES];
        showPlanVoz = false;
    }
    NSString *userName = [NSString stringWithFormat:@"%@ %@", [[DMSetting sharedDMSetting].loggedUser valueForKey:@"NAME"], [[DMSetting sharedDMSetting].loggedUser valueForKey:@"SURNAME"] ];
    lblUser.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Poradce", nil), userName];
    
    if(existInDic([DMSetting sharedDMSetting].vozidlo, @"CHECKIN_NUMBER") && [[[DMSetting sharedDMSetting].vozidlo valueForKey:@"CHECKIN_NUMBER"] integerValue] > 0)
    {
        lblCheckinNr.textColor = [UIColor lightGrayColor];
        lblCheckinNr.text = [[[DMSetting sharedDMSetting].vozidlo valueForKey:@"CHECKIN_NUMBER"] stringValue];
    }
    else if(existInDic([DMSetting sharedDMSetting].vozidlo, @"PLANNED_ORDER_ID"))
    {
        lblCheckinNr.textColor = [UIColor colorWithRed:0.18 green:0.35 blue:0.7 alpha:1];//[UIColor colorWithRed:0.2 green:0.2 blue:0.9 alpha:0.5];//[UIColor blueColor];
        lblCheckinNr.text = [[DMSetting sharedDMSetting].vozidlo objectForKey:@"PLANNED_ORDER_NO"];
    }
    else
        lblCheckinNr.text = @"";
}

- (IBAction)btnOBDIIdidToutchInsideUp:(id)sender {
    [self EnabledAllComponents:NO];
    OBDIICom *odbiiCom = [OBDIICom sharedOBDIICom];
    if(![odbiiCom createConnection])
        [self EnabledAllComponents:YES];
    
//    [DMOBDII decodeMultyFrameInData:nil];
//    [self showOBDIIData];
//    [DMOBDII decodeOBDIIErrorInCode:nil];
}


- (IBAction)getRZVData:(id)sender
{
    if([txtRZV.text isEqualToString:[[DMSetting sharedDMSetting].vozidlo valueForKey:@"LICENSE_TAG"]])
        return;
    [self changedValue];
    [DMSetting sharedDMSetting].vozInfo = nil;
    [DMSetting sharedDMSetting].vozHistory = nil;
    [DMSetting sharedDMSetting].SDA = nil;
    [DMSetting sharedDMSetting].PZ = nil;
    btnSDA.enabled = NO;
    btnPZ.enabled = NO;

    [[DMSetting sharedDMSetting].vozidlo setValue:[NSNull null] forKey:@"VEHICLE_ID"];
    if(txtVIN.text.length)
    {
        txtVIN.enabled = YES;
        return;
    }
    
    lblCheckinNr.text = @"";
    NSString *rzv;
    rzv = txtRZV.text;
    [self clearAllData:self.view];
    [self EnabledAllComponents:NO];
    txtVIN.text = @"";
    txtRZV.text = rzv;
    
    [[WSDCHIDataTransfer sharedWSDCHIDataTransfer] startGetCarDataWithVozidloId:-1 checkIn_id:-1 oZakazkaId:-1 rzv:rzv vin:@""];
//    [[WSCommunications sharedWSCommunications].wsLoadCarManufactureData startGetCarDataWithVozidloId:-1 checkIn_id:-1 oZakazkaId:-1 rzv:rzv vin:@""];

}

- (void)setMouthDate:(UITextField *)sender
{
    [dateFormatter setDateFormat:@"MM'.'yyyy"];
    NSDate *date;
    NSMutableDictionary *voz = [DMSetting sharedDMSetting].vozidlo;
    NSString *dateType = (sender == txtSTK)?@"TI_VALID_UNTIL":@"EC_VALID_UNTIL";
    
    if([sender text].length)
        date = [dateFormatter dateFromString:[sender text]];
    if(date == nil)
        [voz removeObjectForKey:dateType];
    
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss"];
    [voz setValue:[dateFormatter stringFromDate:date] forKey:dateType];
}


-(void)pickerDidSelected:(vcPicker*)Sender
{
    [self setStatusOdeslani:NO];
    
    if([Sender.view tag] == btnEmise.tag){
        [txtEmise setText: [NSString stringWithFormat:@"%d.%@",[Sender selectedRowInComponent:0]+1, [Sender selectedValueInComponent:1] ]];
        [self setMouthDate:txtEmise];
    }
    else if([Sender.view tag] == btnSTK.tag) {
        [txtSTK setText:[NSString stringWithFormat:@"%d.%@",[Sender selectedRowInComponent:0]+1, [Sender selectedValueInComponent:1] ]];
        [self setMouthDate:txtSTK];
        [txtEmise setText: [NSString stringWithFormat:@"%d.%@",[Sender selectedRowInComponent:0]+1, [Sender selectedValueInComponent:1] ]];
        [self setMouthDate:txtEmise];
    }
    [self changedValue];
}

-(void) showOBDIIData
{
    NSArray *obdData = [[OBDIICom sharedOBDIICom].data filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SHOW.intValue = 1"]];
    
    VCOBDIIGrig *vh = [[VCOBDIIGrig alloc] initWithFrame:CGRectMake(0, 0, 700, 480)];
    Column *c = [vh addColumnWithSize:CGSizeMake(200, 30) textAlign:NSTextAlignmentRight];
    c.dictEnum = @"TYPE";
    c.caption = NSLocalizedString(@"ODBII dotaz", nil);
    
    c = [vh addColumnWithSize:CGSizeMake(500, 30) textAlign:NSTextAlignmentLeft];
    c.dictEnum = @"RESPONSE";
    c.caption = NSLocalizedString(@"Response", nil);
    
    vh.viewTitle = NSLocalizedString(@"OBDII data", @"grid zaznamov");
    vh.gridData = obdData;
    vh.columnsCaptionsHeight = 30;
    vh.gridType = eGRDODBII;
    vh.cellSelectionStyle = UITableViewCellSelectionStyleNone;
    
    [vh setModalPresentationStyle:UIModalPresentationFormSheet];
    UINavigationController *ncPicker = [[UINavigationController alloc] initWithRootViewController:vh];
    [ncPicker setModalPresentationStyle:UIModalPresentationFormSheet];
    ncPicker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController presentViewController:ncPicker animated:YES completion:nil];
    ncPicker.preferredContentSize = CGSizeMake(700, 480);
    ncPicker.view.superview.center = self.view.superview.center;
    [self EnabledAllComponents:YES];
}

-(IBAction)showOdlozPoloz:(id)sender {
    VCBaseGrid *vh = [[VCBaseGrid alloc] initWithFrame:CGRectMake(0, 0, 900, 480)];
    Column *c = [vh addColumnWithSize:CGSizeMake(800, 30) textAlign:NSTextAlignmentLeft];
    c.dictEnum = @"DEMAND_DESCRIPTION";
    c.caption = NSLocalizedString(@"Popis", nil);
    
    c = [vh addColumnWithSize:CGSizeMake(100, 30) textAlign:NSTextAlignmentLeft];
    c.dictEnum = @"SELL_PRICE";
    c.caption = NSLocalizedString(@"Cena", nil);
    
    vh.viewTitle = NSLocalizedString(@"Odlozene polozky", @"grid zaznamov");
    vh.gridData = [DMSetting sharedDMSetting].odlozPoloz;
    vh.columnsCaptionsHeight = 30;
    vh.gridType = eGRDODLPOLZ;
    vh.cellSelectionStyle = UITableViewCellSelectionStyleNone;
    
    [vh setModalPresentationStyle:UIModalPresentationFormSheet];
    UINavigationController *ncPicker = [[UINavigationController alloc] initWithRootViewController:vh];
    [ncPicker setModalPresentationStyle:UIModalPresentationFormSheet];
    ncPicker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController presentViewController:ncPicker animated:YES completion:nil];
    ncPicker.preferredContentSize = CGSizeMake(900, 480);
    ncPicker.view.superview.center = self.view.superview.center;
}

- (IBAction)showSDA:(id)sender
{
    
    VCBaseGrid *vh = [[VCBaseGrid alloc] initWithFrame:CGRectMake(0, 0, 900, 480)];
    Column *c = [vh addColumnWithSize:CGSizeMake(200, 30) textAlign:NSTextAlignmentRight];
    c.dictEnum = @"ACTION_NO";
    c.caption = NSLocalizedString(@"Kód závady", nil);
    
    c = [vh addColumnWithSize:CGSizeMake(200, 30) textAlign:NSTextAlignmentLeft];
    c.dictEnum = @"ACTION_TYPE";
    c.caption = NSLocalizedString(@"Typ akce", nil);
    
    c = [vh addColumnWithSize:CGSizeMake(500, 30) textAlign:NSTextAlignmentLeft];
    c.dictEnum = @"ACTION_TXT";
    c.caption = NSLocalizedString(@"Popis", nil);
    
    vh.viewTitle = NSLocalizedString(@"Svolávací a dílenské akce", @"grid zaznamov");
    vh.gridData = [DMSetting sharedDMSetting].SDA;
    vh.columnsCaptionsHeight = 30;
    vh.gridType = eGRDSDA;
    vh.cellSelectionStyle = UITableViewCellSelectionStyleNone;
    
    [vh setModalPresentationStyle:UIModalPresentationFormSheet];
    UINavigationController *ncPicker = [[UINavigationController alloc] initWithRootViewController:vh];
    [ncPicker setModalPresentationStyle:UIModalPresentationFormSheet];
    ncPicker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController presentViewController:ncPicker animated:YES completion:nil];
    ncPicker.preferredContentSize = CGSizeMake(900, 480);
    ncPicker.view.superview.center = self.view.superview.center;
}

- (IBAction)showPZ:(id)sender
{
    VCBaseGrid *vh = [[VCBaseGrid alloc] initWithFrame:CGRectMake(0, 0, 900, 480)];
    Column *c = [vh addColumnWithSize:CGSizeMake(200, 30) textAlign:NSTextAlignmentRight];
    c.dictEnum = @"WorkshopDescription";
    c.caption = NSLocalizedString(@"Provozovna", nil);
    
    c = [vh addColumnWithSize:CGSizeMake(200, 30) textAlign:NSTextAlignmentLeft];
    c.dictEnum = @"TeamDescription";
    c.caption = NSLocalizedString(@"Tým", nil);
    
    c = [vh addColumnWithSize:CGSizeMake(500, 30) textAlign:NSTextAlignmentLeft];
    c.dictEnum = @"PlannedActivity";
    c.caption = NSLocalizedString(@"Činnost", nil);
    
    vh.viewTitle = NSLocalizedString(@"Plánované činnosti", @"grid zaznamov");
    vh.gridData = [[DMSetting sharedDMSetting].PZ objectForKey:@"ACTIVITIES"];
    vh.columnsCaptionsHeight = 30;
    vh.gridType = eGRDPZ;
    vh.cellSelectionStyle = UITableViewCellSelectionStyleNone;
    
    [vh setModalPresentationStyle:UIModalPresentationFormSheet];
    UINavigationController *ncPicker = [[UINavigationController alloc] initWithRootViewController:vh];
    [ncPicker setModalPresentationStyle:UIModalPresentationFormSheet];
    ncPicker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController presentViewController:ncPicker animated:YES completion:nil];
    ncPicker.preferredContentSize = CGSizeMake(900, 480);
    ncPicker.view.superview.center = self.view.superview.center;
}

- (IBAction)getDate:(id)sender
{
    NSDate *now = [NSDate date];
    //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM.yyyy"];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
    [components setHour:1];
    
    NSMutableArray *years = [[NSMutableArray alloc] init];
    for(NSInteger i=0 ; i< 30; i++)
        [years addObject:[NSString stringWithFormat:@"%d", (2000+i)]];
    
    NSArray *pickerArray = [NSArray arrayWithObjects:
                            [NSArray arrayWithObjects: 
                             NSLocalizedString(@"Leden", @"mesice"), NSLocalizedString(@"Unor", @"mesice"),
                             NSLocalizedString(@"Brezen", @"mesice"), NSLocalizedString(@"Duben", @"mesice"),
                             NSLocalizedString(@"Kveten", @"mesice"), NSLocalizedString(@"Cerven", @"mesice"),
                             NSLocalizedString(@"Cervenec", @"mesice"), NSLocalizedString(@"Srpen", @"mesice"),
                             NSLocalizedString(@"Zari", @"mesice"), NSLocalizedString(@"Rijen", @"mesice"),
                             NSLocalizedString(@"Listopad", @"mesice"), NSLocalizedString(@"Prosinec", @"mesice"), nil],
                            years, nil];
    
    vcPicker *picker = [[vcPicker alloc] initWithNibName:@"vcPicker" bundle:[NSBundle mainBundle]];

    if([sender tag] == btnEmise.tag && [[txtEmise text] length] > 0)
        components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[dateFormatter dateFromString:[txtEmise text]]];
    else if([sender tag] == btnSTK.tag && [[txtSTK text] length] > 0)
        components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[dateFormatter dateFromString:[txtSTK text]]];

    if(txtEmise.text.length == 0)
        txtEmise.text = [NSString stringWithFormat:@"%d.%d", components.month, components.year];
    if(txtSTK.text.length == 0  && [sender tag] != btnEmise.tag)
        txtSTK.text = [NSString stringWithFormat:@"%d.%d", components.month, components.year];
    [self changedValue];
    
    [picker setSetPos:[NSArray arrayWithObjects:[NSNumber numberWithInt:[components month]-1], [NSNumber numberWithInt:[components year]-2000], nil]];
    [picker setPickerDelegate:self];
    [picker.view setTag:[sender tag]];
    [picker setPickerArray:pickerArray];
    [picker setModalPresentationStyle:UIModalPresentationFormSheet];
    
    CGRect r = [self.view convertRect:[sender frame] fromView:((UIButton *) sender).superview];
    
    myPopoverController = [[UIPopoverController alloc] initWithContentViewController:picker];
    myPopoverController.delegate = self;
    myPopoverController.popoverContentSize = CGRectMake(0, 0, 300, 216).size;
    [myPopoverController presentPopoverFromRect:r inView:[self view] permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

-(void) loadPlanovaneZakazky
{
    [self EnabledAllComponents:NO];
    [[WSDCHIDataTransfer sharedWSDCHIDataTransfer] startRequestGetPlanZakazky];
//    [[WSCommunications sharedWSCommunications].wsLoadCarManufactureData startRequestGetPlanZakazky];
    //    [self loadPlanVozidla];
}

- (IBAction)getRZVFromPlanVoz:(id)sender
{
    [self loadPlanovaneZakazky];
}

- (void)showPlanVozidla
{
    VCVozVyber *vh = [[VCVozVyber alloc] initWithFrame:CGRectMake(0, 0, 1000, 480)];
    Column *c = [vh addColumnWithSize:CGSizeMake(100, 44) textAlign:NSTextAlignmentRight];
    c.dictEnum = @"DATA_SOURCE";
    c.caption = NSLocalizedString(@"Zdroj", nil);
    
    c = [vh addColumnWithSize:CGSizeMake(100, 44) textAlign:NSTextAlignmentLeft];
    c.dictEnum = @"PLANNED_ORDER_STATUS";
    c.caption = NSLocalizedString(@"Status", nil);
    
    c = [vh addColumnWithSize:CGSizeMake(100, 44) textAlign:NSTextAlignmentLeft];
    c.dictEnum = @"LICENSE_TAG";
    c.caption = NSLocalizedString(@"RZV", nil);
    
    c = [vh addColumnWithSize:CGSizeMake(400, 44) textAlign:NSTextAlignmentLeft];
    c.dictEnum = @"VEHICLE_DESCRIPTION";
    c.caption = NSLocalizedString(@"Vozidlo", nil);
    
    c = [vh addColumnWithSize:CGSizeMake(200, 44) textAlign:NSTextAlignmentLeft];
    c.dictEnum = @"CUSTOMER_LABEL";
    c.caption = NSLocalizedString(@"Zakaznik", nil);
    
    c = [vh addColumnWithSize:CGSizeMake(100, 44) textAlign:NSTextAlignmentLeft];
    c.dictEnum = @"PLANNED_ORDER_NO";
    c.caption = NSLocalizedString(@"PZ c.", nil);
    
    vh.viewTitle = NSLocalizedString(@"Planovane zakazky/checkIny", @"grid zaznamov");
    vh.gridData = [DMSetting sharedDMSetting].planovaneZakazky;
    vh.columnsCaptionsHeight = 30;
    vh.gridRowHeight = 44;
    vh.vozVyberDelegate = self;
    vh.gridType = eGRDPLANZAK;
    
    [vh setModalPresentationStyle:UIModalPresentationFormSheet];
    UINavigationController *ncPicker = [[UINavigationController alloc] initWithRootViewController:vh];
    [ncPicker setModalPresentationStyle:UIModalPresentationFormSheet];
    ncPicker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController presentViewController:ncPicker animated:YES completion:nil];
    ncPicker.preferredContentSize = CGSizeMake(1000, 480);
    ncPicker.view.superview.center = self.view.superview.center;
}

#pragma mark -
#pragma mark grids delegates
//- (void)vozVyberSelected:(VCVozVyber *)Sender data:(NSDictionary *)data
//{
//    [[self navigationController] dismissModalViewControllerAnimated:YES];
//}

- (void)vozVyberDisaper:(VCVozVyber *)Sender
{
    if(Sender.selectedData == nil)
        return;
    NSDictionary *selectedData = Sender.selectedData;
    
    [TRABANT_APP_DELEGATE setChecking_id:-1];
    
    if(existInDic(selectedData, @"CHECKIN_ID"))
        [TRABANT_APP_DELEGATE setChecking_id: [[selectedData objectForKey:@"CHECKIN_ID"] integerValue]];
    self.lblNavBar.text = NSLocalizedString(@"Vozidlo nevybrano", @"navig title");
    [self changedValue];
    
    NSInteger vozidlo_id = (existInDic(selectedData, @"VEHICLE_ID"))?[[selectedData valueForKey:@"VEHICLE_ID"] integerValue]:-1;
    NSInteger oZakazka_id = (existInDic(selectedData, @"PLANNED_ORDER_ID"))?[[selectedData valueForKey:@"PLANNED_ORDER_ID"] integerValue]:-1;
    NSInteger checkIn_id = (existInDic(selectedData, @"CHECKIN_ID"))?[[selectedData valueForKey:@"CHECKIN_ID"] integerValue]:-1;
    NSString *rzv = [selectedData valueForKey:@"LICENSE_TAG"];
//    txtRZV.text = rzv;
    
    switch ([Sender gridType]) {
        case eGRDPLANZAK:
            if(rzv.length)
            {
                lblCheckinNr.text = @"";
                [self clearAllData:self.view];
                [self EnabledAllComponents:NO];
                [[WSDCHIDataTransfer sharedWSDCHIDataTransfer] startGetCarDataWithVozidloId:vozidlo_id checkIn_id:checkIn_id oZakazkaId:oZakazka_id rzv:@"" vin:@""];
//                [[WSCommunications sharedWSCommunications].wsLoadCarManufactureData startGetCarDataWithVozidloId:vozidlo_id checkIn_id:checkIn_id oZakazkaId:oZakazka_id rzv:@"" vin:@""];
            }
            break;
        case eGRDZOZNAMRZV:

            if(vozidlo_id >0)
            {
                lblCheckinNr.text = @"";
                [self clearAllData:self.view];
                [self EnabledAllComponents:NO];
                [[WSDCHIDataTransfer sharedWSDCHIDataTransfer] startGetCarDataWithVozidloId:vozidlo_id checkIn_id:checkIn_id oZakazkaId:oZakazka_id rzv:@"" vin:@""];
//                [[WSCommunications sharedWSCommunications].wsLoadCarManufactureData startGetCarDataWithVozidloId:vozidlo_id checkIn_id:checkIn_id oZakazkaId:oZakazka_id rzv:@"" vin:@""];
            }
            break;
        default:
            break;
    }
}

- (void)dataChanged:(NSNotification *)notification
{
    NSLog(@"Did get notification %@", notification.object);
    if([notification.object isEqualToString:@"GetCheckinOrderList"])
    {
        [self performSelectorOnMainThread:@selector(showPlanVozidla) withObject:self waitUntilDone:YES];
    }
    else if([notification.object isEqualToString:@"GetCarData"])
    {
        if(existInDic([DMSetting sharedDMSetting].vozidlo, @"CHECKIN_NUMBER") && [[DMSetting sharedDMSetting].vozidlo valueForKey:@"CHECKIN_NUMBER"] > 0)
        {
            lblCheckinNr.textColor = [UIColor lightGrayColor];
            lblCheckinNr.text = [[[DMSetting sharedDMSetting].vozidlo valueForKey:@"CHECKIN_NUMBER"] stringValue];
        }
        else if(existInDic([DMSetting sharedDMSetting].vozidlo, @"PLANNED_ORDER_ID"))
        {
            lblCheckinNr.textColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.9 alpha:0.5];
            lblCheckinNr.text = [[DMSetting sharedDMSetting].vozidlo objectForKey:@"PLANNED_ORDER_NO"];
        }
        else
            lblCheckinNr.text = @"";
        NSLog(@"\nnotificatio :%@\nvozidlo :%@", notification, [DMSetting sharedDMSetting].vozidlo);
        [[DMSetting sharedDMSetting].vozidlo setValue:[[DMSetting sharedDMSetting].loggedUser valueForKey:@"PERSONAL_IND"] forKey:@"PERSONAL_IND"];
        if([[DMSetting sharedDMSetting].vozidlo count] == 0)
        {
            [self setDefaultData];
            ROOTNAVIGATOR.vozCaption = NSLocalizedString(@"Nezname vozidlo", @"navig title");
            self.lblNavBar.text = ROOTNAVIGATOR.vozCaption;
            return;
        }
        else{
            [self performSelectorOnMainThread:@selector(loadDataVozidlo) withObject:self waitUntilDone:YES];
        }
    }
    else if([notification.object isEqualToString:@"ShowVozidla"])
    {
        [self performSelectorOnMainThread:@selector(showVozidla:) withObject:self waitUntilDone:YES];
    }
    else if([notification.object isEqualToString:@"ChiReport"])
    {
        [self showProtocol];
    }
    else if ([notification.object isEqualToString:@"LoadedOBDIIData"])
    {
        [self performSelectorOnMainThread:@selector(showOBDIIData) withObject:self waitUntilDone:YES];
    }
    else if([notification.object isEqualToString:@"StaticDataUpdate"])
    {
        [ROOTNAVIGATOR releaseData];
//        [self setDefaultData];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:NSLocalizedString(@"StaticDataUpdate", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if([notification.object isEqualToString:@"GetWPForCheckIn"])
    {
        ((tbcBarController *)self.tabBarController).reloadPackets = YES;
    }
    else if([notification.object isEqualToString:@"GetWPForCheckIn"])
    {
        NSLog(@"%@", ROOTNAVIGATOR.presentedViewController);
        
    }
        
}

- (void)loadDataVozidlo
{
    if(existInDic([DMSetting sharedDMSetting].vozidlo, @"CHECKIN_ID"))
        [TRABANT_APP_DELEGATE setChecking_id:[[[DMSetting sharedDMSetting].vozidlo valueForKey:@"CHECKIN_ID"] integerValue]];
    else
        [TRABANT_APP_DELEGATE setChecking_id:-1];
    
    [((vcTrabantPictures*)[[self.tabBarController.viewControllers objectAtIndex:1] viewControllers].lastObject) deallocData];
    [self naplnPropertky];
    NSString *vozPopis;
    if(existInDic([DMSetting sharedDMSetting].vozidlo, @"VEHICLE_DESCRIPTION"))
        vozPopis = [[DMSetting sharedDMSetting].vozidlo valueForKey:@"VEHICLE_DESCRIPTION"];
    else
        vozPopis = NSLocalizedString(@"Nezname vozidlo", @"navig title");
    ROOTNAVIGATOR.vozCaption = vozPopis;
    self.lblNavBar.text = vozPopis;
    
    ((tbcBarController*)self.tabBarController).reloadData = YES;
    [self loadPovinPole];
//    [[DMSetting sharedDMSetting].baners reloadData];
}

- (void)baseGridSelected:(VCBaseGrid *)Sender data:(id)data
{
    NSString *vyrobekVoz;
    NSNumber *n;
    switch (Sender.gridType) {
        case eGRDVYRVOZ:
            vyrobekVoz = [data objectForKey:@"BRAND_ID"];
            [btnVyrobekVoz setTitle:vyrobekVoz forState:UIControlStateNormal];
            [[DMSetting sharedDMSetting].vozidlo setValue:btnVyrobekVoz.titleLabel.text forKey:@"BRAND_ID"];
            [[DMSetting sharedDMSetting].vozidlo removeObjectForKey:@"SILHOUETTE_ID"];
            [btnVyrobekVoz setImage:[vozIcons objectForKey:btnVyrobekVoz.titleLabel.text] forState:UIControlStateNormal];
            [self EnabledAllComponents:NO];
            [[DMSetting sharedDMSetting] reloadScenare];
            [[DMSetting sharedDMSetting] reloadSiluets];
            [[DMSetting sharedDMSetting].baners reloadData];
            txtScenar.text = [[[DMSetting sharedDMSetting] getActualScenarData] objectForKey:@"TEXT"];
            [self setStatusOdeslani:NO];
            ((tbcBarController*)self.tabBarController).reloadData = YES;
            [(vcNabidky *)[[self.tabBarController viewControllers].lastObject viewControllers].lastObject refresTableData];
            break;
        case eGRDPALIVODRUH:
            n = [data objectForKey:@"FUEL_ID"];
            [[DMSetting sharedDMSetting].vozidlo setValue:n forKey:@"FUEL_ID"];
            [self setStatusOdeslani:NO];
            break;
        case eGRDSCENARE:
            txtScenar.text = [data objectForKey:@"TEXT"];
            btnScenar.tag = [[data objectForKey:@"CHECK_SCENARIO_ID"] integerValue];
            [[DMSetting sharedDMSetting].vozidlo setValue:[data objectForKey:@"CHECK_SCENARIO_ID"] forKey:@"CHECK_SCENARIO_ID"];
            [[DMSetting sharedDMSetting] removeSluzbyData];
            ((tbcBarController*)self.tabBarController).reloadData = YES;
            [[DMSetting sharedDMSetting] reloadScenare];
            [self loadPovinPole];
            [self setStatusOdeslani:NO];
            break;
        default:
            break;
    }
    
    [self changedValue];
    [myPopoverController dismissPopoverAnimated:YES];
    
}
- (void)baseGridDisaper:(VCBaseGrid *)Sender
{
    
}
#pragma mark -
- (IBAction)getPalivoDruh:(id)sender
{
    NSArray *palivoArray = [DMSetting sharedDMSetting].palivoArray;
    VCBaseGrid *g = [[VCBaseGrid alloc] initWithFrame:CGRectMake(0, 0, 180, palivoArray.count * 44)];
    Column *c = [g addColumnWithSize:CGSizeMake(180, 44) textAlign:NSTextAlignmentRight];
    c.dictEnum = @"TEXT";
    
    g.viewTitle = NSLocalizedString(@"Palivovy system", @"grid zaznamov");
    g.gridData = palivoArray;
    g.gridRowHeight = 44;
    g.baseGridDelegate = self;
    g.gridType = eGRDPALIVODRUH;
    
    CGRect r = [self.view convertRect:[sender frame] fromView:((UIButton *) sender).superview];
    
    myPopoverController = [[UIPopoverController alloc] initWithContentViewController:g];
    myPopoverController.delegate = self;
    myPopoverController.popoverContentSize = CGRectMake(0, 0, 180, palivoArray.count * 44).size;
    [myPopoverController presentPopoverFromRect:r inView:[self view] permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];

    NSInteger palivoId = [[[DMSetting sharedDMSetting].vozidlo valueForKey:@"FUEL_ID"] integerValue];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"FUEL_ID.intValue = %i", palivoId];//btnPalivo.tag];
    NSDictionary *d = [palivoArray filteredArrayUsingPredicate:predicate].lastObject;
    
    [g setSelectRow:[NSIndexPath indexPathForRow:[palivoArray indexOfObject:d] inSection:0]];

}

- (void)showVozidla:(id)sender
{
    [self EnabledAllComponents:NO];
    VCVozVyber *vh = [[VCVozVyber alloc] initWithFrame:CGRectMake(0, 0, 1000, 480)];
    Column *c = [vh addColumnWithSize:CGSizeMake(100, 44) textAlign:NSTextAlignmentRight];
    c.dictEnum = @"LICENSE_TAG";
    c.caption = NSLocalizedString(@"RZV", nil);
    
    c = [vh addColumnWithSize:CGSizeMake(200, 44) textAlign:NSTextAlignmentLeft];
    c.dictEnum = @"VIN";
    c.caption = NSLocalizedString(@"VIN", nil);
    
    c = [vh addColumnWithSize:CGSizeMake(400, 44) textAlign:NSTextAlignmentLeft];
    c.dictEnum = @"VEHICLE_CAPTION";
    c.caption = NSLocalizedString(@"Vozidlo", nil);
    
    c = [vh addColumnWithSize:CGSizeMake(200, 44) textAlign:NSTextAlignmentLeft];
    c.dictEnum = @"DRIVER_NAME_SURN";
    c.caption = NSLocalizedString(@"Zakaznik", nil);
    
    c = [vh addColumnWithSize:CGSizeMake(100, 44) textAlign:NSTextAlignmentLeft];
    c.dictEnum = @"OZAKAZKA_NR";
    c.caption = NSLocalizedString(@"PZ c.", nil);
    
    vh.viewTitle = NSLocalizedString(@"Nejednoznacne RZV", @"grid zaznamov");
    vh.gridData = [DMSetting sharedDMSetting].vozidla;
    vh.columnsCaptionsHeight = 30;
    vh.gridRowHeight = 44;
    vh.vozVyberDelegate = self;
    vh.gridType = eGRDZOZNAMRZV;
    
    [vh setModalPresentationStyle:UIModalPresentationFormSheet];
    UINavigationController *ncPicker = [[UINavigationController alloc] initWithRootViewController:vh];
    [ncPicker setModalPresentationStyle:UIModalPresentationFormSheet];
    ncPicker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController presentViewController:ncPicker animated:YES completion:nil];
    ncPicker.preferredContentSize = CGSizeMake(1000, 480);
    ncPicker.view.superview.center = self.view.superview.center;
}

- (IBAction)showVyrobekVoz:(id)sender
{
    VCBaseGrid *g = [[VCBaseGrid alloc] initWithFrame:CGRectMake(0, 0, 180, [DMSetting sharedDMSetting].vyrobekVoz.count * 44)];
    
    g.gridData = [DMSetting sharedDMSetting].vyrobekVoz;
    g.columnsCaptionsHeight = 0;
    g.gridRowHeight = 44;
    g.gridType = eGRDVYRVOZ;
    g.baseGridDelegate = self;
    
    Column *c = [g addColumnWithSize:CGSizeMake(180, 44) textAlign:NSTextAlignmentRight];
    c.dictEnum = @"BRAND_TXT";
//    c.caption = NSLocalizedString(@"Palivovy system", nil);
    
    myPopoverController = [[UIPopoverController alloc] initWithContentViewController:g];
    myPopoverController.delegate = self;
    myPopoverController.popoverContentSize = CGSizeMake(180, [DMSetting sharedDMSetting].vyrobekVoz.count * 44);
    [myPopoverController presentPopoverFromRect:[sender frame] inView:[self view] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    NSArray *a = [[DMSetting sharedDMSetting].vyrobekVoz filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"BRAND_ID == %@ ",
                                                                                            btnVyrobekVoz.titleLabel.text ]];
    NSInteger index = [[DMSetting sharedDMSetting].vyrobekVoz indexOfObject:a.lastObject];
    a = nil;
    [g setSelectRow:[NSIndexPath indexPathForRow:index inSection:0]];
}

- (IBAction)showScenare:(id)sender
{
    NSArray *scenare = [DMSetting sharedDMSetting].scenar;

    VCBaseGrid *g = [[VCBaseGrid alloc] initWithFrame: CGRectMake(2, 2, 180, scenare.count * 44)];
    Column *c = [g addColumnWithSize:CGSizeMake(180, 44) textAlign:NSTextAlignmentRight];
    c.dictEnum = @"TEXT";
    
    g.gridData = scenare;
    g.columnsCaptionsHeight = 0;
    g.gridRowHeight = 44;
    g.gridType = eGRDSCENARE;
    g.baseGridDelegate = self;
    
    CGRect r = [self.view convertRect:[sender frame] fromView:((UIButton *) sender).superview];
    
    myPopoverController = [[UIPopoverController alloc] initWithContentViewController:g];
    myPopoverController.delegate = self;
    myPopoverController.popoverContentSize = CGRectMake(0, 0, 180, scenare.count * 44).size;
    if ([myPopoverController respondsToSelector:@selector(setBackgroundColor:)]) {   // Check to avoid app crash prior to iOS 7
        myPopoverController.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pozadie_ciste"]];
    }
    [myPopoverController presentPopoverFromRect:r inView:[self view] permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    
    NSInteger scenarId = [[[DMSetting sharedDMSetting].vozidlo valueForKey:@"CHECK_SCENARIO_ID"] integerValue];
    NSArray *a = [scenare filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"CHECK_SCENARIO_ID.intValue == %d ",
                                                  scenarId ]];
    NSInteger index = [scenare indexOfObject:a.lastObject];
    a=nil;
    [g setSelectRow:[NSIndexPath indexPathForRow:index inSection:0]];
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    row = [[NSMutableDictionary alloc] init];
    loadedData = [[NSMutableArray alloc] init];
    btnPZ.enabled = NO;
    btnSDA.enabled = NO;
    btnOdlozPoloz.enabled = NO;
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"alu_texture_view.png"]]];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    btnVyrobekVoz.contentMode = UIViewContentModeScaleAspectFit;
    btnVyrobekVoz.clipsToBounds = YES;

    NSArray *vozObjs = [NSArray arrayWithObjects:
                        [UIImage imageNamed:@"nologo_chi"],
                        [UIImage imageNamed:@"Audi_chi"],
                        [UIImage imageNamed:@"VW_Nutzfarhrzeuge_chi"],
                        [UIImage imageNamed:@"VW_chi"],
                        [UIImage imageNamed:@"Seat_chi"],
                        [UIImage imageNamed:@"Porsche_chi"],
                        [UIImage imageNamed:@"SKODA_chi"], nil];
    vozIcons = [NSDictionary dictionaryWithObjects:vozObjs
                                           forKeys:[NSArray arrayWithObjects:@"F", @"A", @"N", @"V", @"S", @"P", @"C", nil]];
    
    NSString *brandId = @"C";/*[[DMSetting sharedDMSetting].setting objectForKey:@"VYROBEKVOZ_OZN"]*/
    [btnVyrobekVoz setTitle:brandId forState:UIControlStateNormal];
    [btnVyrobekVoz setImage:[vozIcons objectForKey:btnVyrobekVoz.titleLabel.text] forState:UIControlStateNormal];
    [[DMSetting sharedDMSetting].vozidlo setValue:btnVyrobekVoz.titleLabel.text forKey:@"BRAND_ID"];
    [[DMSetting sharedDMSetting].baners reloadData];
    

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"BRAND_ID = %@", brandId];
    NSDictionary *vyrVozDic = [[DMSetting sharedDMSetting].vyrobekVoz filteredArrayUsingPredicate:predicate].lastObject;

    [[DMSetting sharedDMSetting].vozidlo setValue:[vyrVozDic valueForKey:@"CHECK_SCENARIO_ID_DEF"] forKey:@"CHECK_SCENARIO_ID"];
    btnScenar.tag = [[vyrVozDic valueForKey:@"CHECK_SCENARIO_ID_DEF"] integerValue];
    
    ROOTNAVIGATOR.vozCaption = NSLocalizedString(@"Vozidlo nevybrano", @"navig title");
    self.lblNavBar.text = ROOTNAVIGATOR.vozCaption;
    [self.view.subviews.lastObject setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"pozadie_vozzak"]]];
    
    [[DMSetting sharedDMSetting] reloadScenare];
    txtScenar.text = [[[DMSetting sharedDMSetting] getActualScenarData] objectForKey:@"TEXT"];
    [self setDefaultData];
    ((tbcBarController*)self.tabBarController).reloadData = YES;
    [self setLabelsByLanguage];
}

- (void)setLabelsByLanguage
{
    [lblVozidlo[0] setText:NSLocalizedString(@"RZV", @"navig title")];
    [lblVozidlo[1] setText:NSLocalizedString(@"Scenar", @"navig title")];
    [lblVozidlo[2] setText:NSLocalizedString(@"Datum prodeje/MR", @"navig title")];
    [lblVozidlo[3] setText:NSLocalizedString(@"Pojistovaci udalost", @"navig title")];
    [lblVozidlo[4] setText:NSLocalizedString(@"Platnost STK", @"navig title")];
    [lblVozidlo[5] setText:NSLocalizedString(@"OTP", @"navig title")];
    [lblVozidlo[6] setText:NSLocalizedString(@"Stav paliva", @"navig title")];
    [lblVozidlo[7] setText:NSLocalizedString(@"Stav oleje", @"Oil level")];
    [lblVozidlo[8] setText:NSLocalizedString(@"VIN", @"navig title")];
    [lblVozidlo[9] setText:NSLocalizedString(@"Zakaznik", @"navig title")];
    [lblVozidlo[10] setText:NSLocalizedString(@"Vuz pristavil", @"navig title")];
    [lblVozidlo[11] setText:NSLocalizedString(@"Stav tachometru", @"navig title")];
    [lblVozidlo[12] setText:NSLocalizedString(@"Platnost EK", @"navig title")];
    [lblVozidlo[13] setText:NSLocalizedString(@"Servisni knizka", @"navig title")];
    [lblVozidlo[14] setText:NSLocalizedString(@"Interiér", @"navig title")];
    [lblVozidlo[15] setText:NSLocalizedString(@"Informace o vozidle", @"navig title")];
    
    txtRZV.placeholder = NSLocalizedString(@"Pozadovano", @"navig title");
    txtScenar.placeholder = NSLocalizedString(@"Pozadovano", @"navig title");
    txtSTK.placeholder = NSLocalizedString(@"Pozadovano", @"navig title");
    txtVIN.placeholder = NSLocalizedString(@"Pozadovano", @"navig title");
    txtZakaznik.placeholder = NSLocalizedString(@"Zakaznik PH", @"navig title");
    txtVozPristavil.placeholder = NSLocalizedString(@"Jmeno Prijmeni", @"navig title");
    txtKmStav.placeholder = NSLocalizedString(@"Pozadovano", @"navig title");
    txtEmise.placeholder = NSLocalizedString(@"Pozadovano", @"navig title");
}

- (void) setStatusOdeslaniMsg:(id)Sender
{
    [self setStatusOdeslani:NO];
}

-(void) changedValue
{
    self.enableSave = (txtVIN.text.length && txtRZV.text.length && txtKmStav.text.length && txtZakaznik.text.length && txtSTK.text.length && txtEmise.text.length && txtScenar.text.length);
    NSLog(@"%d", self.enableSave);
    [self setStatusOdeslani:NO];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self changedValue];
}

- (IBAction)didChanget:(id)sender
{
    [self changedValue];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField.frame.origin.y+textField.frame.size.height + 20 < 368)
        return YES;
    [ROOTNAVIGATOR setTxtActive:textField];
    [ROOTNAVIGATOR setTbvcActive:nil];
    return YES;    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [ROOTNAVIGATOR setTxtActive:textView];
    [ROOTNAVIGATOR setTbvcActive:nil];
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
    return YES;
}

-(IBAction)rzvShouldReturn:(UITextField*)textField;
{
    [textField resignFirstResponder];
}

-(IBAction)rzvEditingChanget:(UITextField*)textField;
{
    textField.text = [textField.text uppercaseString];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self setStatusOdeslani:NO];
}

- (void)viewDidUnload
{
    txtPalivoDruh = nil;
    txtRZV = nil;
    txtKmStav = nil;
    scStavNadrze = nil;
    scStavInterieru = nil;
    txtZakaznik = nil;
    txtVozPristavil = nil;
    chkPoistPrip_prp = nil;
    btnGetRZVPlanVoz = nil;
    txtSTK = nil;
    txtEmise = nil;
    btnSTK = nil;
    btnEmise = nil;
    btnVyrobekVoz = nil;
    txtProdej_dat = nil;
    btnVozTyp = nil;
    tvcRow = nil;
    odoslaniStatus = nil;
    txtScenar = nil;
    btnScenar = nil;
    chkOTP_prp = nil;
    chkServisKniz_prp = nil;
    lblUser = nil;
    btnNavleft = nil;
    btnNavright = nil;
    btnNavBarSave = nil;
    scStavOleje = nil;
    lblVozidlo = nil;
    planVozArrays = nil;
    planVozSeaking = nil;
    loadedData = nil;
    row = nil;
    vozIcons = nil;
    myPopoverController = nil;
    insertResultMessage = nil;
    dateFormatter = nil;
    btnPZ = nil;
    btnSDA = nil;
    btnOdlozPoloz = nil;
    btnPalivo = nil;
    scStavOleje = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshData];
//    NSString *userName = [NSString stringWithFormat:@"%@ %@", [[DMSetting sharedDMSetting].loggedUser valueForKey:@"NAME"], [[DMSetting sharedDMSetting].loggedUser valueForKey:@"SURNAME"] ];
//    lblUser.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Poradce", nil), userName];
//    if(existInDic([DMSetting sharedDMSetting].vozidlo, @"CHECKIN_NR"))
//        lblCheckinNr.text = [[[DMSetting sharedDMSetting].vozidlo valueForKey:@"CHECKIN_NR"] stringValue];
//    else
//        lblCheckinNr.text = @"";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    if ([myPopoverController isPopoverVisible]) {
        [myPopoverController dismissPopoverAnimated:YES];
    }
    [self.view endEditing:YES];
    [btnGetRZVPlanVoz becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)clearAllData:(id)Sender
{
    [self clearUIData:Sender];
    
    //TODO vymazanie CHECKIN dat z DMSetting
    [[DMSetting sharedDMSetting] clearAllData];
    chkPoistPrip_prp.on = YES;
    chkOTP_prp.on = NO;
    chkServisKniz_prp.on = NO;
    scStavNadrze.selectedSegmentIndex = 0;
    scStavInterieru.selectedSegmentIndex = 0;
    
    [[DMSetting sharedDMSetting] removeProtokolFiles];
    
}

-(void)clearUIData:(id)Sender
{
    for (id obj in [Sender subviews]){
        if([obj isKindOfClass:[UITextField class]])
            [obj setText:@""];
        else if([obj isKindOfClass:[UITableView class]])
            [self clearUIData:obj];
        else if([obj isKindOfClass:[UITableViewCell class]]) {
            [obj setAccessoryType:UITableViewCellAccessoryNone];
            [self clearUIData:[obj contentView]];
        }
        else if([obj isKindOfClass:[UIView class]])
            [self clearUIData:obj];
    }
}

- (void) setDefaultData
{
    btnPZ.enabled = NO;
    btnSDA.enabled = NO;
    btnOdlozPoloz.enabled = NO;
    btnPalivo.tag = 1;
    scStavInterieru.selectedSegmentIndex = 0;
    [chkOTP_prp setOn:YES];
    [[DMSetting sharedDMSetting].vozidlo setValue:@1 forKey:@"CRW_EXISTS"];
    [chkPoistPrip_prp setOn:NO];
    [[DMSetting sharedDMSetting].vozidlo setValue:@0 forKey:@"INSURANCE_CASE"];
    [chkServisKniz_prp setOn:YES];
    [[DMSetting sharedDMSetting].vozidlo setValue:@1 forKey:@"SERVBOOK_EXISTS"];
    [[DMSetting sharedDMSetting].vozidlo setValue:@1 forKey:@"INTERIOR_STATE"];
    [[DMSetting sharedDMSetting].vozidlo setValue:@2 forKey:@"EXTERIOR_STATE"];
    [[DMSetting sharedDMSetting].vozidlo setValue:@1 forKey:@"FUEL_ID"];
    [[DMSetting sharedDMSetting].vozidlo setValue:@0 forKey:@"FUEL_LEVEL"];
    [[DMSetting sharedDMSetting].vozidlo setValue:@1 forKey:@"OIL_LEVEL"];
    scStavOleje.selectedSegmentIndex = 1;
    [[DMSetting sharedDMSetting].vozidlo setValue:txtVIN.text forKey:@"VIN"];
    [[DMSetting sharedDMSetting].vozidlo setValue:txtRZV.text forKey:@"LICENSE_TAG"];
    txtVIN.enabled = YES;
    btnVyrobekVoz.enabled = YES;
    txtRZV.text = [txtRZV.text uppercaseString];
    NSString *brandId = [[[DMSetting sharedDMSetting] loggedUser] valueForKey:@"BRAND_ID"];
    [btnVyrobekVoz setTitle:brandId forState:UIControlStateNormal];
    [[DMSetting sharedDMSetting].vozidlo setValue:btnVyrobekVoz.titleLabel.text forKey:@"BRAND_ID"];
    [[DMSetting sharedDMSetting].vozidlo removeObjectForKey:@"SILHOUETTE_ID"];
    [btnVyrobekVoz setImage:[vozIcons objectForKey:btnVyrobekVoz.titleLabel.text] forState:UIControlStateNormal];
    
    ((tbcBarController*)self.tabBarController).reloadData = YES;
    [[DMSetting sharedDMSetting] reloadScenare];
    [self changedValue];
    [[DMSetting sharedDMSetting] reloadSiluets];
    txtScenar.text = [[[DMSetting sharedDMSetting] getActualScenarData] objectForKey:@"TEXT"];
    [[DMSetting sharedDMSetting].baners reloadData];
    [self loadPovinPole];
    ROOTNAVIGATOR.vozCaption = NSLocalizedString(@"Vozidlo nevybrano", @"navig title");
    self.lblNavBar.text = ROOTNAVIGATOR.vozCaption;
    
    [[DMSetting sharedDMSetting].baners reloadData];
    vcNabidky *vcNab = (vcNabidky *)[[self.tabBarController viewControllers].lastObject viewControllers].lastObject;
    [vcNab refresTableData];
}

- (void)handleSwipeLeft:(UISwipeGestureRecognizer *)recognizer{

}

- (void)handleSwipeRight:(UISwipeGestureRecognizer *)recognizer{

}

- (void) loadPovinPole
{
    NSInteger i = 0;
    for(NSDictionary *d in [DMSetting sharedDMSetting].celky)
        i = i + [[d valueForKey:@"MANDATORY"] integerValue];
    NSDictionary *scenar = [[DMSetting sharedDMSetting] getActualScenarData];
    i = i + [[scenar valueForKey:@"OBLIG_EQUIPMENT_MANDAT"] integerValue]
        + [[scenar valueForKey:@"EQUIPMENT_MANDAT"] integerValue]
        + [[scenar valueForKey:@"SERVICES_MANDAT"] integerValue];

    if(i) {
        if(existInDic([DMSetting sharedDMSetting].vozidlo, @"CHECKIN_ID") && [[[DMSetting sharedDMSetting].vozidlo valueForKey:@"CHECKIN_ID"] integerValue] > 0) {
            [[self.tabBarController.viewControllers objectAtIndex:2] tabBarItem].badgeValue = nil;
            ((vcBase*)[[self.tabBarController.viewControllers objectAtIndex:2] viewControllers].lastObject).enableSave = YES;
        } else {
            [[self.tabBarController.viewControllers objectAtIndex:2] tabBarItem].badgeValue = [NSString stringWithFormat:@"0/%d", i];
            ((vcBase*)[[self.tabBarController.viewControllers objectAtIndex:2] viewControllers].lastObject).enableSave = NO;
        }
    }
    else {
        [[self.tabBarController.viewControllers objectAtIndex:2] tabBarItem].badgeValue = nil;
        ((vcBase*)[[self.tabBarController.viewControllers objectAtIndex:2] viewControllers].lastObject).enableSave = YES;
    }
}

#pragma mark - view object handlers
- (IBAction)scStavNadrzeDidChanget:(UISegmentedControl*)_scStavNadrze
{
    NSNumber *n = [NSNumber numberWithInt:_scStavNadrze.selectedSegmentIndex];
    [[DMSetting sharedDMSetting].vozidlo setValue:n forKey:@"FUEL_LEVEL"];
    [self changedValue];
}

-(IBAction)scStavInterieruDidChanget:(UISegmentedControl*)_scStavInterieru;
{
    NSNumber *n = [NSNumber numberWithInt:_scStavInterieru.selectedSegmentIndex+1];
    [[DMSetting sharedDMSetting].vozidlo setValue:n forKey:@"INTERIOR_STATE"];
    [self changedValue];
}

-(IBAction)chkServisKniz_prpDidChanget:(UISwitch*)_chkServisKniz_prp;
{
    NSNumber *n = [NSNumber numberWithBool:_chkServisKniz_prp.isOn];
    [[DMSetting sharedDMSetting].vozidlo setValue:n forKey:@"SERVBOOK_EXISTS"];
    [self changedValue];
}
- (IBAction)chkOtpDidChanget:(id)sender {
    NSNumber *n = [NSNumber numberWithBool:chkOTP_prp.isOn];
    [[DMSetting sharedDMSetting].vozidlo setValue:n forKey:@"CRW_EXISTS"];
    [self changedValue];
}
- (IBAction)chkPoistPripChandet:(id)sender {
    NSNumber *n = [NSNumber numberWithBool:chkPoistPrip_prp.isOn];
    [[DMSetting sharedDMSetting].vozidlo setValue:n forKey:@"INSURANCE_CASE"];
    [self changedValue];
}
- (IBAction)scStavOlejeChaged:(id)sender {
    NSNumber *n = [NSNumber numberWithInt:scStavOleje.selectedSegmentIndex];
    [[DMSetting sharedDMSetting].vozidlo setValue:n forKey:@"OIL_LEVEL"];
    [self changedValue];
}

- (IBAction)txtKMEditDidEnd:(id)sender
{
    if([[txtKmStav text] length])
    {
        NSNumber *num = [TRABANT_APP_DELEGATE.numFormat numberFromString:[txtKmStav.text stringByReplacingOccurrencesOfString:@" " withString:@""]];
        txtKmStav.text = [TRABANT_APP_DELEGATE.numFormat stringFromNumber:num];
        [[DMSetting sharedDMSetting].vozidlo setValue:[num stringValue] forKey:@"ODOMETER"];
        [self changedValue];
    }
    else
    {
        NSNumber *num = [[DMSetting sharedDMSetting].vozidlo objectForKey:@"ODOMETER"];
        txtKmStav.text = [TRABANT_APP_DELEGATE.numFormat stringFromNumber:num];
    }
}

- (IBAction)txtVINDidChanget:(id)sender
{
    NSError *error = NULL;
    if(![txtVIN.text isEqualToString:txtVIN.text.uppercaseString])
        txtVIN.text = txtVIN.text.uppercaseString;
    
    NSMutableString *data = [txtVIN.text stringByReplacingOccurrencesOfString:@" " withString:@""].mutableCopy;
    
    if(data.length > 17)
        data = [data substringToIndex:17].mutableCopy;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:VINREGULAR//@"^([A-Z0-9]{3})([A-Z0-9]{0,3})([A-Z0-9]{0,2})([A-Z0-9]{0,3})([A-Z0-9]{0,6})(\\w*)"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:data
                                                               options:0
                                                                 range:NSMakeRange(0, data.length)
                                                          withTemplate:@"$1 $2 $3 $4 $5"];
    
    modifiedString = [modifiedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(![txtVIN.text isEqualToString:modifiedString])
        txtVIN.text = modifiedString;
}

- (IBAction)txtVINDidEndEditing:(id)sender
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:VINREGULAR
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSInteger matches = [regex numberOfMatchesInString:txtVIN.text options:0 range:NSMakeRange(0, txtVIN.text.length)];
    
    NSString *theVin = [txtVIN.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if(matches != 1)
    {
        NSLog(@"nespravny VIN, %d", matches);
        return;
    }
    else if([theVin isEqualToString:[[DMSetting sharedDMSetting].vozidlo valueForKey:@"VIN"]])
        return;
    else
        [[DMSetting sharedDMSetting].vozidlo setValue:theVin forKey:@"VIN"];
    
    [self changedValue];
    [[DMSetting sharedDMSetting].vozidlo setValue:[NSNull null] forKey:@"VEHICLE_ID"];
    
    if(txtRZV.text.length)
        return;
    
    NSString *vin;
    vin = txtVIN.text;
    [self clearAllData:self.view];
    [self EnabledAllComponents:NO];
    txtVIN.text = vin;
    [[WSDCHIDataTransfer sharedWSDCHIDataTransfer] startGetCarDataWithVozidloId:-1 checkIn_id:-1 oZakazkaId:-1 rzv:@"" vin:[vin stringByReplacingOccurrencesOfString:@" " withString:@""]];
//    [[WSCommunications sharedWSCommunications].wsLoadCarManufactureData startGetCarDataWithVozidloId:-1 checkIn_id:-1 oZakazkaId:-1 rzv:@"" vin:[vin stringByReplacingOccurrencesOfString:@" " withString:@""]];
    
}

- (IBAction) txtZakaznikDidEndEditing:(id)sender
{
    if(![[[DMSetting sharedDMSetting].vozidlo valueForKey:@"CUSTOMER_LABEL"] isEqualToString:txtZakaznik.text])
    {
        [[DMSetting sharedDMSetting].vozidlo removeObjectForKey:@"CUSTOMER_ID"];
        [DMSetting sharedDMSetting].zakaznikInfo = nil;
    }
    
    [[DMSetting sharedDMSetting].vozidlo setValue:txtZakaznik.text forKey:@"CUSTOMER_LABEL"];
    
    [self changedValue];
}

- (IBAction) txtVozPristavilDidEndEditing:(UITextField *)_txtVozPristavil
{
    [[DMSetting sharedDMSetting].vozidlo setValue:[txtVozPristavil.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"DRIVER_NAME_SURN"];
    [self changedValue];
}

- (IBAction)txtMouthDateDidEndEditing:(id)sender
{
    [self setMouthDate:sender];
}

#pragma mark - web service message magnaging

-(void)naplnPropertky
{
    
    NSDictionary *mvoz = [DMSetting sharedDMSetting].vozidlo;
    NSDictionary *zak = [DMSetting sharedDMSetting].zakaznik;
    NSMutableString *tmpStr = [[NSMutableString alloc] init];

    if(existInDic(mvoz, @"LICENSE_TAG"))
        [txtRZV setText:[mvoz valueForKey:@"LICENSE_TAG"]];
    
    [mvoz setValue:[[DMSetting sharedDMSetting].loggedUser objectForKey:@"PERSONAL_ID"] forKey:@"PERSONAL_ID"];

    if(!existInDic(mvoz, @"EXTERIOR_STATE"))
        [mvoz setValue:@2 forKey:@"EXTERIOR_STATE"];
    
    if(!existInDic(mvoz, @"INTERIOR_STATE"))
        [mvoz setValue:@1 forKey:@"INTERIOR_STATE"];
    else
        scStavInterieru.selectedSegmentIndex = [[mvoz objectForKey:@"INTERIOR_STATE"] integerValue]-1;
    
    NSNumber *n = [mvoz objectForKey:@"ODOMETER"];
    bool loadKM = [[[[DMSetting sharedDMSetting] setting] valueForKey:@"SHOW_DEF_ODOMETER"] boolValue];
    if(loadKM && existInDic(mvoz, @"ODOMETER"))
        txtKmStav.text = [TRABANT_APP_DELEGATE.numFormat stringFromNumber:n];
    
    if(existInDic(zak, @"CUSTOMER_LABEL"))
        [tmpStr setString:[zak valueForKey:@"CUSTOMER_LABEL"]];
    else if(existInDic(mvoz, @"CUSTOMER_LABEL"))
        [tmpStr setString:[mvoz valueForKey:@"CUSTOMER_LABEL"]];

    if(tmpStr.length)
        txtZakaznik.text = [tmpStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(existInDic(mvoz, @"DRIVER_NAME_SURN"))
        [txtVozPristavil setText: [mvoz valueForKey:@"DRIVER_NAME_SURN"]];
    
    if(existInDic(mvoz, @"FUEL_ID"))
    {
        n = [mvoz valueForKey:@"FUEL_ID"];
        NSInteger palivo_pzn = n.integerValue;
        btnPalivo.tag = palivo_pzn;
        txtPalivoDruh = [[DMSetting sharedDMSetting].palivoArray[((palivo_pzn>0)?palivo_pzn-1:0)] valueForKey:@"TEXT"];
    } else {
        btnPalivo.tag = 0;
        [mvoz setValue:@0 forKey:@"FUEL_ID"];
    }
    
    if(existInDic(mvoz, @"CHECKIN_ID"))
    {
        n = [mvoz valueForKey:@"CHECKIN_ID"];
        [TRABANT_APP_DELEGATE setChecking_id:n.integerValue];
    }
    if(existInDic(mvoz, @"OIL_LEVEL"))
    {
        n = [mvoz valueForKey:@"OIL_LEVEL"];
        scStavOleje.selectedSegmentIndex = n.intValue;
    } else {
        scStavOleje.selectedSegmentIndex = 1;
        [mvoz setValue:@1 forKey:@"OIL_LEVEL"];
    }
    
    if(existInDic(mvoz, @"INSURANCE_CASE"))
        [chkPoistPrip_prp setOn:([mvoz valueForKey:@"INSURANCE_CASE"])?YES:NO];
    if(existInDic(mvoz, @"FUEL_LEVEL"))
        [scStavNadrze setSelectedSegmentIndex:[[mvoz valueForKey:@"FUEL_LEVEL"] integerValue]];

    if(existInDic(mvoz, @"BRAND_ID"))
    {
        btnVyrobekVoz.enabled = NO;
        [btnVyrobekVoz setTitle:[mvoz valueForKey:@"BRAND_ID"] forState:UIControlStateNormal];
        [btnVyrobekVoz setImage:[vozIcons objectForKey:btnVyrobekVoz.titleLabel.text] forState:UIControlStateNormal];
    }
    else
    {
        btnVyrobekVoz.enabled = YES;
        [btnVyrobekVoz setTitle:@"F" forState:UIControlStateNormal];
        [mvoz setValue:@"F" forKey:@"BRAND_ID"];
        [btnVyrobekVoz setImage:[vozIcons objectForKey:btnVyrobekVoz.titleLabel.text] forState:UIControlStateNormal];
    }
    
//    if(existInDic(mvoz, @"CHECKIN_NUMBER") && [[mvoz valueForKey:@"CHECKIN_NUMBER"] integerValue]>0)
//        lblCheckinNr.text = [[mvoz valueForKey:@"CHECKIN_NUMBER"] stringValue];
//    else
//        lblCheckinNr.text = @"";
    
    if(existInDic(mvoz, @"CHECKIN_NUMBER") && [[mvoz valueForKey:@"CHECKIN_NUMBER"] integerValue] > 0)
    {
        lblCheckinNr.textColor = [UIColor lightGrayColor];
        lblCheckinNr.text = [[mvoz valueForKey:@"CHECKIN_NUMBER"] stringValue];
    }
    else if(existInDic(mvoz, @"PLANNED_ORDER_ID"))
    {
        lblCheckinNr.textColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.9 alpha:0.5];//[UIColor blueColor];
        lblCheckinNr.text = [mvoz objectForKey:@"PLANNED_ORDER_NO"];
    }
    else
        lblCheckinNr.text = @"";
    
    if(existInDic(mvoz, @"CRW_EXISTS"))
        [chkOTP_prp setOn:([[mvoz valueForKey:@"CRW_EXISTS"] integerValue] == 1)?YES:NO];//DCHI
    else
        [mvoz setValue:[NSNumber numberWithBool:chkOTP_prp.isOn ] forKey:@"CRW_EXISTS"];
        
    if(existInDic(mvoz, @"INSURANCE_CASE"))
        chkPoistPrip_prp.on = [[mvoz valueForKey:@"INSURANCE_CASE"] boolValue];
    else
        [mvoz setValue:[NSNumber numberWithBool:chkPoistPrip_prp.isOn ] forKey:@"INSURANCE_CASE"];
    
    if(existInDic(mvoz, @"SERVBOOK_EXISTS"))
        chkServisKniz_prp.on = [[mvoz valueForKey:@"SERVBOOK_EXISTS"] boolValue];
    else
        [mvoz setValue:[NSNumber numberWithBool:chkServisKniz_prp.isOn ] forKey:@"SERVBOOK_EXISTS"];
    
    [[DMSetting sharedDMSetting] reloadScenare];
    
    NSString *data = [mvoz valueForKey:@"VIN"];
    
    if(existInDic(mvoz, @"VIN") && data.length)
    {
        NSError *error;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:VINREGULAR
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        NSString *modifiedString = [regex stringByReplacingMatchesInString:data
                                                                   options:0
                                                                     range:NSMakeRange(0, data.length)
                                                              withTemplate:@"$1 $2 $3 $4 $5"];
        txtVIN.text = modifiedString;
        txtVIN.enabled = NO;
    }
    else
    {
        txtVIN.text = @"";
        txtVIN.enabled = YES;
    }
    
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss"];
    NSDate *date, *emiseDate, *STKDate;
    if(existInDic(mvoz, @"LICENSE_DATE"))
        date = [dateFormatter dateFromString:[mvoz objectForKey:@"LICENSE_DATE"]];
    if(existInDic(mvoz, @"EC_VALID_UNTIL"))
        emiseDate = [dateFormatter dateFromString:[mvoz objectForKey:@"EC_VALID_UNTIL"]];
    if(existInDic(mvoz, @"TI_VALID_UNTIL"))
        STKDate = [dateFormatter dateFromString:[mvoz objectForKey:@"TI_VALID_UNTIL"]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];

    [tmpStr setString:@""];
    if(date != nil && existInDic(mvoz, @"MY"))
        [tmpStr appendFormat:@"%@ / %@", [dateFormatter stringFromDate:date], [mvoz valueForKey:@"MY"] ];
    else if(date != nil)
        [tmpStr setString:[dateFormatter stringFromDate:date]];
    else if(existInDic(mvoz, @"MY"))
        [tmpStr setString:[mvoz valueForKey:@"MY"] ];
    
    txtProdej_dat.text = tmpStr;
    
    [dateFormatter setDateFormat:@"MM.yyyy"];
    if(STKDate != nil && [[[DMSetting sharedDMSetting].setting valueForKey:@"SHOW_DEF_TI_VALID_UNTIL"] boolValue])
        txtSTK.text = [dateFormatter stringFromDate:STKDate];
    if(emiseDate != nil && [[[DMSetting sharedDMSetting].setting valueForKey:@"SHOW_DEF_EC_VALID_UNTIL"] boolValue])
        txtEmise.text = [dateFormatter stringFromDate:emiseDate];
    
    ((tbcBarController*)self.tabBarController).reloadData = YES;
//    [[DMSetting sharedDMSetting] setAllValuesTo:NO];

    btnPZ.enabled = !([DMSetting sharedDMSetting].PZ == nil || [DMSetting sharedDMSetting].PZ.count == 0);
    btnSDA.enabled = !([DMSetting sharedDMSetting].SDA == nil || [DMSetting sharedDMSetting].SDA.count == 0);
    btnOdlozPoloz.enabled = !([DMSetting sharedDMSetting].odlozPoloz == nil || [DMSetting sharedDMSetting].odlozPoloz.count == 0);
    
    [[DMSetting sharedDMSetting] reloadSiluets];
    
    if(existInDic(mvoz, @"CHECK_SCENARIO_ID"))
    {
        NSInteger scenarId = [[mvoz valueForKey:@"CHECK_SCENARIO_ID"] integerValue]; //DCHI
        NSArray *a = [[DMSetting sharedDMSetting].scenar filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"CHECK_SCENARIO_ID.intValue == %d ", scenarId]];
        txtScenar.text = [a.lastObject objectForKey:@"TEXT"];
    }
    else
    {
        //reloadScenare
        txtScenar.text = [[[DMSetting sharedDMSetting] getActualScenarData] objectForKey:@"TEXT"];
//        [mvoz setValue:[NSNumber numberWithInt:btnScenar.tag] forKey:@"CHECK_SCENARIO_ID"];
    }

    
    [[DMSetting sharedDMSetting].baners reloadData];
    vcNabidky *vcNab = (vcNabidky *)[[self.tabBarController viewControllers].lastObject viewControllers].lastObject;
    [vcNab refresTableData];
    [DMSetting sharedDMSetting].isLoadingCheckinData = NO;
    [self changedValue];
}

@end