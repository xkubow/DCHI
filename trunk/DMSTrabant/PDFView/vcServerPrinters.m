//
//  vcServerPrinters.m
//  DirectCheckin
//
//  Created by Jan Kubis on 12.12.12.
//
//

#import "vcServerPrinters.h"
#import "DMSetting.h"
#import "WSProtocolRequest.h"
#include "WSDCHIDataTransfer.h"

@interface vcServerPrinters ()<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView *tvPrinters;
    IBOutlet UIButton *btnPrint;
    UIView *footerView;
}
@end

@implementation vcServerPrinters

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
//    footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 170, 300, 70)];
//    footerView.backgroundColor = [UIColor greenColor];
//    tvPrinters.tableFooterView = footerView;
//    btnPrint = [UIButton buttonWithType:UIButtonTypeRoundedRect];//[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
//    btnPrint.frame = CGRectMake(10, 30, 280, 44);
//    [btnPrint setTitle:NSLocalizedString(@"Print", nil) forState:UIControlStateNormal];
//    [btnPrint addTarget:self action:@selector(print:) forControlEvents:UIControlEventTouchDown];
//    btnPrint.titleLabel.font = [UIFont fontWithName:@"Verdana-Bold" size:17];
//    [btnPrint setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [footerView addSubview:btnPrint];
//    [self.view addSubview:footerView];
    [tvPrinters setBackgroundColor:[UIColor clearColor]];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"pozadie_ciste.png"]]];
    [btnPrint setTitle:NSLocalizedString(@"Print", nil) forState:UIControlStateNormal];
    

	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
//    CGRect f = btnPrint.frame;
//    btnPrint.frame = CGRectMake(f.origin.x, self.view.frame.size.height - 80, f.size.width, f.size.height);
//    f = tvPrinters.frame;
//    tvPrinters.frame = CGRectMake(10, 30, f.size.width, self.view.frame.size.height-100);
    
    [super viewWillAppear:animated];
    [tvPrinters selectRowAtIndexPath:[NSIndexPath indexPathForItem:[DMSetting sharedDMSetting].defaultPrinterIdx inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
}

-(void)viewDidUnload
{
    tvPrinters = nil;
    [super viewDidUnload];
}



#pragma mark -
#pragma mark Table controls
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if(section == 0)
        return [DMSetting sharedDMSetting].printers.count;
    else
        return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 30;
//}

//- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (1 == indexPath.section){
//        return nil;
//    }
//    return indexPath;
//}


//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 0;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//
////    if(footerView == nil)
////    {
////        footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 100)];
////        btnPrint = [UIButton buttonWithType:UIButtonTypeRoundedRect];//[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
////        btnPrint.frame = CGRectMake(10, 30, 280, 44);
////        [btnPrint setTitle:NSLocalizedString(@"Print", nil) forState:UIControlStateNormal];   
////        [btnPrint addTarget:self action:@selector(print:) forControlEvents:UIControlEventTouchDown];
////        btnPrint.titleLabel.font = [UIFont fontWithName:@"Verdana-Bold" size:17];
////        [btnPrint setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
////        [footerView addSubview:btnPrint];
////    }
//    
//    return nil;//[[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 70)];
//}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    btnPrint.enabled = YES;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    BOOL bCaption = (indexPath.row == 0);
    
	NSString *MyIdentifier = @"MyId";//[NSString stringWithFormat:@"MyIdentifier %i", indexPath.row];
    
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor colorWithRed:(76.0/255.0) green:(161.0/255.0) blue:(255.0/255.0) alpha:1.0]; // perfect color suggested by @mohamadHafez
        bgColorView.layer.masksToBounds = YES;
        cell.selectedBackgroundView = bgColorView;
	}
    
    if(indexPath.section == 0)
        cell.textLabel.text = [DMSetting sharedDMSetting].printers[indexPath.row];
    
	return cell;
}

-(IBAction) print:(id)sender
{
    btnPrint.enabled = NO;
    [[WSDCHIDataTransfer sharedWSDCHIDataTransfer] startPrintReportWithPrinterName:[DMSetting sharedDMSetting].printers[tvPrinters.indexPathForSelectedRow.row]];
//    [[WSCommunications sharedWSCommunications].wsLoadCarManufactureData startPrintReportWithPrinterName:[DMSetting sharedDMSetting].printers[tvPrinters.indexPathForSelectedRow.row]];
    [tvPrinters deselectRowAtIndexPath:[tvPrinters indexPathForSelectedRow] animated:YES];
}


@end
