//
//  vcNabidky.m
//  Direct checkin
//
//  Created by Jan Kubis on 05.11.12.
//  Copyright (c) 2012 jan.kubis@t-systems.cz. All rights reserved.
//

#import "vcNabidky.h"
#import "DMSetting.h"
#import "Banners.h"
#import "TrabantAppDelegate.h"
#import <QuartzCore/QuartzCore.h>


#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])
#define ROOTNAVIGATOR ([TRABANT_APP_DELEGATE rootNavController])

typedef enum {ePC=101}enumFields;


@interface NabidkaTableViewCell : UITableViewCell


@end

@implementation NabidkaTableViewCell

- (void)setAccessoryType:(UITableViewCellAccessoryType)newAccessoryType
{
    // Check for the checkmark
    [super setAccessoryType:newAccessoryType];
    switch(newAccessoryType)
    {
        case UITableViewCellAccessoryCheckmark:
            self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"celky_povinny_ok.png"]];
            break;
        case UITableViewCellAccessoryNone:
            self.accessoryView = nil;
            break;
        default:
            break;
    }
    
}

@end

@interface vcNabidky() <UITableViewDelegate, UITableViewDataSource>
{
//    __weak IBOutlet UITableViewController *tbControler;
    __weak IBOutlet UIImageView *imgSpona;
    __weak IBOutlet UILabel *lblNadpis;
    __weak IBOutlet UILabel *lblUser;
    __weak IBOutlet UITableView *tbNabidka;
    NSArray *nabPicArray;
    DBBanners *banners;
}
- (void) refreshData;
@end

@implementation vcNabidky

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        banners = [[DBBanners alloc] init];
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    nabPicArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"baner1.png"],
            [UIImage imageNamed:@"baner2.png"],
            [UIImage imageNamed:@"baner3.png"],
            [UIImage imageNamed:@"baner4.png"],
            [UIImage imageNamed:@"baner5.png"],nil];

    lblNadpis.text = NSLocalizedString(@"Výhodné nabídky", @"nadpisy");

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshData];
}

- (void)viewDidUnload
{
    nabPicArray = nil;
    imgSpona = nil;
    lblNadpis = nil;
    lblUser = nil;
    tbNabidka = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.enableSave = YES;
    self.lblNavBar.text = ROOTNAVIGATOR.vozCaption;
    [super viewDidAppear:animated];
}

- (void) refresTableData
{
    [tbNabidka reloadData];
    if(existInDic([DMSetting sharedDMSetting].vozidlo, @"CHECKIN_ID") && [[[DMSetting sharedDMSetting].vozidlo valueForKey:@"CHECKIN_ID"] integerValue] > 0)
        [self setEnableSave:YES];
    else
        [self setEnableSave:NO];
}

- (void) refreshData
{
    NSString *userName = [NSString stringWithFormat:@"%@ %@", [[DMSetting sharedDMSetting].loggedUser valueForKey:@"NAME"], [[DMSetting sharedDMSetting].loggedUser valueForKey:@"SURNAME"] ];
    lblUser.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Poradce", nil), userName];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [DMSetting sharedDMSetting].nabidky.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.imageView.backgroundColor = [UIColor clearColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    [cell.selectedBackgroundView setAlpha:0];

    NSLog(@"  Showing banners :%@",[[DMSetting sharedDMSetting].nabidky[indexPath.row] objectForKey:@"CHECK_OFFER_ID"]);
    if(existInDic([DMSetting sharedDMSetting].nabidky[indexPath.row], @"ADVERT_BANNER")) {
        NSData *bannerImage = [[DMSetting sharedDMSetting].nabidky[indexPath.row] objectForKey:@"ADVERT_BANNER"];
        UIImage *img = [UIImage imageWithData:bannerImage];
//        UIColor *color = [UIColor colorWithPatternImage:img];
        UIImageView *iv = [[UIImageView alloc] initWithImage:img];
        iv.frame = CGRectMake(0, 0, 992, 100);
//        [cell setBackgroundColor:color];
        [cell setBackgroundView:iv];
        NSRange r = {bannerImage.length - 10, 10};
        NSRange r2 = {0, 10};
        NSLog(@"  Baner data :%d",[bannerImage length]);
        NSLog(@"  Start :%@",[bannerImage subdataWithRange:r2]);
        NSLog(@"  End :%@",[bannerImage subdataWithRange:r]);
        NSLog(@"  Size :%f, %f, %@\n", img.size.height, img.size.width, cell.backgroundView);
    } else {
        NSLog(@"  No banner :%@", [[DMSetting sharedDMSetting].nabidky[indexPath.row] objectForKey:@"ADVERT_BANNER"]);
        [cell setBackgroundColor:[UIColor clearColor]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"ROW";//[NSString stringWithFormat:@"%d_%d", indexPath.section, indexPath.row];
    UITextField *txtPC = nil;
    NSDictionary *row = [DMSetting sharedDMSetting].nabidky[indexPath.row];

    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[NabidkaTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:30.0];
        
        UILabel *lblBackground = [[UILabel alloc] initWithFrame:CGRectMake(850, 20, 135, 50)];
        [lblBackground setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.7]];
        lblBackground.layer.cornerRadius = 8;
        [cell.contentView addSubview:lblBackground];
        
        txtPC = [[UITextField alloc] initWithFrame:CGRectMake(850, 30, 100, 30)];
        txtPC.font = [UIFont fontWithName:@"Helvetica-Bold" size:24.0];
        txtPC.tag = ePC;
        txtPC.userInteractionEnabled = NO;
        txtPC.textAlignment = NSTextAlignmentCenter;
//        txtPC.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        txtPC.layer.cornerRadius = 10;
        [cell.contentView addSubview:txtPC];
    }
    
    if([[row valueForKey:@"SHOW_TXT"] boolValue])
        cell.textLabel.text = [row valueForKey:@"TEXT"];
    else
        cell.textLabel.text = @"";
    
    if(txtPC == nil)
        txtPC = (UITextField*)[cell.contentView viewWithTag:ePC];
    
    if([row valueForKey:@"SELL_PRICE"] == nil || [row valueForKey:@"SELL_PRICE"] == [NSNull null])
        txtPC.text = @"";
    else
        txtPC.text = [NSString stringWithFormat:@"%@", [row valueForKey:@"SELL_PRICE"]];
    
    if(existInDic(row, @"CHECKED") && [[row valueForKey:@"CHECKED"] integerValue] == 1)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellAccessoryType accessoryType = [aTableView cellForRowAtIndexPath:indexPath].accessoryType;
    [aTableView cellForRowAtIndexPath:indexPath].accessoryType = (accessoryType)?UITableViewCellAccessoryNone:UITableViewCellAccessoryCheckmark;
    accessoryType = [aTableView cellForRowAtIndexPath:indexPath].accessoryType;
    NSString *value = (accessoryType == UITableViewCellAccessoryCheckmark)?@"1":@"0";
    [[DMSetting sharedDMSetting].nabidky[indexPath.row] setValue:value forKey:@"CHECKED"];
    [self setStatusOdeslani:NO];
}

@end
