//
//  vcSluzbyPicker.m
//  DirectCheckin
//
//  Created by Jan Kubis on 04.01.13.
//
//

#import "vcSluzbyPicker.h"
#import "DMSetting.h"
#import "vNumKeyboard.h"
#import <QuartzCore/QuartzCore.h>
#import "TrabantAppDelegate.h"

#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])
#define ROOTNAVIGATOR ([TRABANT_APP_DELEGATE rootNavController])

@interface vcSluzbyPicker ()<UITableViewDelegate, UITableViewDataSource>
{
    vNumKeyboard *myNumKeyboard;
    NSInteger selectedRow;
    NSArray *_servicesArray;
    UIImage *serviceImage, *packetGreen, *packetGreenE, *packetOrange, *packetOrangeE;
    __weak IBOutlet UITableView *tvServices;
    __weak IBOutlet UILabel *lblPC;
    __weak IBOutlet UILabel *lblMena;
    __weak IBOutlet UIView *vKeyboard;
    __weak IBOutlet UIView *vPC;
}

@end

@implementation vcSluzbyPicker
@synthesize serviceID = _servicesID;
@synthesize pc = _pc;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil data:(NSArray*)data
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _servicesArray = data;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil data:(NSArray*)data selectedRow:(NSInteger)newSelectedRow
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _servicesArray = data;
        selectedRow = newSelectedRow;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    serviceImage = [UIImage imageNamed:@"celky_servis"];
    packetGreen = [UIImage imageNamed:@"packet_green"];
    packetGreenE = [UIImage imageNamed:@"packet_green_E"];
    packetOrange = [UIImage imageNamed:@"packet_orange"];
    packetOrangeE = [UIImage imageNamed:@"packet_orange_E"];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    
    CGRect nr = self.navigationController.navigationBar.frame;
    UIImage *img = [UIImage imageNamed:@"alu_texture_navigation.png"];
    
    UIGraphicsBeginImageContext(CGSizeMake(nr.size.width, nr.size.height));
    [img drawInRect:nr];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.navigationController.navigationBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
    
    CGRect r = self.navigationController.navigationBar.frame;
    UILabel *_lblNavBar = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, nr.size.width, r.size.height)];
    _lblNavBar.text = self.title;//@"aqdqwdwefasdfgqefqewf";
    _lblNavBar.lineBreakMode = NSLineBreakByTruncatingTail;
    _lblNavBar.backgroundColor = [UIColor clearColor];
    _lblNavBar.textColor = [UIColor whiteColor];
    _lblNavBar.font = [UIFont fontWithName:@"Verdana" size:25 ];
    _lblNavBar.textAlignment = NSTextAlignmentCenter;
    _lblNavBar.clipsToBounds = NO;
    _lblNavBar.numberOfLines = 0;
    _lblNavBar.adjustsFontSizeToFitWidth = NO;
    self.navigationItem.titleView = _lblNavBar;
    
    myNumKeyboard = [[vNumKeyboard alloc] initWithNibName:@"vNumKeyboard" bundle:[NSBundle mainBundle] label:lblPC];
    myNumKeyboard.view.frame = CGRectMake(0, 0, vKeyboard.frame.size.width, vKeyboard.frame.size.height);
    [vKeyboard addSubview:myNumKeyboard.view];
    [vKeyboard layoutSubviews];
    vPC.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"kalk_ciastka_bg"]];
    lblMena.text = [[DMSetting sharedDMSetting].setting valueForKey:@"DChICurrencyAbbreviation"];
    [self.view  layoutSubviews];
    
    if(selectedRow > 0) {
        [tvServices selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
        lblPC.text = [_servicesArray[selectedRow] valueForKey:@"SELL_PRICE"];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    tvServices = nil;
    lblPC = nil;
    [super viewDidUnload];
}

-(NSDictionary *)selectedPacked
{
    NSIndexPath *ip = tvServices.indexPathForSelectedRow;
    if(ip && existInDic(_servicesArray[ip.row], @"WORKSHOP_PACKET_NUMBER"))
        return _servicesArray[ip.row];
    else
        return nil;
}

-(NSString*)serviceID
{
    NSIndexPath *ip = tvServices.indexPathForSelectedRow;
    if(ip)
        return [_servicesArray[ip.row] objectForKey:@"CHCK_REQUIRED_ID"];
    return nil;
}

-(NSString*)serviceText
{
    NSIndexPath *ip = tvServices.indexPathForSelectedRow;
    if(ip)
        return [_servicesArray[ip.row] objectForKey:@"CHCK_REQUIRED_TXT"];
    return nil;
}

-(NSString*)pc
{
    NSString *separator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
    return [lblPC.text stringByReplacingOccurrencesOfString:separator withString:@""];
}

#pragma mark -tableViewDelegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _servicesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"ServiceCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        [cell.textLabel setFont:[UIFont fontWithName:@"Verdana-Bold" size:17]];
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        [cell.detailTextLabel setFont:[UIFont fontWithName:@"Verdana" size:14]];
        cell.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
        
        UIView *v= [[UIView alloc] initWithFrame:cell.frame];
        v.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"kalk_cisla_bg"]];//[UIColor colorWithRed:0.45 green:0.6 blue:0.63 alpha:1];
        cell.selectedBackgroundView = v;
    }

    if(existInDic(_servicesArray[indexPath.row], @"CHCK_REQUIRED_TXT"))
    {
        cell.textLabel.text = [_servicesArray[indexPath.row] objectForKey:@"CHCK_REQUIRED_TXT" ];
        cell.detailTextLabel.text = @"";
        cell.imageView.image = serviceImage;
    }
    else if(existInDic(_servicesArray[indexPath.row], @"WORKSHOP_PACKET_DESCRIPTION"))
    {
        cell.textLabel.text = [_servicesArray[indexPath.row] objectForKey:@"WORKSHOP_PACKET_DESCRIPTION" ];
        if(existInDic(_servicesArray[indexPath.row], @"RESTRICTIONS"))
            cell.detailTextLabel.text = [_servicesArray[indexPath.row] objectForKey:@"RESTRICTIONS" ];
        else
            cell.detailTextLabel.text = @"";
        BOOL isEconomy = [[_servicesArray[indexPath.row] objectForKey:@"ECONOMIC"] boolValue];
        BOOL isAvailable = NO;
        if(existInDic(_servicesArray[indexPath.row], @"SPARE_PART_DISPON_ID"))
            isAvailable = [[_servicesArray[indexPath.row] objectForKey:@"SPARE_PART_DISPON_ID"] boolValue];//isEqualToString:@"NOT_AVAILABLE"];
        if(isAvailable)
            cell.imageView.image = (isEconomy)?packetOrangeE: packetOrange;
        else
            cell.imageView.image = (isEconomy)?packetGreenE: packetGreen;
            
    }
    
    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    myNumKeyboard.value = @"";
    if(existInDic(_servicesArray[indexPath.row], @"SELL_PRICE"))
    {
        NSNumber *n = [_servicesArray[indexPath.row] valueForKey:@"SELL_PRICE"];
        if(n)
            lblPC.text = [n stringValue];
        else
            lblPC.text = [_servicesArray[indexPath.row] valueForKey:@"SELL_PRICE"];
    }
    else
        lblPC.text = @"";
}


@end
