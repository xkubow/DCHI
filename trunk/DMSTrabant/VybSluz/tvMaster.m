//
//  tvMaster.m
//  DirectCheckin
//
//  Created by Jan Kubis on 16.11.12.
//
//

#import "tvMaster.h"
#import "tvDetail.h"
#import "vcBase.h"
#import "DMSetting.h"
#import "vcSplitView.h"

@interface tvMaster()
{
}

@end

@implementation tvMaster
@synthesize reloadingData=_reloadingData;

- (void)commonInit
{
    _reloadingData = YES;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self commonInit];
    }
    return self;
}

- (void) reloadData
{
    _reloadingData = YES;
    [super reloadData];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

@interface DMMaster()
{
    UIImage *warningIcon, *checkIcon;
}

@property (nonatomic, retain) NSArray *detailData;
@property (nonatomic, retain) DMDetail *detail;

@end

@implementation DMMaster
@synthesize masterData=_masterData;
@synthesize detail=_detail;
@synthesize masterView=_masterView;
@synthesize detailData=_detailData;
@synthesize baseView=_baseView;

+ (DMMaster *)dmMasterWithData:(NSArray*)data detailData:(NSArray *)detailData detailView:(DMDetail *)detail masterView:(tvMaster *)master
{
    DMMaster* obj = [[self alloc] init];
    if(obj)
    {
        obj.masterData = data;
        obj.detail = detail;
        obj.masterView = master;
        obj.detailData = detailData;
        
        if([obj.masterView respondsToSelector:@selector(setSeparatorInset:)]) {
            [obj.masterView setSeparatorInset:UIEdgeInsetsZero];
            obj.masterView.layoutMargins = UIEdgeInsetsZero;
        }
    }
    return obj;
}

- (id) init
{
    self = [super init];
    
    if (self) {
        warningIcon = [UIImage imageNamed:@"celky_povinny"];
        checkIcon = [UIImage imageNamed:@"celky_povinny_ok"];
    }
    
    return self;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if([_masterData[section] count] == 0)
        return 0;
    else
        return 22;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if([_masterData[section] count] == 0)
        return nil;
    
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:
                                 CGRectMake(0, 0, tableView.frame.size.width, 20.0)];
    sectionHeaderView.backgroundColor = [UIColor colorWithRed:0.923 green:0.923 blue:0.925 alpha:1];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:
                            CGRectMake(5, 0, sectionHeaderView.bounds.size.width-5, sectionHeaderView.bounds.size.height)];
    
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textAlignment = NSTextAlignmentLeft ;
    [headerLabel setFont:[UIFont fontWithName:@"Verdana-Bold" size:17.0]];
    [headerLabel setTextColor:[UIColor blackColor]];
    [sectionHeaderView addSubview:headerLabel];
    
    NSString *caption;
    switch (section) {
        case 0:
            caption = NSLocalizedString(@"Vybavy", nil);
            break;
        case 1:
            caption = NSLocalizedString(@"Sluzby", nil);
            break;
        case 2:
            caption = NSLocalizedString(@"Celky", nil);
            break;
        case 3:
            caption = NSLocalizedString(@"Pakety", nil);
            break;
            
        default:
            caption = @"";
            break;
    }
    headerLabel.text = caption;
    
    return sectionHeaderView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _masterData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_masterData[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.layoutMargins = UIEdgeInsetsZero;
        [cell.textLabel setFont:[UIFont fontWithName:@"Verdana-Bold" size:17]];  // @{NSFontAttributeName : @"Verdana-Bold"};
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor colorWithRed:(119.0/255.0) green:(156.0/255.0) blue:(164.0/255.0) alpha:1.0]; // perfect color suggested by @mohamadHafez
        bgColorView.layer.masksToBounds = YES;
        cell.selectedBackgroundView = bgColorView;
    }
    
    //    if(_masterView.reloadingData)
    {
        cell.tag = 0;
        cell.imageView.image = nil;
        NSLog(@"%d, %d, %@", indexPath.section, indexPath.row, [_masterData[indexPath.section][indexPath.row] objectForKey:@"TEXT"]);
        cell.textLabel.text = [_masterData[indexPath.section][indexPath.row] objectForKey:@"TEXT"];
        if([[_masterData[indexPath.section][indexPath.row] objectForKey:@"MANDATORY"] integerValue] || indexPath.section == 2) {
            if([[_masterData[indexPath.section][indexPath.row] objectForKey:@"MANDATORY"] integerValue] == 2
               || (existInDic([DMSetting sharedDMSetting].vozidlo, @"CHECKIN_ID") && [[[DMSetting sharedDMSetting].vozidlo valueForKey:@"CHECKIN_ID"] integerValue] > 0)) {
                cell.tag = 2;
                cell.imageView.image = checkIcon;
            } else {
                cell.imageView.image = warningIcon;
                cell.tag = 1;
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self selectRow:indexPath];
}

-(void) selectRow:(NSIndexPath*)indexPath
{
    NSInteger index = 0;
    NSLog(@"%d, %d > %@", indexPath.section, indexPath.row, _masterData[indexPath.section][indexPath.row]);
    for (int i=0; i < indexPath.section; i++) {
        index += [_masterView numberOfRowsInSection:i];
    }
    
    _dataType = indexPath.section;
    [_detail setDataType:_dataType];
    index += indexPath.row;
    if(_dataType == ePAKETY) {
        vcSplitView *vcSp =(vcSplitView*)self.baseView;
        NSArray *filteredPakety = vcSp.filteredPacketArray;
        NSInteger groupId = [[_masterData[indexPath.section][indexPath.row] valueForKey:@"ID"] integerValue];
        if(groupId == -1)
            _detail.detailData = filteredPakety;//[DMSetting sharedDMSetting].pakety;
        else
            _detail.detailData = [filteredPakety filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"GROUP_NR.intValue = %d", groupId]];
    }
    else
        _detail.detailData = [_detailData objectAtIndex:index];
    _detail.unitName = [_masterData[indexPath.section][indexPath.row] valueForKey:@"TEXT"];
    
    //    [_baseView performSelector:@selector(setFilteredPacketArray:) withObject:[NSMutableArray arrayWithCapacity:[DMSetting sharedDMSetting].pakety.count]];
    
    if([self.masterView cellForRowAtIndexPath:indexPath].tag == 1){
        //        vcBase *vcb = _detail.baseView;
        
        NSArray *badge = [_baseView.navigationController.tabBarItem.badgeValue componentsSeparatedByString:@"/"];
        NSInteger selected = [[badge objectAtIndex:0] integerValue] + 1;
        NSInteger pov = [[badge objectAtIndex:1] integerValue];
        [self.masterView cellForRowAtIndexPath:indexPath].tag = 2;
        [self.masterView cellForRowAtIndexPath:indexPath].imageView.image = checkIcon;
        [_masterData[indexPath.section][indexPath.row] setValue:@2 forKey:@"MANDATORY"];
        if(selected == pov)
        {
            _baseView.enableSave = YES;
        }
        else
        {
            NSString *badgeString = [NSString stringWithFormat:@"%d/%d", selected, pov];
            _baseView.navigationController.tabBarItem.badgeValue = badgeString;
        }
    }
    [_detail.detailView reloadData];
}

@end
