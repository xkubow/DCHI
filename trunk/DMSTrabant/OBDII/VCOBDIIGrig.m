//
//  vcOBDIIGrigViewController.m
//  DirectCheckin
//
//  Created by Jan Kubis on 23.05.13.
//
//

#import "VCOBDIIGrig.h"
#import "WSDCHIDataTransfer.h"
#import "DejalActivityView.h"
#import "TrabantAppDelegate.h"

#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])

@interface VCOBDIIGrig ()
{
    NSString *vin;
}

@end

@implementation VCOBDIIGrig

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) loadNavBar
{
    [super loadNavBar];
    
    UIImage *imgButton = [[UIImage imageNamed:@"tlacitko"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16)];
    UIBarButtonItem *btnGetData = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Prevzi data", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(loadVoz:)];
    [btnGetData setBackgroundImage:imgButton forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [btnGetData setBackgroundImage:imgButton forState:UIControlStateDisabled barMetrics:UIBarMetricsDefault];

    [self.navigationItem setRightBarButtonItem:btnGetData animated:NO];
}


/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSDictionary *d = self.gridData[indexPath.row];
    NSLog(@"%@", d);
    
    NSString *type = [d valueForKey:@"TYPE"];
    NSString *respons = [d valueForKey:@"RESPONSE"];
    if(([type isEqualToString:@"STOREDDTC"]
       || [type isEqualToString:@"PENDINGDTC"]
       || [type isEqualToString:@"PERMANENTDTC"])
       && respons.length)
    {
        NSInteger count = [respons componentsSeparatedByString:@","].count;
        return count*[self gridRowHeight];
    }
    else
        return [self gridRowHeight];
}

- (void)addExtraViewsToCell:(UITableViewCell*)cell rowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *d = self.gridData[indexPath.row];
    NSLog(@"%@", d);
    
    NSString *type = [d valueForKey:@"TYPE"];
    if([type isEqualToString:@"VIN"])
    {
        vin = [d valueForKey:@"RESPONSE"];
        UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(240, 0, 60, 44)];
        [b setTitle:@"Load vehicle" forState:UIControlStateNormal];
        [b setBackgroundColor:[UIColor greenColor]];
        [b addTarget:self action:@selector(loadVoz:) forControlEvents:UIControlEventTouchUpInside];
    }
}
*/

- (IBAction)loadVoz:(id)sender
{
    [[self navigationController] dismissViewControllerAnimated:YES completion:^{
        [DejalBezelActivityView activityViewForView:TRABANT_APP_DELEGATE.rootNavController.view];
        [[WSDCHIDataTransfer sharedWSDCHIDataTransfer] startGetCarDataWithVozidloId:-1 checkIn_id:-1 oZakazkaId:-1 rzv:@"" vin:vin];
        
    }];
}

@end
