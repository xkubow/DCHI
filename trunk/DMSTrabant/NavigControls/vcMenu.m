//
//  vcMenu.m
//  Direct checkin
//
//  Created by Jan Kubis on 09.10.12.
//  Copyright (c) 2012 jan.kubis@t-systems.cz. All rights reserved.
//
#import <objc/runtime.h>
#import "vcMenu.h"
#import "TrabantAppDelegate.h"
#import "DMSetting.h"
#import "vcVozHistory.h"
#import "vcShowInfo.h"
#import "tbcBarController.h"
#import "vcBase.h"
#import "VCBaseGrid.h"
#import "DejalActivityView.h"
#import "vcTrabantInfo.h"
#import "vcNabidky.h"
#import "WSDCHIDataTransfer.h"

#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])
#define ROOTNAVIGATOR ([TRABANT_APP_DELEGATE rootNavController])

@interface vcMenu()
{
    BOOL showDocument;
    UIAlertView *alert;
}
- (void)showVozHistory;
- (void)showShortVozHistory;
- (void) showVozidloInfo;
- (void) showZakaznikInfo;
- (void) showPDFDocument;
- (void) saveCheckin;
@end

@implementation vcMenu
@synthesize menu;


- (id)initAndShowInView:(id)Sender
{
    if ( (self = [super init] ) )
    {
        rootTBC = ROOTNAVIGATOR.viewControllers.lastObject;
        menu = [[UIActionSheet alloc] initWithTitle:nil
                                           delegate:self  
                                  cancelButtonTitle:nil  
                             destructiveButtonTitle:NSLocalizedString(@"Novy Checkin", nil)
                                  otherButtonTitles:
                NSLocalizedString(@"Odesli data", nil),
                NSLocalizedString(@"Stručná historie", nil),
                NSLocalizedString(@"Historie", nil),
                NSLocalizedString(@"Informácie o vozidle", nil),
                NSLocalizedString(@"Informácie o zakazníkovi", nil),
                NSLocalizedString(@"Document", nil), nil];
        [menu showFromBarButtonItem:Sender animated:YES];
        
        
        id obj = rootTBC.selectedViewController;
        while (![obj isKindOfClass:[vcBase class]] && class_getProperty([obj class], "viewControllers") != NULL)
            obj = [obj viewControllers].lastObject;
        if([obj isKindOfClass:[vcBase class]])
            viewControlerBase = (vcBase *)obj;
        else
            viewControlerBase = nil;
        
        showDocument = NO;
    }
    
    return self;
}

- (void) setStatusOdeslani:(BOOL)saved
{
    for(UINavigationController *nc in rootTBC.viewControllers)
    {
        vcBase *vcb = nc.viewControllers.lastObject;
        [vcb setStatusOdeslani: YES];
    }
}

- (BOOL) checkPovinne
{
    BOOL enableSave = YES;
    for(id vb in rootTBC.viewControllers)
    {
        if(!((vcBase *)[vb viewControllers].lastObject).enableSave)
        {
            NSLog(@"%@", ((vcBase *)[vb viewControllers].lastObject).nibName);
            enableSave = NO;
        }
        if(![vb isViewLoaded])
            enableSave = NO;
    }
    if(!enableSave)
    { 
        alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"Pozadovane data nevyplnena",@"chyba hlaska")
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.tag = 1;
        [alert show];
    }
    
    return enableSave;
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{

    switch (buttonIndex) {
        case 0:
            alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"Chcete novy checkin",@"chyba hlaska")
                                       delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"chyba hlaska") otherButtonTitles:NSLocalizedString(@"OK",@"chyba hlaska"), nil];
            alert.tag = 0;
            [alert show];
            break;
        case 1:
            [self saveCheckin];
            [DMSetting sharedDMSetting].showProtocol = NO;
            break;
        case 2:
            [self showShortVozHistory];
            break;
        case 3:
            [self showVozHistory];
            break;
        case 4:
            [self showVozidloInfo];
            break;
        case 5:
            [self showZakaznikInfo];
            break;
        case 6:
            if(!viewControlerBase.statusOdeslani)
            {
                [DMSetting sharedDMSetting].showProtocol = YES;
                [self saveCheckin];
            }
            else
                [self showPDFDocument];
            break;
            
        default:
            break;
    }
}

- (void)dealloc {
    menu = nil;
    rootTBC = nil;
    viewControlerBase = nil;
    insertResultMessage = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


#pragma mark - Show modal vindows

- (void) novyCheckin
{
    
}

- (void) showPDFDocument
{
    [viewControlerBase EnabledAllComponents:NO];
    [[WSDCHIDataTransfer sharedWSDCHIDataTransfer] startDCHIReportImage];
//    [[WSCommunications sharedWSCommunications].wsLoadCarManufactureData startDCHIReport];
}

- (void)showVozHistory 
{
    UINavigationController *nc = (UINavigationController*)ROOTNAVIGATOR;

    vcVozHistory *vh = [[vcVozHistory alloc] initWithFrame:CGRectMake(0, 0, 1000, 680)];
    Column *c = [vh addColumnWithSize:CGSizeMake(150, 30) textAlign:NSTextAlignmentRight];
    c.dictEnum = @"HISTORY_TYPE_TXT";
    c.caption = NSLocalizedString(@"Typ", nil);
    
    c = [vh addColumnWithSize:CGSizeMake(700, 30) textAlign:NSTextAlignmentLeft];
    c.dictEnum = @"HISTORY_DESCRIPTION";
    c.caption = NSLocalizedString(@"Popis", nil);
    
    c = [vh addColumnWithSize:CGSizeMake(100, 30) textAlign:NSTextAlignmentLeft];
    c.dictEnum = @"ITEM_NO";
    c.caption = NSLocalizedString(@"PP/ND", nil);
    
    c = [vh addColumnWithSize:CGSizeMake(50, 30) textAlign:NSTextAlignmentLeft];
    c.dictEnum = @"PERSONAL_TAG";
    c.caption = NSLocalizedString(@"Os.č.", nil);
    
    vh.viewTitle = NSLocalizedString(@"HistorieVozu", @"UI strings");
    vh.gridData = [DMSetting sharedDMSetting].vozHistory;
    vh.columnsCaptionsHeight = 30;
    vh.gridType = eGRDVOZHISTORY;
    vh.cellSelectionStyle = UITableViewCellSelectionStyleNone;
    
    [vh setModalPresentationStyle:UIModalPresentationFormSheet];
    UINavigationController *ncPicker = [[UINavigationController alloc] initWithRootViewController:vh];
    ncPicker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [ncPicker setModalPresentationStyle:UIModalPresentationFormSheet];
    [nc presentViewController:ncPicker animated:YES completion:nil];
    ncPicker.preferredContentSize = CGSizeMake(1000, 680);
    ncPicker.view.superview.center = rootTBC.view.superview.center;
}

- (void)showShortVozHistory
{   
    NSArray *data = [[DMSetting sharedDMSetting].vozHistory filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"BRIEF_HISTORY.intValue == 1"]];
    
    UINavigationController *nc = rootTBC.selectedViewController.navigationController;
    
    vcVozHistory *vh = [[vcVozHistory alloc] initWithFrame:CGRectMake(0, 0, 1000, 680)];
    Column *c = [vh addColumnWithSize:CGSizeMake(150, 30) textAlign:NSTextAlignmentRight];
    c.dictEnum = @"HISTORY_TYPE_TXT";
    c.caption = NSLocalizedString(@"Typ", nil);
    
    c = [vh addColumnWithSize:CGSizeMake(700, 30) textAlign:NSTextAlignmentLeft];
    c.dictEnum = @"HISTORY_DESCRIPTION";
    c.caption = NSLocalizedString(@"Popis", nil);
    
    c = [vh addColumnWithSize:CGSizeMake(100, 30) textAlign:NSTextAlignmentLeft];
    c.dictEnum = @"ITEM_NO";
    c.caption = NSLocalizedString(@"PP/ND", nil);
    
    c = [vh addColumnWithSize:CGSizeMake(50, 30) textAlign:NSTextAlignmentLeft];
    c.dictEnum = @"PERSONAL_TAG";
    c.caption = NSLocalizedString(@"Os.č.", nil);
    
    vh.viewTitle = NSLocalizedString(@"HistorieVozu", @"UI strings");
    vh.gridData = data;
    vh.columnsCaptionsHeight = 30;
    vh.gridType = eGRDVOZHISTORY;
    vh.cellSelectionStyle = UITableViewCellSelectionStyleNone;
    
    [vh setModalPresentationStyle:UIModalPresentationFormSheet];
    UINavigationController *ncPicker = [[UINavigationController alloc] initWithRootViewController:vh];
    ncPicker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [ncPicker setModalPresentationStyle:UIModalPresentationFormSheet];
    [nc presentViewController:ncPicker animated:YES completion:nil];
    ncPicker.preferredContentSize = CGSizeMake(1000, 680);
    ncPicker.view.superview.center = rootTBC.view.superview.center;
    
}

- (void) showVozidloInfo
{
    UINavigationController *nc = rootTBC.selectedViewController.navigationController;

    VCBaseGrid *vh = [[VCBaseGrid alloc] initWithFrame:CGRectMake(0, 0, 600, 680)];
    Column *c = [vh addColumnWithSize:CGSizeMake(200, 30) textAlign:NSTextAlignmentRight];
    c.font = [UIFont fontWithName:@"Helvetica Bold" size:12];
    c.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];
    c.dictEnum = @"DESCRIPTION";
    c.caption = NSLocalizedString(@"Typ", nil);
    c = [vh addColumnWithSize:CGSizeMake(400, 30) textAlign:NSTextAlignmentLeft];
    c.font = [UIFont fontWithName:@"Helvetica" size:17];
    c.dictEnum = @"VALUE";
    c.caption = NSLocalizedString(@"Popis", nil);
    
    vh.viewTitle = NSLocalizedString(@"Informácie o vozidle", nil);
    vh.gridData = [DMSetting sharedDMSetting].vozInfo;
    vh.columnsCaptionsHeight = 30;
    vh.gridType = eGRDVOZINFO;
    vh.cellSelectionStyle = UITableViewCellSelectionStyleNone;    
    
    [vh setModalPresentationStyle:UIModalPresentationFormSheet];
    UINavigationController *ncPicker = [[UINavigationController alloc] initWithRootViewController:vh];
    ncPicker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [ncPicker setModalPresentationStyle:UIModalPresentationFormSheet];
    [nc presentViewController:ncPicker animated:YES completion:nil];
    ncPicker.preferredContentSize = CGSizeMake(600, 680);
    ncPicker.view.superview.center = rootTBC.view.superview.center;
}

- (void) showZakaznikInfo
{
    UINavigationController *nc = rootTBC.selectedViewController.navigationController;
    
    VCBaseGrid *vh = [[VCBaseGrid alloc] initWithFrame:CGRectMake(0, 0, 600, 680)];
    Column *c = [vh addColumnWithSize:CGSizeMake(200, 30) textAlign:NSTextAlignmentRight];
    c.font = [UIFont fontWithName:@"Helvetica Bold" size:12];
    c.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];
    c.dictEnum = @"DESCRIPTION";
    c.caption = NSLocalizedString(@"Typ", nil);
    c = [vh addColumnWithSize:CGSizeMake(400, 30) textAlign:NSTextAlignmentLeft];
    c.font = [UIFont fontWithName:@"Helvetica" size:17];
    c.dictEnum = @"VALUE";
    c.caption = NSLocalizedString(@"Popis", nil);
    
    vh.viewTitle = NSLocalizedString(@"Informácie o zakazníkovi", nil);
    vh.gridData = [DMSetting sharedDMSetting].zakaznikInfo;
    vh.columnsCaptionsHeight = 30;
    vh.gridType = eGRDZAKINFO;
    vh.cellSelectionStyle = UITableViewCellSelectionStyleNone;
    
    [vh setModalPresentationStyle:UIModalPresentationFormSheet];
    UINavigationController *ncPicker = [[UINavigationController alloc] initWithRootViewController:vh];
    ncPicker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [ncPicker setModalPresentationStyle:UIModalPresentationFormSheet];
    [nc presentViewController:ncPicker animated:YES completion:nil];
    ncPicker.preferredContentSize = CGSizeMake(600, 680);
    ncPicker.view.superview.center = rootTBC.view.superview.center;
}

#pragma mark - SOAP mesages

- (void) saveCheckin {
    
    if(![self checkPovinne])
        return;
    
    
    [DejalBezelActivityView activityViewForView:TRABANT_APP_DELEGATE.rootNavController.view withLabel:NSLocalizedString(@"Sending data", nil) width:100 progressView:YES];
    [[WSDCHIDataTransfer sharedWSDCHIDataTransfer] saveData];
//    [[WSCommunications sharedWSCommunications].wsLoadCarManufactureData saveData];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(alertView.tag)
    {
            case 0:
                if(buttonIndex == 1)
                {
                    vcTrabantInfo *vcTbi = nil;
                    rootTBC.selectedIndex = 0;
                    vcTbi = (vcTrabantInfo *)[((UINavigationController*)rootTBC.selectedViewController) viewControllers].lastObject;
                    [vcTbi clearAllData:vcTbi.view];
                    [vcTbi setDefaultData];
                    [vcTbi refreshData];
                    vcNabidky *vcNab = (vcNabidky *)[((UINavigationController*)rootTBC.viewControllers.lastObject) viewControllers].lastObject;
                    [vcNab refresTableData];
                }
            break;
            default:
            break;
    }
        
    
}


@end
