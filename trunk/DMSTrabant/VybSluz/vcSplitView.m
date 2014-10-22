//
//  vcNewSplitView.m
//  DirectCheckin
//
//  Created by Jan Kubis on 16.11.12.
//
//

#import "vcSplitView.h"
#import "tvMaster.h"
#import "DMSetting.h"
#import "TrabantAppDelegate.h"
#import "DejalActivityView.h"

#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])
#define ROOTNAVIGATOR ([TRABANT_APP_DELEGATE rootNavController])

@interface vcSplitView () <UISearchBarDelegate>
{
    NSMutableArray *masterData, *detailData;
    DMMaster *dmMaster;
    DMDetail *dmDetail;
    NSDictionary *actualScenar;
    __weak IBOutlet tvMaster *masterTableView;
    __weak IBOutlet tvDetail *detailTableView;
    UITapGestureRecognizer *tap;
}
@property IBOutlet UISearchBar *packetSearchBar;

@end

@implementation vcSplitView
@synthesize filteredPacketArray=_filteredPacketArray;
@synthesize packetSearchBar=_packetSearchBar;
@synthesize filterPredicateString=_filterPredicateString;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        masterData = [[NSMutableArray alloc] init];
        detailData = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    dmDetail = [[DMDetail alloc] initWithData:detailTableView];
    dmDetail.baseView = self;
    dmMaster = [DMMaster dmMasterWithData:masterData detailData:detailData detailView:dmDetail masterView:masterTableView];
    dmMaster.baseView = self;
//    dataDetail = [DMDetail dmDetailWithData:detailData];
    
    masterTableView.delegate = dmMaster;
    masterTableView.dataSource = dmMaster;
    
    detailTableView.delegate = dmDetail;
    detailTableView.dataSource = dmDetail;
    
    self.packetSearchBar.searchFieldBackgroundPositionAdjustment = UIOffsetZero;
    
    self.packetSearchBar.placeholder = NSLocalizedString(@"Packet search", nil);
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    detailTableView.contentInset = UIEdgeInsetsMake(44, 0.0, 44, 0.0);
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    masterTableView.reloadingData = NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
-(void) refreshWPData
{
    [masterData removeLastObject];
    [self setPakety];
}
-(void) reloadData
{
    [masterData removeAllObjects];
    [detailData removeAllObjects];
    dmDetail.detailData = nil;
    [masterTableView deselectRowAtIndexPath:[masterTableView indexPathForSelectedRow] animated:NO];
    actualScenar = [[DMSetting sharedDMSetting] getActualScenarData];
    
    if(actualScenar == nil)
    {
        [masterData addObject:@[]];
        [detailData addObjectsFromArray:@[]];
        
        [masterTableView reloadData];
        [dmDetail setDataType:eVYBAVY];
        dmDetail.detailData = nil;
        [detailTableView reloadData];
        return;
    }
    
    NSArray *objKeys = [NSArray arrayWithObjects:@"TEXT",@"MANDATORY", nil];
    
    NSArray *obj1 = @[NSLocalizedString(@"Vybavy", @"UI strings"), [actualScenar valueForKey:@"EQUIPMENT_MANDAT"]];

    NSArray *obj2 = @[NSLocalizedString(@"Povinne vybavy", @"UI strings"), [actualScenar valueForKey:@"OBLIG_EQUIPMENT_MANDAT"]];

    [masterData addObject:[NSArray arrayWithObjects:[NSMutableDictionary dictionaryWithObjects:obj1  forKeys:objKeys],
                                        [NSMutableDictionary dictionaryWithObjects:obj2  forKeys:objKeys], nil]];

    if([DMSetting sharedDMSetting].vybavy == nil)
        [DMSetting sharedDMSetting].vybavy = [[NSMutableArray alloc] init];
    if([DMSetting sharedDMSetting].povVybavy == nil)
        [DMSetting sharedDMSetting].povVybavy = [[NSArray alloc] init];
    if([DMSetting sharedDMSetting].sluzby == nil)
        [DMSetting sharedDMSetting].sluzby = [[NSMutableArray alloc] init];
    
    [detailData addObject:[DMSetting sharedDMSetting].vybavy];
    [detailData addObject:[DMSetting sharedDMSetting].povVybavy];
    [detailData addObject:[DMSetting sharedDMSetting].sluzby];
    
    
    NSArray *obj3 = [NSArray arrayWithObjects:NSLocalizedString(@"Sluzby", @"UI strings"),
                         [actualScenar valueForKey:@"SERVICES_MANDAT"]
                         , nil];
    [masterData addObject:[NSArray arrayWithObject:[NSMutableDictionary dictionaryWithObjects:obj3 forKeys:objKeys]]];
    
    if([DMSetting sharedDMSetting].celky == nil)
        [DMSetting sharedDMSetting].celky = [[NSMutableArray alloc] init];
    if([DMSetting sharedDMSetting].casti == nil)
        [DMSetting sharedDMSetting].casti = [[NSMutableArray alloc] init];
    
    [masterData addObject:[DMSetting sharedDMSetting].celky];
    [detailData addObjectsFromArray:[DMSetting sharedDMSetting].casti ];
    
    [self setPakety];
    
}

-(void)setPakety
{
    self.filteredPacketArray = [DMSetting sharedDMSetting].pakety;
    
    [masterData addObject:[self setPaketyMaster]];
    [masterTableView reloadData];
//    [dmDetail setDataType:eVYBAVY];
    dmDetail.detailData = nil;
    [detailTableView reloadData];
}

-(NSMutableArray *)setPaketyMaster
{
    NSArray *groupNr = [[DMSetting sharedDMSetting].pakety valueForKeyPath:@"@distinctUnionOfObjects.GROUP_NR"];
    NSMutableArray *packetGroup = [NSMutableArray arrayWithCapacity:groupNr.count+1];
    if([DMSetting sharedDMSetting].pakety.count > 0)
        [packetGroup addObject: @{@"TEXT":[NSString stringWithFormat:@"%@ [%d]",NSLocalizedString(@"All packets", @"All packets"), self.filteredPacketArray.count], @"ID": [NSNumber numberWithInt:-1]}];
    
    for(NSNumber *nr in groupNr) {
        NSString *groupName = [[[DMSetting sharedDMSetting].pakety filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"GROUP_NR.intValue = %d", nr.integerValue]].lastObject valueForKey:@"GROUP_TEXT"];
        NSInteger groubcount = [self.filteredPacketArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"GROUP_NR.intValue = %d", nr.integerValue]].count;
        
        NSString *groupFullName = [NSString stringWithFormat:@"%@ [%d]", groupName, groubcount ];
        NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithObjectsAndKeys: groupFullName, @"TEXT", nr, @"ID", nil ];
        [packetGroup addObject: mdic];
    }
    
    return packetGroup;
}

- (void)viewDidUnload {
    masterTableView = nil;
    detailTableView = nil;
    [super viewDidUnload];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}

#pragma mark Content Filtering

-(void) packetFilter
{
    NSLog(@"%@",self.packetSearchBar.text);
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    self.filteredPacketArray = [DMSetting sharedDMSetting].pakety;
    
//    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *dic, NSDictionary *bindings) {
//        // remove all whitespace from both strings
//        NSString *strippedString=[[[dic valueForKey:@"WORKSHOP_PACKET_DESCRIPTION"] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@""];
//        NSString *strippedKey=[[self.packetSearchBar.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@""];
//        return [strippedString containsString:strippedKey];
//    }];
    if(self.packetSearchBar.text.length) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"WORKSHOP_PACKET_DESCRIPTION CONTAINS[cd] %@",self.packetSearchBar.text];
        self.filteredPacketArray = [NSMutableArray arrayWithArray:[[DMSetting sharedDMSetting].pakety filteredArrayUsingPredicate:predicate]];
    }
//
//    for(NSMutableDictionary *d in dmMaster.masterData.lastObject) {
//        [d setValue:@"" forKey:@"TEXT"];
//    }
    
    [masterData removeLastObject];
    
    NSMutableArray *newMaster = [self setPaketyMaster];
    
    [masterData addObject:newMaster];
    
//    for(NSMutableDictionary *d in newMaster) {
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"GROUP_NR.intValue = %d", [[d valueForKey:@"ID"] integerValue]];
//        NSMutableDictionary *mdata = [dmMaster.masterData.lastObject filteredArrayUsingPredicate:predicate].lastObject;
//        [mdata setValue:[d valueForKey:@"TEXT"] forKey:@"TEXT"];
//    }
    [masterTableView reloadData];
    
    [dmMaster.masterView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:ePAKETY] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    [dmMaster selectRow:[NSIndexPath indexPathForRow:0 inSection:ePAKETY]];
    [dmDetail.detailView reloadData];
}

#pragma mark - UISearchDisplayController Delegate Methods
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self packetFilter];
    
}

@end
