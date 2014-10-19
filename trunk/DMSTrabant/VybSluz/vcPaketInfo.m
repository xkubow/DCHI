//
//  vcPaketInfo.m
//  DirectCheckin
//
//  Created by Jan Kubis on 06.08.14.
//
//

#import "vcPaketInfo.h"
#import "tvcNDPacketInfo.h"
#import "tvcPPPacketInfo.h"
#import "DMSetting.h"
#import "TrabantAppDelegate.h"

#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])

@interface vcPaketInfo ()<UITableViewDelegate, UITableViewDataSource>
{
    
    __weak IBOutlet UITableView *tvPaketInfo;
    NSArray *_NDPaketDetailArray;
    NSArray *_PPPaketDetailArray;
    NSDictionary *_packet;
    enum filterEnum {eND=0, ePP=1, eALL=999999};
    enum filterEnum filtered;
    NSString *_NDCell;
    NSString *_PPCell;
    __weak IBOutlet UILabel *lblPrace;
    __weak IBOutlet UILabel *lblPraceCena;
    __weak IBOutlet UILabel *lblMaterial;
    __weak IBOutlet UILabel *lblMaterialCena;
    __weak IBOutlet UILabel *lblCelkem;
    __weak IBOutlet UILabel *lblCelkemCena;
    
    UIImage *_naSklade, *_neNaSklade, *_prace;
}
@end

@implementation vcPaketInfo

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil packet:(NSDictionary*)packet
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _packet = packet;
        NSArray *packetDetail = [_packet valueForKey:@"DETAIL_LIST"];
        
        NSPredicate *predicateND = [NSPredicate predicateWithFormat:@"CAPAKET_ITEM_ENUM like 'SPARE_PART'"];
        NSPredicate *predicatePP = [NSPredicate predicateWithFormat:@"CAPAKET_ITEM_ENUM like 'LABOR_POSITION'"];
        
        _NDPaketDetailArray = [packetDetail filteredArrayUsingPredicate:predicateND];
        _PPPaketDetailArray = [packetDetail filteredArrayUsingPredicate:predicatePP];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.navigationItem.title = @"Detail paketu";
    
    _naSklade = [UIImage imageNamed:@"tag_green"];
    _neNaSklade = [UIImage imageNamed:@"tag_orange"];
    _prace = [UIImage imageNamed:@"celky_servis.png"];
    
    _NDCell = @"NDCell";
    _PPCell = @"PPCell";
    [tvPaketInfo registerNib:[UINib nibWithNibName:@"tvcNDPacketInfo" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:_NDCell];
    [tvPaketInfo registerNib:[UINib nibWithNibName:@"tvcPPPacketInfo" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:_PPCell];
    
    lblMaterial.text = NSLocalizedString(@"Material", nil);
    lblPrace.text = NSLocalizedString(@"Prace", nil);
    lblCelkem.text = NSLocalizedString(@"Celkem", nil);
    
    double NDsum = 0.0;
    for(NSDictionary *d in _NDPaketDetailArray)
        if(existInDic(d, @"SELL_PRICE"))
            NDsum += [[d valueForKey:@"SELL_PRICE"] doubleValue];
//    NSNumber* NDsum = [_NDPaketDetailArray valueForKeyPath: @"@sum.SELL_PRICE"];
    lblMaterialCena.text = [NSString stringWithFormat:@"%@ %@", [TRABANT_APP_DELEGATE.numFormat stringFromNumber:[NSNumber numberWithDouble:NDsum]], [[DMSetting sharedDMSetting].setting valueForKey:@"CURRENCY_ABBREV"]];
    
    double PPsum = 0.0;
    for(NSDictionary *d in _PPPaketDetailArray)
        if(existInDic(d, @"SELL_PRICE"))
            PPsum += [[d valueForKey:@"SELL_PRICE"] doubleValue];
    //    NSNumber* NDsum = [_NDPaketDetailArray valueForKeyPath: @"@sum.SELL_PRICE"];
    lblPraceCena.text = [NSString stringWithFormat:@"%@ %@", [TRABANT_APP_DELEGATE.numFormat stringFromNumber:[NSNumber numberWithDouble:PPsum]], [[DMSetting sharedDMSetting].setting valueForKey:@"CURRENCY_ABBREV"]];
    
    lblCelkemCena.text = [NSString stringWithFormat:@"%@ %@", [TRABANT_APP_DELEGATE.numFormat stringFromNumber:[NSNumber numberWithDouble:(PPsum + NDsum)]], [[DMSetting sharedDMSetting].setting valueForKey:@"CURRENCY_ABBREV"]];
    
    filtered = eALL;
    
    if([tvPaketInfo respondsToSelector:@selector(setSeparatorInset:)]) {
        [tvPaketInfo setSeparatorInset:UIEdgeInsetsZero];
        tvPaketInfo.layoutMargins = UIEdgeInsetsZero;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGSize nrSize = self.navigationController.navigationBar.frame.size;//CGSizeMake(700, 44);
    UIImage *img = [UIImage imageNamed:@"alu_texture_navigation.png"];
    
    UIGraphicsBeginImageContext(nrSize);
    [img drawInRect:CGRectMake(0, 0, nrSize.width, nrSize.height)];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    [self.navigationController.navigationBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@",  [_packet objectForKey:@"WORKSHOP_PACKET_NUMBER" ]];
    
    if(existInDic(_packet, @"WORKSHOP_PACKET_DESCRIPTION"))
        self.navigationItem.title = [NSString stringWithFormat:@"%@ - %@",  self.navigationItem.title, [_packet objectForKey:@"WORKSHOP_PACKET_DESCRIPTION" ]];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    tvPaketInfo = nil;
    lblPrace = nil;
    lblPraceCena = nil;
    lblMaterial = nil;
    lblMaterialCena = nil;
    lblCelkem = nil;
    lblCelkemCena = nil;
    [super viewDidUnload];
}

#pragma mark -tableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    switch (indexPath.section) {
        case 0:
            return 50;
            break;
        case 1:
            return 50;
            break;
            
        default:
            return tableView.rowHeight;
            break;
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (filtered == eALL)?2:1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
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
            caption = NSLocalizedString(@"ND", @"ND");
            break;
        case 1:
            caption = NSLocalizedString(@"PP", @"PP");
            break;
        default:
            caption = @"";
            break;
    }
            headerLabel.text = caption;
            
            return sectionHeaderView;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    
//    if(filtered != eALL)
//        return (filtered == eND)?@"ND":@"PP";
//    
//    
//    switch (section) {
//        case 0:
//            return NSLocalizedString(@"ND", @"ND");
//            break;
//        case 1:
//            return  NSLocalizedString(@"PP", @"PP");
//            break;
//        default:
//            return @"";
//            break;
//    }
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(filtered != eALL)
        return (filtered == eND)?_NDPaketDetailArray.count:_PPPaketDetailArray.count;
    
    switch (section) {
        case 0:
            return _NDPaketDetailArray.count;
            break;
        case 1:
            return _PPPaketDetailArray.count;
            break;
        default:
            return 0;
            break;
    }
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section;
    if(filtered == eALL)
        section = indexPath.section;
    else
        section = (filtered == ePP)?1:0;
    
    NSString *CellIdentifier = (section == 0)?@"NDCell":@"PPCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    
    switch (section) {
        case 0:
            [self fillNDCell:(tvcNDPacketInfo*)cell cellForRowAtIndexPath:indexPath];
            break;
        case 1:
            [self fillPPCell:(tvcPPPacketInfo*)cell cellForRowAtIndexPath:indexPath];
            break;
    
        default:
            break;
    }
    
    
    
    return cell;
}

-(void)fillNDCell:(tvcNDPacketInfo*)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = _NDPaketDetailArray[indexPath.row];
//    cell.textLabel.text = [data valueForKey:@"CAPAKET_ITEM_NUMBER"];
//    cell.detailTextLabel.text = [data valueForKey:@"CAPAKET_ITEM_DESCRIPTION"];

    cell.ItemNumber.text = [data valueForKey:@"CAPAKET_ITEM_NUMBER"];
    cell.Nazev.text = [data valueForKey:@"CAPAKET_ITEM_DESCRIPTION"];
    
    if(existInDic(data, @"AMOUNT")) {
        NSNumber *n = [data valueForKey:@"AMOUNT"];
        cell.Mnozstvi.text = [NSString stringWithFormat:@"%@ %@", [TRABANT_APP_DELEGATE.numFormat stringFromNumber:n], NSLocalizedString(@"ks", nil)];
    }
    else
        cell.Mnozstvi.text = @"";
    
    if(existInDic(data, @"SELL_PRICE")) {
        NSNumber *n = [data valueForKey:@"SELL_PRICE"];
        cell.Cena.text = [NSString stringWithFormat:@"%@ %@", [TRABANT_APP_DELEGATE.numFormat stringFromNumber:n], [[DMSetting sharedDMSetting].setting valueForKey:@"CURRENCY_ABBREV"]];
    }
    else
        cell.Cena.text = @"";
    
    if(existInDic(data, @"SPARE_PART_DISPON_ID"))
        cell.imageView.image = ([[data valueForKey:@"SPARE_PART_DISPON_ID"] integerValue])?_naSklade:_neNaSklade;

}

-(void)fillPPCell:(tvcPPPacketInfo*)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = _PPPaketDetailArray[indexPath.row];
    cell.Nazev.text = [data valueForKey:@"CAPAKET_ITEM_DESCRIPTION"];
    cell.CisloPP.text = [data valueForKey:@"CAPAKET_ITEM_NUMBER"];
    
    if(existInDic(data, @"SELL_PRICE")) {
        NSNumber *n = [data valueForKey:@"SELL_PRICE"];
        cell.PC.text = [NSString stringWithFormat:@"%@ %@", [TRABANT_APP_DELEGATE.numFormat stringFromNumber:n], [[DMSetting sharedDMSetting].setting valueForKey:@"CURRENCY_ABBREV"]];
    }
    else
        cell.PC.text = @"";
    
    cell.imageView.image = _prace;
    
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}
- (IBAction)btnPraceClicked:(id)sender {
    filtered = ePP;
    [tvPaketInfo reloadData];
    
}
- (IBAction)btnMaterialClicked:(id)sender {
    filtered = eND;
    [tvPaketInfo reloadData];
}
- (IBAction)btnCelkemClicked:(id)sender {
    filtered = eALL;
    [tvPaketInfo reloadData];
}

@end
