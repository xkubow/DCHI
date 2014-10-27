//
//  tvDetail.m
//  DirectCheckin
//
//  Created by Jan Kubis on 16.11.12.
//
//

#import "tvDetail.h"
#import "DMSetting.h"
#import "vcBase.h"
#import "TrabantAppDelegate.h"
#import "vcSluzbyPicker.h"
#import "vcPaketInfo.h"
#import "tvMaster.h"
#import "Rezident.h"

#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])
#define ROOTNAVIGATOR ([TRABANT_APP_DELEGATE rootNavController])


@interface myTableViewCell : UITableViewCell

@property (nonatomic, readwrite) spDataType dataType;

@end



@implementation myTableViewCell

- (void) layoutSubviews {
    [super layoutSubviews];
    if(_dataType != ePAKETY)
        self.textLabel.frame = CGRectMake(5, 5, 480, 20);
}

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


@implementation tvDetail

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
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

@interface DMDetail()
{
    UIPopoverController *myPopoverController;
    NSMutableDictionary *editedData;
    NSArray *pozadData;
    UIImage *nezadanoIcon, *odlozeniIcon, *servisIcon, *okIcon,
    *nezadanoDisIcon, *odlozeniDisIcon, *servisDisIcon,*okDisIcon,
    *packetGreen, *packetGreenE, *packetOrange, *packetOrangeE, *packetInfo;
    UISwipeGestureRecognizer *swipeLeft;
    UIButton *btnClearRow;
    spDataType _dataType;
}

- (void) setVybavyCells:(UITableViewCell*) cell;
- (void) loadVybavyData:(UITableViewCell*) cell data:(NSDictionary *)data;
- (void) vybavaDidSelect:(NSIndexPath *)indexPath;

//- (void) celkyDidSelect:(NSIndexPath *)indexPath;
- (void) loadPozadavky:(id)sender data:(NSArray*)dat;
- (void) setPoziadavkyDataWithIndexPath:(NSIndexPath*)ip;

@end

@implementation DMDetail
@synthesize detailData=_detailData;
@synthesize detailView=_detailView;
@synthesize baseView=_baseView;
@synthesize unitName=_unitName;


- (id) initWithData:(tvDetail*)detailView
{
    self = [super init];
    if(self)
    {
        _detailView = detailView;
        okIcon = [UIImage imageNamed:@"celky_povinny_ok"];
        nezadanoIcon = [UIImage imageNamed:@"celky_nezadano"];
        odlozeniIcon = [UIImage imageNamed:@"celky_olozeni"];
        servisIcon = [UIImage imageNamed:@"celky_servis"];
        
        okDisIcon = [UIImage imageNamed:@"celky_povinny_ok_dis"];
        nezadanoDisIcon = [UIImage imageNamed:@"celky_nezadano_dis"];
        odlozeniDisIcon = [UIImage imageNamed:@"celky_olozeni_dis"];
        servisDisIcon = [UIImage imageNamed:@"celky_servis_dis"];
        
        packetGreen = [UIImage imageNamed:@"packet_green"];
        packetGreenE = [UIImage imageNamed:@"packet_green_E"];
        packetOrange = [UIImage imageNamed:@"packet_orange"];
        packetOrangeE = [UIImage imageNamed:@"packet_orange_E"];
        
        packetInfo = [UIImage imageNamed:@"Info_icon"];
        
        if([_detailView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_detailView setSeparatorInset:UIEdgeInsetsZero];
            _detailView.layoutMargins = UIEdgeInsetsZero;
        }
    }
    return self;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    if(_dataType == eCELKY || _dataType == ePAKETY)
        height = 50;//1.25*UITableViewAutomaticDimension;
    else
        height = UITableViewAutomaticDimension;
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _detailData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell %d", _dataType];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[myTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.clipsToBounds = NO;
        cell.layoutMargins = UIEdgeInsetsZero;
        
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor colorWithRed:(76.0/255.0) green:(161.0/255.0) blue:(255.0/255.0) alpha:1.0]; // perfect color suggested by @mohamadHafez
        bgColorView.layer.masksToBounds = YES;
        cell.selectedBackgroundView = bgColorView;
        
        ((myTableViewCell *)cell).dataType = _dataType;
        switch (_dataType) {
            case eVYBAVY:
                [self setVybavyCells:cell];
                break;
            case eDTNABIDKY:
                [self setSluzbyCells:cell];
                break;
            case eCELKY:
                [self setCelkyCells:cell];
                break;
            case ePAKETY:
                [self setPaketyCells:cell];
                break;
            default:
                break;
        }
    }
    
    switch (_dataType) {
        case eVYBAVY:
            [self loadVybavyData:cell data:_detailData[indexPath.row]];
            break;
        case eDTNABIDKY:
            [self loadNabidkyData:cell data:_detailData[indexPath.row]];
            break;
        case eCELKY:
            [self loadCelkyData:cell data:_detailData[indexPath.row]];
            break;
        case ePAKETY:
            [self loadPaketyData:cell data:_detailData[indexPath.row]];
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (_dataType) {
        case eVYBAVY:
            [self vybavaDidSelect:indexPath];
            break;
        case eDTNABIDKY:
            [self sluzbaDidSelect:indexPath];
            break;
        case ePAKETY:
            break;
            //        case eCELKY:
            //            [self celkyDidSelect:indexPath];
            //            break;
        default:
            break;
    }
    
    [_baseView performSelector:@selector(setStatusOdeslani:) withObject:self];
}

-(void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - nastavenie VYBAV

- (void) setVybavyCells:(UITableViewCell*) cell
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UITextField *textfield = [[UITextField alloc] initWithFrame:CGRectMake(10, 6, 300, 30)];
    textfield.font = [UIFont fontWithName:@"Verdana-Bold" size:17];
    textfield.tag = eVYBAVATEXT;
    [textfield setBorderStyle:UITextBorderStyleNone];
    [textfield setPlaceholder:NSLocalizedString(@"Volne vybavy", nil)];
    textfield.autocorrectionType = UITextAutocorrectionTypeNo;
    [textfield addTarget:self action:@selector(vybavaDidStartEdit:) forControlEvents:UIControlEventEditingDidBegin];
    [textfield addTarget:self action:@selector(vybavaDidFinishEdit:) forControlEvents:UIControlEventEditingDidEnd];
    [textfield addTarget:self action:@selector(vybavaDidChanged:) forControlEvents:UIControlEventEditingChanged];
    [cell.contentView addSubview:textfield];
    [cell layoutSubviews];
}

- (void) setSluzbyCells:(UITableViewCell*) cell
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UITextField *textfield = [[UITextField alloc] initWithFrame:CGRectMake(10, 6, 490, 30)];
    //    [textfield setBackgroundColor:[UIColor redColor]];
    textfield.font = [UIFont fontWithName:@"Verdana-Bold" size:17];
    textfield.tag = eVYBAVATEXT;
    [textfield setBorderStyle:UITextBorderStyleNone];
    [textfield setPlaceholder:NSLocalizedString(@"Volne sluzby", nil)];
    textfield.autocorrectionType = UITextAutocorrectionTypeNo;
    [textfield addTarget:self action:@selector(vybavaDidStartEdit:) forControlEvents:UIControlEventEditingDidBegin];
    [textfield addTarget:self action:@selector(vybavaDidFinishEdit:) forControlEvents:UIControlEventEditingDidEnd];
    [textfield addTarget:self action:@selector(vybavaDidChanged:) forControlEvents:UIControlEventEditingChanged];
    [cell.contentView addSubview:textfield];
    
    
    UITextField *txtPC = [[UITextField alloc] initWithFrame:CGRectMake(500, 6, 100, 30)];
    [txtPC addTarget:self action:@selector(vybavaDidStartEdit:) forControlEvents:UIControlEventEditingDidBegin];
    [txtPC addTarget:self action:@selector(vybavaDidFinishEdit:) forControlEvents:UIControlEventEditingDidEnd];
    [txtPC addTarget:self action:@selector(txtPCDidChanged:) forControlEvents:UIControlEventEditingChanged];
    txtPC.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0];
    txtPC.keyboardType = UIKeyboardTypeNumberPad;
    txtPC.tag = eSLUZBAPC;
    //    txtPC.userInteractionEnabled = NO;
    txtPC.enabled = NO;
    txtPC.textAlignment = NSTextAlignmentRight;
    [cell.contentView addSubview:txtPC];
    
    [cell layoutSubviews];
}

- (void) setPaketyCells:(UITableViewCell*) cell
{
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:(119.0/255.0) green:(156.0/255.0) blue:(164.0/255.0) alpha:1.0]; // perfect color suggested by @mohamadHafez
    bgColorView.layer.masksToBounds = YES;
    cell.selectedBackgroundView = bgColorView;
    
    CGRect r = [_detailView rectForRowAtIndexPath:_detailView.indexPathForSelectedRow];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(r.size.width - 596, 5, 380, 18)];
    lblTitle.textAlignment = NSTextAlignmentLeft;
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.font = [UIFont fontWithName:@"Verdana-Bold" size:17];
    lblTitle.tag = eTITLETEXT;
    [cell.contentView addSubview:lblTitle];
    
    UILabel *lblDetail = [[UILabel alloc] initWithFrame:CGRectMake(r.size.width - 596, 29, 380, 18)];
    lblDetail.textAlignment = NSTextAlignmentLeft;
    lblDetail.backgroundColor = [UIColor clearColor];
    lblDetail.font = [UIFont fontWithName:@"Verdana" size:14];
    lblDetail.tag =eDETAILTEXT;
    [cell.contentView addSubview:lblDetail];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [btn addTarget:self action:@selector(packetInfoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    btn.tintColor = [UIColor colorWithRed:0.471 green:0.612 blue:0.639 alpha:1];
    btn.adjustsImageWhenHighlighted = YES;
    btn.tag = eDETAIL;
    cell.accessoryView = btn;
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(r.size.width - 90, 5, 44, 44)];
    [btn addTarget:self action:@selector(packetCheckClicked:) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundImage:okDisIcon forState:UIControlStateNormal];
    [btn setBackgroundImage:okDisIcon forState:UIControlStateHighlighted];
    [btn setBackgroundImage:okIcon forState:UIControlStateSelected];
    btn.tag = eOKBTN;
    [cell.contentView addSubview:btn];
    
    UILabel *lblPc = [[UILabel alloc] initWithFrame:CGRectMake(r.size.width - 230, 29, 120, 18)];
    lblPc.textAlignment = NSTextAlignmentRight;
    lblPc.backgroundColor = [UIColor clearColor];
    lblPc.font = [UIFont fontWithName:@"Verdana-Bold" size:17];
    lblPc.textColor = [UIColor colorWithRed:0.18 green:0.35 blue:0.7 alpha:1];
    lblPc.tag =eCELKYPC;
    [cell.contentView addSubview:lblPc];
    
    [cell layoutSubviews];
    
}

- (void) packetInfoButtonPressed:(UIButton*)sender
{
    UITableViewCell *cell = [Rezident finTableViewCell:sender];
    NSIndexPath *selectedIndex = [self.detailView indexPathForCell:cell];

    
//    vcPaketInfo *picker = [[vcPaketInfo alloc] initWithNibName:@"vcPaketInfo" bundle:[NSBundle mainBundle] PPdata:PPPaketInfoData NDdata:NDPaketInfoData];
    vcPaketInfo *picker = [[vcPaketInfo alloc] initWithNibName:@"vcPaketInfo" bundle:[NSBundle mainBundle] packet:self.detailData[selectedIndex.row]];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:picker];
    
    myPopoverController = [[UIPopoverController alloc] initWithContentViewController:nc];
    myPopoverController.delegate = nil;
    myPopoverController.popoverContentSize = CGSizeMake(700, 384);
    
    CGRect frame = [_baseView.view convertRect:sender.frame fromView:sender.superview];
    [myPopoverController presentPopoverFromRect:frame inView:_baseView.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}

- (void) packetCheckClicked:(UIButton*)sender
{
    UITableViewCell* cell = (UITableViewCell*)sender.superview.superview;
    NSIndexPath *ip = [_detailView indexPathForCell:cell];
    
    [_detailView selectRowAtIndexPath:ip animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    sender.selected = YES;
    if(sender.selected)
        [[_detailData objectAtIndex:ip.row] setValue:@"1" forKey:@"CHCK_STATUS_ID"];

}

- (void) loadVybavyData:(UITableViewCell*) cell data:(NSDictionary *)data
{
    cell.detailTextLabel.text = @"";
    BOOL textFieldInCell = [[data valueForKey:@"EDITABLE"]integerValue];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    UITextField *tf = (UITextField *)[cell.contentView viewWithTag:eVYBAVATEXT];
    tf.text = [data valueForKey:@"TEXT"];
    tf.enabled = textFieldInCell;
    
    
    if([[data valueForKey:@"CHECKED"] integerValue])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
}

- (void) loadNabidkyData:(UITableViewCell*) cell data:(NSDictionary *)data
{
    cell.detailTextLabel.text = @"";
    //    NSString *ItemEnum = [data valueForKey:@"ENUM"];
    BOOL textFieldInCell = [[data valueForKey:@"EDITABLE"]integerValue];//(ItemEnum.length > 3 && [[ItemEnum substringToIndex:3]isEqualToString:@"ZZZ"]);
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    UITextField *tf = (UITextField *)[cell.contentView viewWithTag:eVYBAVATEXT];
    tf.text = [data valueForKey:@"TEXT"];
    tf.enabled = textFieldInCell;
    
    
    if([[data valueForKey:@"CHECKED"] integerValue])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    tf = (UITextField *)[cell viewWithTag:eSLUZBAPC];
    tf.enabled = textFieldInCell;
    double pc;
    NSScanner *s;
    if([data objectForKey:@"SELL_PRICE"] != nil)
        s = [NSScanner scannerWithString:[NSString stringWithFormat:@"%@", [data valueForKey:@"SELL_PRICE"]]];
    
    if(s != nil && [s scanDouble:&pc])
    {
        NSNumber *PC = [NSNumber numberWithDouble:pc];
        tf.text = [TRABANT_APP_DELEGATE.numFormat stringFromNumber:PC];
    }
    else if(textFieldInCell)
    {
        tf.text = @"";
        tf.placeholder = NSLocalizedString(@"Cena", nil);
    }
    else
        tf.text = @"";
}

- (void) loadPaketyData:(UITableViewCell*) cell data:(NSDictionary *)data
{
    UILabel *lblTitle = (UILabel *)[cell viewWithTag:eTITLETEXT];
    lblTitle.text = [NSString stringWithFormat:@"%@", [data objectForKey:@"WORKSHOP_PACKET_DESCRIPTION" ]];
    
    UILabel *lblDetail = (UILabel *)[cell viewWithTag:eDETAILTEXT];
    if(existInDic(data, @"RESTRICTIONS"))
        lblDetail.text = [data objectForKey:@"RESTRICTIONS" ];
    cell.detailTextLabel.text = @" ";
    
    BOOL isEconomy = [[data objectForKey:@"ECONOMIC"] boolValue];
    BOOL isAvailable = NO;
    if(existInDic(data, @"SPARE_PART_DISPON_ID"))
        isAvailable = [[data objectForKey:@"SPARE_PART_DISPON_ID"] boolValue];//isEqualToString:@"NOT_AVAILABLE"];
    if(isAvailable)
        cell.imageView.image = (isEconomy)?packetOrangeE: packetOrange;
    else
        cell.imageView.image = (isEconomy)?packetGreenE: packetGreen;
    
    UIButton *btn = (UIButton *)[cell viewWithTag:eOKBTN];
    if(existInDic(data, @"SELL_PRICE")) {
        if([[data objectForKey:@"CHCK_STATUS_ID"] integerValue] == 1)
            [btn setSelected:YES];
        else
            [btn setSelected:NO];
    }
    
    UILabel *tf = (UILabel *)[cell viewWithTag:eCELKYPC];
    NSScanner *s;
    NSNumber *nPC;
    if(existInDic(data, @"SELL_PRICE"))
    {
        id value = [data objectForKey:@"SELL_PRICE"];
        if([value isKindOfClass:[NSNumber class]])
            nPC = value;
        else
        {
            double pc;
            s = [NSScanner scannerWithString:value];
            if(s != nil && [s scanDouble:&pc])
                nPC = [NSNumber numberWithDouble:pc];
        }
    }
    if(nPC != nil && nPC.floatValue >0)
        tf.text = [NSString stringWithFormat:@"%@ %@", [TRABANT_APP_DELEGATE.numFormat stringFromNumber:nPC], [[DMSetting sharedDMSetting].setting valueForKey:@"CURRENCY_ABBREV"]];
    else
        tf.text = @"";
}


- (void)vybavaDidStartEdit:(id)Sender
{
    [ROOTNAVIGATOR setTxtActive:Sender];
    [ROOTNAVIGATOR setTbvcActive:_detailView];
}

- (void)vybavaDidFinishEdit:(id)Sender
{
    //    id obj = [self.detailItem objectForKey:[indexes objectAtIndex:[Sender tag]]];
    //    [eidtedData setVText:[Sender text]];
    //    [_detailData[_detailView.indexPathForSelectedRow.row] setValue:[Sender text] forKey:@"TEXT"];
}

- (void)vybavaDidChanged:(UITextField *)Sender
{
    UITableViewCell* cell = (UITableViewCell *)Sender.superview.superview;
    NSIndexPath *i = [_detailView indexPathForCell:cell];
    UITextField *textField = (UITextField *)Sender;
    
    [_detailData[i.row] setValue:[textField text] forKey:@"TEXT"];
    
    if([textField text].length > 0){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [_detailData[i.row] setValue:@"1" forKey:@"CHECKED"];
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [_detailData[i.row] setValue:@"0" forKey:@"CHECKED"];
    }
    
    [_baseView setStatusOdeslani:NO];
}

- (void)txtPCDidChanged:(id)Sender
{
    UITableViewCell* cell = (UITableViewCell *)[[Sender superview] superview];
    NSIndexPath *i = [_detailView indexPathForCell:cell];
    UITextField *textField = (UITextField *)Sender;
    
    [_detailData[i.row] setValue:[textField text] forKey:@"SELL_PRICE"];
    [_baseView setStatusOdeslani:NO];
}

- (void) vybavaDidSelect:(NSIndexPath *)indexPath
{
    UITableViewCellAccessoryType actualaccessory = [_detailView cellForRowAtIndexPath:indexPath].accessoryType;
    NSMutableDictionary *mData = [_detailData objectAtIndex:indexPath.row];
    //    NSString *ItemEnum = [mData valueForKey:@"ENUM"];
    BOOL textFieldInCell = [[mData valueForKey:@"EDITABLE"]integerValue];//(ItemEnum.length > 3 && [[ItemEnum substringToIndex:3]isEqualToString:@"ZZZ"]);
    if(textFieldInCell)
        return;
    BOOL checked = (actualaccessory == UITableViewCellAccessoryCheckmark);
    
    [_detailView cellForRowAtIndexPath:indexPath].accessoryType = (checked)?UITableViewCellAccessoryNone:UITableViewCellAccessoryCheckmark;
    checked = ([_detailView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryCheckmark);
    [mData setValue:(checked)?@"1":@"0" forKey:@"CHECKED"];
}

- (void) sluzbaDidSelect:(NSIndexPath *)indexPath
{
    UITableViewCellAccessoryType actualaccessory = [_detailView cellForRowAtIndexPath:indexPath].accessoryType;
    NSMutableDictionary *mData = [_detailData objectAtIndex:indexPath.row];
    //    NSString *ItemEnum = [mData valueForKey:@"ENUM"];
    BOOL textFieldInCell = [[mData valueForKey:@"EDITABLE"]integerValue];//(ItemEnum.length > 3 && [[ItemEnum substringToIndex:3]isEqualToString:@"ZZZ"]);
    if(textFieldInCell)
        return;
    BOOL checked = (actualaccessory == UITableViewCellAccessoryCheckmark);
    
    [_detailView cellForRowAtIndexPath:indexPath].accessoryType = (checked)?UITableViewCellAccessoryNone:UITableViewCellAccessoryCheckmark;
    checked = ([_detailView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryCheckmark);
    [mData setValue:(checked)?@"1":@"0" forKey:@"CHECKED"];
}


#pragma mark - nastavenie Celkov

- (void) setCelkyCells:(UITableViewCell*) cell
{
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSIndexPath *i = [_detailView indexPathForCell:cell];
    CGRect r = [_detailView rectForRowAtIndexPath:i];
    float width = r.size.width;
    
    [cell.textLabel setFont:[UIFont fontWithName:@"Verdana-Bold" size:17]];
    [cell.detailTextLabel setFont:[UIFont fontWithName:@"Verdana" size:14]];
    

    UIButton *btnPozad = [[UIButton alloc] initWithFrame:CGRectMake(width - 110, 5, 44, 44)];
    [btnPozad addTarget:self action:@selector(serviceButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [btnPozad setBackgroundImage:servisDisIcon forState:UIControlStateNormal];
    [btnPozad setBackgroundImage:servisDisIcon forState:UIControlStateHighlighted];
    [btnPozad setBackgroundImage:servisIcon forState:UIControlStateSelected];
    btnPozad.tag = eCELKYSLUZBABTN;
    [cell.contentView addSubview:btnPozad];
    
    btnPozad = [[UIButton alloc] initWithFrame:CGRectMake(width - 60, 5, 44, 44)];
    [btnPozad addTarget:self action:@selector(serviceButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [btnPozad setBackgroundImage:odlozeniDisIcon forState:UIControlStateNormal];
    [btnPozad setBackgroundImage:odlozeniDisIcon forState:UIControlStateHighlighted];
    [btnPozad setBackgroundImage:odlozeniIcon forState:UIControlStateSelected];
    btnPozad.tag = eCELKYODLOZBTN;
    [cell.contentView addSubview:btnPozad];
    
    btnPozad = [[UIButton alloc] initWithFrame:CGRectMake(width - 160, 5, 44, 44)];
    [btnPozad addTarget:self action:@selector(serviceButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [btnPozad setBackgroundImage:okDisIcon forState:UIControlStateNormal];
    [btnPozad setBackgroundImage:okDisIcon forState:UIControlStateHighlighted];
    [btnPozad setBackgroundImage:okIcon forState:UIControlStateSelected];
    btnPozad.tag = eOKBTN;
    [cell.contentView addSubview:btnPozad];
    
    UILabel *lblPc = [[UILabel alloc] initWithFrame:CGRectMake(width - 290, 29, 120, 18)];
    lblPc.textAlignment = NSTextAlignmentRight;
    lblPc.backgroundColor = [UIColor clearColor];
    lblPc.font = [UIFont fontWithName:@"Verdana-Bold" size:17];
    lblPc.textColor = [UIColor colorWithRed:0.18 green:0.35 blue:0.7 alpha:1];
    lblPc.tag =eCELKYPC;
    [cell.contentView addSubview:lblPc];
    
    UILabel *lblPozad = [[UILabel alloc] initWithFrame:CGRectMake(width - 610, 29, 320, 18)];
    lblPozad.tag = eCELKYPOZAD;
    lblPozad.backgroundColor = [UIColor clearColor];
    lblPozad.font = [UIFont fontWithName:@"Verdana" size:14];
    lblPozad.textColor = [UIColor colorWithRed:0.18 green:0.35 blue:0.7 alpha:1];
    [cell.contentView addSubview:lblPozad];
    
    [cell layoutSubviews];
    
}

- (void) serviceButtonPressed:(UIButton*)sender
{
    UIView *cellContent = (UIView*)sender.superview;
    UITableViewCell* cell = (UITableViewCell*)cellContent.superview;
    NSIndexPath *ip = [_detailView indexPathForCell:cell];
    UIButton *btnOk = (UIButton*)[cellContent viewWithTag:eOKBTN];
    UIButton *btnOdloz = (UIButton*)[cellContent viewWithTag:eCELKYODLOZBTN];
    UIButton *btnSluzba = (UIButton*)[cellContent viewWithTag:eCELKYSLUZBABTN];
    
    [_detailView selectRowAtIndexPath:ip animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    if(sender.tag != eBTNCLEARROW && ( btnOk.selected || btnOdloz.selected || btnSluzba.selected))
        return;
    
    btnOk.selected = NO;
    btnOdloz.selected = NO;
    btnSluzba.selected = NO;
    
    sender.selected = YES;
    NSLog(@"%d", btnOk.selected);
    
    switch(sender.tag)
    {
        case eBTNCLEARROW:
            [sender removeFromSuperview];
            ((UILabel*)[cell viewWithTag:eCELKYPOZAD]).text = @"";
            ((UILabel*)[cell viewWithTag:eCELKYPC]).text = @"";
            [[_detailData objectAtIndex:ip.row] removeObjectForKey:@"CHCK_REQUIRED_ID"];
            [[_detailData objectAtIndex:ip.row] removeObjectForKey:@"CHCK_STATUS_ID"];
            break;
        case eOKBTN:
            [[_detailData objectAtIndex:ip.row] removeObjectForKey:@"CHCK_REQUIRED_ID"];
            [[_detailData objectAtIndex:ip.row] setValue:@"0" forKey:@"CHCK_STATUS_ID"];
            ((UILabel*)[cell viewWithTag:eCELKYPOZAD]).text = @"";
            ((UILabel*)[cell viewWithTag:eCELKYPC]).text = @"";
            break;
        case eCELKYODLOZBTN:
            [[_detailData objectAtIndex:ip.row] setValue:@"20" forKey:@"CHCK_REQUIRED_ID"];
            [[_detailData objectAtIndex:ip.row] setValue:@"1" forKey:@"CHCK_STATUS_ID"];
            ((UILabel*)[cell viewWithTag:eCELKYPOZAD]).text = @"";
            ((UILabel*)[cell viewWithTag:eCELKYPC]).text = @"";
            break;
        case eCELKYSLUZBABTN:
            [[_detailData objectAtIndex:ip.row] setValue:@"1" forKey:@"CHCK_STATUS_ID"];
            [self setPoziadavkyDataWithIndexPath:ip];
            break;
            
    }
}

- (void) setIconButonForCell:(UITableViewCell*)cell data:(NSDictionary *)data
{
    [self.baseView setStatusOdeslani:NO];
    UIButton *btnSluzba = (UIButton*)[cell viewWithTag:eCELKYSLUZBABTN];
    [btnSluzba setBackgroundImage:servisDisIcon forState:UIControlStateNormal];
    [btnSluzba setBackgroundImage:servisDisIcon forState:UIControlStateHighlighted];
    [btnSluzba setBackgroundImage:servisIcon forState:UIControlStateSelected];
    btnSluzba.selected = NO;
    
    UIButton *btnOK = (UIButton*)[cell viewWithTag:eOKBTN];
    btnOK.selected = NO;
    UIButton *btnOdloz = (UIButton*)[cell viewWithTag:eCELKYODLOZBTN];
    btnOdloz.selected = NO;
    
    NSNumber *castStav, *castPozad;
    castStav = 0;
    castPozad = 0;
    
    
    if(existInDic(data, @"CHCK_STATUS_ID") && ([[data objectForKey:@"CHCK_STATUS_ID"] isKindOfClass:[NSNumber class]] || [[data objectForKey:@"CHCK_STATUS_ID"] length]))
        castStav = [data objectForKey:@"CHCK_STATUS_ID"];
    
    if(existInDic(data, @"CHCK_REQUIRED_ID") && ([[data objectForKey:@"CHCK_REQUIRED_ID"] isKindOfClass:[NSNumber class]] || [[data objectForKey:@"CHCK_REQUIRED_ID"] length]))
        castPozad = [data objectForKey:@"CHCK_REQUIRED_ID"];
    if(existInDic(data, @"WORKSHOP_PACKET"))
    {
        NSDictionary *packet = [data objectForKey:@"WORKSHOP_PACKET"];
        BOOL isEconomy = [[packet objectForKey:@"ECONOMIC"] boolValue];
        BOOL isAvailable = NO;
        if(existInDic(packet, @"SPARE_PART_DISPON_ID"))
            isAvailable = [[packet objectForKey:@"SPARE_PART_DISPON_ID"] boolValue];//[[packet objectForKey:@"DISPONIBILITY"] isEqualToString:@"NOT_AVAILABLE"];
        if(isAvailable)
            [btnSluzba setBackgroundImage:(isEconomy)?packetOrangeE: packetOrange forState:UIControlStateSelected];
        else
            [btnSluzba setBackgroundImage:(isEconomy)?packetGreenE: packetGreen forState:UIControlStateSelected];
        btnSluzba.selected = YES;
        castPozad = [NSNumber numberWithInt:1]; //paket icona
        return;
    }
    
    if(castStav == nil)
        return;
    
    if(castStav == 0)
        castPozad = 0;
    
    switch(castPozad.integerValue)
    {
        case -1:
            break;
        case 0:
            btnOK.selected = YES;
            break;
        case 20:
            btnOdloz.selected = YES;
            break;
        default:
            btnSluzba.selected = YES;
    }
}

- (void) loadCelkyData:(UITableViewCell*) cell data:(NSDictionary *)data
{
    cell.textLabel.text = [data objectForKey:@"CHCK_PART_TXT"];
    cell.detailTextLabel.text = [data objectForKey:@"CHCK_POSITION_ABBREV_TXT"];
    
    [self setIconButonForCell:cell data:data];
    
    UILabel *lb = (UILabel *)[cell viewWithTag:eCELKYPOZAD];
    
    if(existInDic(data, @"CHCK_REQUIRED_TXT") && [[data valueForKey:@"CHCK_REQUIRED_ID"] integerValue] != 20)
        lb.text = [data objectForKey:@"CHCK_REQUIRED_TXT"];
    else
        lb.text = @"";
    
    UILabel *tf = (UILabel *)[cell viewWithTag:eCELKYPC];
    NSScanner *s;
    NSNumber *nPC;
    if(existInDic(data, @"SELL_PRICE"))
    {
        id value = [data objectForKey:@"SELL_PRICE"];
        if([value isKindOfClass:[NSNumber class]])
            nPC = value;
        else
        {
            double pc;
            s = [NSScanner scannerWithString:value];
            if(s != nil && [s scanDouble:&pc])
                nPC = [NSNumber numberWithDouble:pc];
        }
    }
    if(nPC != nil && nPC.floatValue >0)
        tf.text = [NSString stringWithFormat:@"%@ %@", [TRABANT_APP_DELEGATE.numFormat stringFromNumber:nPC], [[DMSetting sharedDMSetting].setting valueForKey:@"CURRENCY_ABBREV"]];
    else
        tf.text = @"";
}

#pragma mark - celky - vyber pozaidavkov

- (void) setPoziadavkyDataWithIndexPath:(NSIndexPath*)ip
{
    NSDictionary *sd = [_detailData objectAtIndex:ip.row];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT DATA.*, PPS.CHCK_STATUS_ID, PPS.CHCK_REQUIRED_ID, PPS.SELL_PRICE "
                     "FROM "
                     "(SELECT ifnull(RL.CHCK_REQUIRED_TXT_LOC, R.CHCK_REQUIRED_TXT_DEF) AS CHCK_REQUIRED_TXT, R.CHCK_REQUIRED_ID "
                     "FROM CHCK_REQUIRED R LEFT OUTER JOIN CHCK_REQUIRED_LOC RL "
                     "ON R.CHCK_REQUIRED_ID = RL.CHCK_REQUIRED_ID AND RL.LANG_ENUM = '%@') DATA, "
                     "CHCK_PART_POSITION_STATUS PPS, CHCK_PART_POSITION PP "
                     "WHERE DATA.CHCK_REQUIRED_ID = PPS.CHCK_REQUIRED_ID "
                     "AND PPS.CHCK_PART_POSITION_ID = PP.CHCK_PART_POSITION_ID "
                     "AND pp.CHCK_PART_ID = %d "
                     "AND pp.CHCK_POSITION_ID = %d "
                     "AND DATA.CHCK_REQUIRED_ID != 20 ", TRABANT_APP_DELEGATE.actualLanguage, [[sd objectForKey:@"CHCK_PART_ID"] intValue], [[sd objectForKey:@"CHCK_POSITION_ID"] intValue]];
    NSArray *pozadArray = [[BaseDBManager sharedBaseDBManager] preformOnStaticDBSelect:sql];
    
    if([DMSetting sharedDMSetting].pakety != nil)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"CHCK_PART_ID.intValue == %d", [[sd objectForKey:@"CHCK_PART_ID"] intValue]];
        NSArray *packetArray = [[DMSetting sharedDMSetting].pakety filteredArrayUsingPredicate:predicate];
        pozadArray =   [pozadArray arrayByAddingObjectsFromArray:packetArray];
    }
    
    
    [self loadPozadavky:[_detailView cellForRowAtIndexPath:ip] data:pozadArray ];// selectedRow:[[sd objectForKey:@"CHCK_REQUIRED_ID"] intValue]];
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    vcSluzbyPicker *picker = [((UINavigationController*)popoverController.contentViewController) viewControllers].lastObject;
    
    NSIndexPath *index = _detailView.indexPathForSelectedRow;
    UITableViewCell *cell = [_detailView cellForRowAtIndexPath:index];
    UILabel *lblPozad = (UILabel*)[cell viewWithTag:eCELKYPOZAD];
    UILabel *txtPC = (UILabel*)[cell viewWithTag:eCELKYPC];
    NSScanner *s;
    NSDictionary *packet = [picker selectedPacked];
    
    if(packet != nil)
    {
        [[_detailData objectAtIndex:index.row] setValue:packet forKey:@"WORKSHOP_PACKET"];
        NSString *text = [packet valueForKey:@"WORKSHOP_PACKET_DESCRIPTION"];
        if(existInDic(packet, @"RESTRICTIONS"))
            text = [text stringByAppendingFormat:@" %@", [packet valueForKey:@"RESTRICTIONS"]];
        [[_detailData objectAtIndex:index.row] setValue:text forKey:@"CHCK_REQUIRED_TXT"];
        [[_detailData objectAtIndex:index.row] setValue:@19 forKey:@"CHCK_REQUIRED_ID"];
        lblPozad.text = text;
    }
    else if(picker.serviceID)
    {
        [[_detailData objectAtIndex:index.row] setValue:picker.serviceID forKey:@"CHCK_REQUIRED_ID"];
        [[_detailData objectAtIndex:index.row] setValue:picker.serviceText forKey:@"CHCK_REQUIRED_TXT"];
        lblPozad.text = picker.serviceText;
    }
    
    s = [NSScanner localizedScannerWithString:picker.pc];
    [[_detailData objectAtIndex:index.row] setValue:picker.pc forKey:@"SELL_PRICE"];
    
    double pc;
    if([s scanDouble:&pc])
    {
        NSNumber *num = [NSNumber numberWithDouble:pc];
        NSString* pcStr = [TRABANT_APP_DELEGATE.numFormat stringFromNumber:num];
        NSString* mena = [[DMSetting sharedDMSetting].setting valueForKey:@"CURRENCY_ABBREV"];
        txtPC.text = [NSString stringWithFormat:@"%@ %@", pcStr, mena] ;
    }
    else
        txtPC.text = @"";
    
    [[_detailData objectAtIndex:index.row] setValue:[NSNumber numberWithInt:1] forKey:@"CHCK_STATUS_ID"];
    
    [self setIconButonForCell:cell data:[_detailData objectAtIndex:index.row]];
    
    [self.baseView setStatusOdeslani:NO];
    
    return YES;
}

- (void)loadPozadavky:(id)sender data:(NSArray*)data// selectedRow:(NSInteger)selectedRow
{
    
    UITableViewCell *cell = (UITableViewCell*)sender;
    pozadData = data;
    vcSluzbyPicker *picker = [[vcSluzbyPicker alloc] initWithNibName:@"vcSluzbyPicker" bundle:[NSBundle mainBundle] data:pozadData selectedRow:0];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:picker];
    
    myPopoverController = [[UIPopoverController alloc] initWithContentViewController:nc];
    myPopoverController.delegate = self;
    myPopoverController.popoverContentSize = CGSizeMake(839, 364 + _baseView.navigationController.navigationBar.frame.size.height);//384);
    
    UIButton *b = (UIButton*)[cell.contentView viewWithTag:eCELKYSLUZBABTN];
    CGRect r = [cell convertRect:b.frame toView:_baseView.view];
    
    CGSize nrSize = CGSizeMake(839, 44);;
    UIImage *img = [UIImage imageNamed:@"alu_texture_navigation.png"];
    
    UIGraphicsBeginImageContext(nrSize);
    [img drawInRect:CGRectMake(0, 0, nrSize.width, nrSize.height)];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [nc.navigationBar setBarStyle:UIBarStyleDefault];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [nc.navigationBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
    
    if([cell.detailTextLabel.text isEqualToString:@"-"])
        picker.title = [NSString stringWithFormat:@"%@ - %@", _unitName, cell.textLabel.text];
    else
        picker.title = [NSString stringWithFormat:@"%@ - %@, %@", _unitName, cell.textLabel.text, cell.detailTextLabel.text ];
    
//    [nc.navigationItem setTitle:];
//    nc.navigationBar.topItem.title =
    
    [myPopoverController presentPopoverFromRect:r inView:_baseView.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_dataType == eCELKY || _dataType == ePAKETY)
        return YES;
    else
        return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete){
        // Delete song from list & disc
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        
        UIButton *btnOk = (UIButton*)[cell viewWithTag:eOKBTN];
        btnOk.selected = NO;
        
        NSInteger row = indexPath.row;
        [[_detailData objectAtIndex:row] removeObjectForKey:@"CHCK_STATUS_ID"];
        
        if(_dataType == eCELKY) {
            UIButton *btnOdloz = (UIButton*)[cell viewWithTag:eCELKYODLOZBTN];
            UIButton *btnSluzba = (UIButton*)[cell viewWithTag:eCELKYSLUZBABTN];
            UILabel *txtPC = (UILabel*)[cell viewWithTag:eCELKYPC];
            btnOdloz.selected = NO;
            btnSluzba.selected = NO;
            UILabel *lb = (UILabel *)[cell viewWithTag:eCELKYPOZAD];
            lb.text = @"";
            txtPC.text = @"";
            [btnSluzba setBackgroundImage:servisIcon forState:UIControlStateSelected];
            
            [[_detailData objectAtIndex:row] removeObjectForKey:@"WORKSHOP_PACKET"];
            [[_detailData objectAtIndex:row] removeObjectForKey:@"CHCK_REQUIRED_TXT"];
            [[_detailData objectAtIndex:row] removeObjectForKey:@"CHCK_REQUIRED_ID"];
            [[_detailData objectAtIndex:row] removeObjectForKey:@"SELL_PRICE"];
        }
    }
}

- (void) setDataType:(NSInteger)type
{
    _dataType = type;
}

@end
