//
//  VCVozVyberViewController.m
//  DirectCheckin
//
//  Created by Jan Kubis on 22.01.13.
//
//

#import "VCVozVyber.h"
#import "TrabantAppDelegate.h"
#import "DMSetting.h"
#import "DejalActivityView.h"
#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])

@interface VCVozVyber ()
{
    NSArray *filteredDataHis, *filteredDataOthers;
}

@end

@implementation VCVozVyber
@synthesize selectedData=_selectedData;

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
    filteredDataHis = [[NSArray alloc] init];
    filteredDataOthers = [[NSArray alloc] init];

    NSInteger parcovnik_id = [[[DMSetting sharedDMSetting].loggedUser objectForKey:@"PERSONAL_ID"] integerValue];
    filteredDataHis = [self.gridData filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"PERSONAL_ID.intValue == %d", parcovnik_id ]];
    filteredDataOthers = [self.gridData filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"PERSONAL_ID.intValue != %d", parcovnik_id ]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if([[self vozVyberDelegate] respondsToSelector:@selector(vozVyberDisaper:)])
        [[self vozVyberDelegate] vozVyberDisaper:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    filteredDataHis = nil;
    filteredDataOthers = nil;
    [super viewDidUnload];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowCount = 0;
    if(section == 0)
        rowCount = filteredDataHis.count;
    else if(section == 1)
        rowCount = filteredDataOthers.count;
    return rowCount;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
        if(section == 0 && filteredDataHis.count)
            return 22;
        else if (section == 1 && filteredDataOthers.count)
            return 22;
        else
            return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if([self gridType] != eGRDPLANZAK)
        return nil;
    if((section == 0 && filteredDataHis.count == 0) || (section == 1 && filteredDataOthers.count == 0))
        return [[UIView alloc] initWithFrame: CGRectMake(0, 0, tableView.frame.size.width, 0)];
    
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:
                                 CGRectMake(0, 0, tableView.frame.size.width, 20.0)];
    sectionHeaderView.backgroundColor = [UIColor colorWithRed:0.923 green:0.923 blue:0.925 alpha:1];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:
                            CGRectMake(5, 0, sectionHeaderView.bounds.size.width-5, sectionHeaderView.bounds.size.height)];
    
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textAlignment = NSTextAlignmentLeft ;
    [headerLabel setFont:[UIFont fontWithName:@"Verdana-Bold" size:17.0]];
//    [headerLabel setTextColor: [UIColor whiteColor]];
    [sectionHeaderView addSubview:headerLabel];
    
    if(section == 0)
        headerLabel.text = [NSString stringWithString:NSLocalizedString(@"Moje", @"UI strings")];
    else if(section == 1)
        headerLabel.text = [NSString stringWithString: NSLocalizedString(@"Ostatne", @"UI strings")];
    
    return sectionHeaderView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if([self gridType] != eGRDPLANZAK)
        return nil;
    if(section == 0 && filteredDataHis.count)
        return [NSString stringWithString:NSLocalizedString(@"Moje", @"UI strings")];
    else if(section == 1 && filteredDataOthers.count)
        return [NSString stringWithString: NSLocalizedString(@"Ostatne", @"UI strings")];
    return nil;
}

-(id)getDataWithIndexPath:(NSIndexPath*)indexPath
{
    NSDictionary *data;
    if(indexPath.section == 0)
        data =  filteredDataHis[indexPath.row];
    else if(indexPath.section == 1)
        data = filteredDataOthers[indexPath.row];

    return data;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *data = [self getDataWithIndexPath:indexPath];
    _selectedData = data;
    [[self navigationController] dismissViewControllerAnimated:YES completion:nil];
    
//    if([[self vozVyberDelegate] respondsToSelector:@selector(vozVyberSelected:data:)])
//        [[self vozVyberDelegate] vozVyberSelected:self data:data];
}

@end
