//
//  VCBaseGrid.m
//  DirectCheckin
//
//  Created by Jan Kubis on 21.01.13.
//
//

#import "VCBaseGrid.h"
#import "DMSetting.h"
#import "TrabantAppDelegate.h"
#import "DejalActivityView.h"
#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])

@interface BaseNavBarTitle : UILabel
{
    CGRect initFrame;
}

@end

@implementation BaseNavBarTitle

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        initFrame = frame;
    }
    return self;
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:initFrame];
}

@end

@interface myTableCell : UITableViewCell

@end

@implementation myTableCell

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0, 0, 10, 30);
}

@end


@implementation Column

@synthesize frame = _frame;
@synthesize textAlignment = _textAlignment;
@synthesize backgroundColor = _backgroundColor;
@synthesize caption = _caption;
@synthesize dictEnum = _dictEnum;
@synthesize textColor = _textColor;

-(id)initWithFrame:(CGRect)newFrame
{
    self = [super init];
    if(self)
    {
        self.frame = newFrame;
    }
    return self;
}

@end

@interface VCBaseGrid () <UITableViewDelegate, UITableViewDataSource>
{
@protected
    UITableView *gridTableView;
    CGRect viewFrame;
    NSInteger startPos;
}
- (void) setColumns;
- (void) setGrid;
//- (void) createGridWithCell:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath;
- (void) createGridFromColumsWithCell:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath;
//- (void) loadDataToCell:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath;
- (void) loadColumnDataToCell:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath;
- (NSDictionary*)getDataWithIndexPath:(NSIndexPath*)indexPath;
@end

@implementation VCBaseGrid
@synthesize columnsCaptions=_columnsCaptions;
@synthesize columnsWidth=_columnsWidth;
@synthesize columnsCaptionsHeight=_columnsCaptionsHeight;
@synthesize gridData = _gridData;
@synthesize columnsSort = _columnsSort;
@synthesize gridType = _gridType;
@synthesize gridRowHeight = _gridRowHeight;
@synthesize columnsTextAligment = _columnsTextAligment;
@synthesize viewTitle = _viewTitle;
@synthesize showNavBar = _showNavBar;
@synthesize columns=_columns;
@synthesize cellSelectionStyle=_cellSelectionStyle;


-(id)initWithFrame:(CGRect)r
{
    self = [super init];
    
    if(self)
    {
        // Custom initialization
        viewFrame = r;
        self.columnsCaptionsHeight = 0;
        self.gridRowHeight = 30;
        self.showNavBar = YES;
        self.columns = [[NSArray alloc] init];
        self.cellSelectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"pozadie_ciste"]]];

    if(_showNavBar)
        [self loadNavBar];
    [self setGrid];
    [self setColumns];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view layoutSubviews];
    [DejalBezelActivityView removeViewAnimated:YES];
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
    _columnsWidth = nil;
    _columnsCaptions = nil;
    _gridData = nil;
    _columnsSort = nil;
    _columnsTextAligment = nil;
    _columnsFont = nil;
    _columns = nil;
    [super viewDidUnload];
}

- (void)setColumnsFromColumnsArray
{
    startPos = 0;
    NSInteger i=0;
//    CGFloat Y = self.navigationController.navigationBar.frame.size.height;
    
    for(Column *c in _columns)
    {
        CGRect r;
        if(startPos==0)
            r = CGRectMake(startPos, 0, c.frame.size.width + 10, _columnsCaptionsHeight);
        else
            r = CGRectMake(startPos+1, 0, c.frame.size.width+9, _columnsCaptionsHeight);
        UILabel *lblCap = [[UILabel alloc] initWithFrame:r];
        lblCap.text = c.caption;
        lblCap.backgroundColor = [UIColor colorWithRed:0.97 green:0.92 blue:0.51 alpha:0.5];
        lblCap.textAlignment = NSTextAlignmentCenter;
        lblCap.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];
        [self.view addSubview:lblCap];
        
        r = CGRectMake(startPos+c.frame.size.width+10, 0, 1, self.view.frame.size.height);
        UIView *v = [[UIView alloc] initWithFrame:r];
        v.backgroundColor = gridTableView.separatorColor;
        [self.view insertSubview:v aboveSubview:self.view.subviews.lastObject];
        
        startPos += c.frame.size.width+10;
        i++;
    }
}

- (void)setColumns
{
    startPos = 0;
    
    if(_columns.count)
    {
        [self setColumnsFromColumnsArray];
        return;
    }
}

- (void)setGrid
{
    NSInteger height = viewFrame.size.height - _columnsCaptionsHeight /*- self.navigationController.navigationBar.frame.size.height*/;
    CGRect r = CGRectMake(0, _columnsCaptionsHeight, viewFrame.size.width, height);
    gridTableView = [[UITableView alloc] initWithFrame:r];
    gridTableView.delegate = self;
    gridTableView.dataSource = self;
    gridTableView.backgroundColor = [UIColor clearColor];
    if([gridTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [gridTableView setSeparatorInset:UIEdgeInsetsZero];
        gridTableView.layoutMargins = UIEdgeInsetsZero;
    }
    [self.view addSubview:gridTableView];
    [self.view layoutSubviews];
}

- (void)btnLeftClick:(id) Sender {
    [[self parentViewController] dismissViewControllerAnimated:YES completion:nil];
}

-(void) loadNavBar
{
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    
    CGRect nr = self.navigationController.navigationBar.frame;
    nr.size.width = viewFrame.size.width;
    UIImage *img = [UIImage imageNamed:@"alu_texture_navigation.png"];
    
    UIGraphicsBeginImageContext(CGSizeMake(nr.size.width, nr.size.height));
    [img drawInRect:nr];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.navigationController.navigationBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];

    CGRect r = self.navigationController.navigationBar.frame;
    BaseNavBarTitle *_lblNavBar = [[BaseNavBarTitle alloc] initWithFrame:CGRectMake(0, 0, viewFrame.size.width, r.size.height)];
    _lblNavBar.text = _viewTitle;
    _lblNavBar.lineBreakMode = NSLineBreakByTruncatingTail;
    _lblNavBar.backgroundColor = [UIColor clearColor];
    _lblNavBar.textColor = [UIColor whiteColor];
    _lblNavBar.font = [UIFont fontWithName:@"Verdana" size:25 ];
    _lblNavBar.textAlignment = NSTextAlignmentCenter;
    _lblNavBar.clipsToBounds = NO;
    _lblNavBar.numberOfLines = 0;
    _lblNavBar.adjustsFontSizeToFitWidth = NO;
    self.navigationItem.titleView = _lblNavBar;
    
    UIImage *btnImg = [[UIImage imageNamed:@"tlacitko"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16)];
    UIBarButtonItem *btnNavleft = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(btnLeftClick:)];
    [btnNavleft setTitleTextAttributes: @{NSFontAttributeName : [UIFont fontWithName:@"Verdana-Bold" size:12.0]
                                          , NSForegroundColorAttributeName:[UIColor whiteColor]}
                              forState:UIControlStateNormal];
    [btnNavleft setBackgroundImage:btnImg forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [btnNavleft setBackgroundImage:btnImg forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [btnNavleft setBackgroundImage:btnImg forState:UIControlStateDisabled barMetrics:UIBarMetricsDefault];
    
    [self.navigationItem setLeftBarButtonItem:btnNavleft animated:NO];
}

- (UITableView *)gridTableView
{
    return self.gridTableView;
}

- (void) setSelectRow:(NSIndexPath*)indexPath;
{
    [gridTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}

-(Column*) addColumnWithSize:(CGSize)cellSize textAlign:(NSTextAlignment)textAlign
{
    CGRect r = CGRectMake(5, 0, cellSize.width - 10, cellSize.height);
    if(_columns.count > 0)
    {
        Column *c = (Column *)_columns.lastObject;
        r.origin.x += c.frame.origin.x + c.frame.size.width + 5;
    }
    Column *c = [[Column alloc] initWithFrame:r];
    c.backgroundColor = [UIColor clearColor];
    c.textAlignment = textAlign;
    c.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    c.textColor = [UIColor blackColor];
    _columns = [_columns arrayByAddingObject:c];
    
    return c;
}

#pragma mark -
#pragma mark Table view data source
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:
                                 CGRectMake(0, 0, tableView.frame.size.width, 20.0)];
    sectionHeaderView.backgroundColor = [UIColor colorWithRed:0.923 green:0.923 blue:0.925 alpha:1];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:
                            CGRectMake(0, 0, sectionHeaderView.bounds.size.width, sectionHeaderView.bounds.size.height)];
    
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textAlignment = NSTextAlignmentRight;
    [headerLabel setFont:[UIFont fontWithName:@"Verdana" size:20.0]];
    [headerLabel setTextColor: [UIColor whiteColor]];
    [sectionHeaderView addSubview:headerLabel];
    
    [self setCaptions:headerLabel inSection:section];
    
    return sectionHeaderView;
}

-(void) setCaptions:(UILabel*)label inSection:(NSInteger)section
{
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return _gridData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return _gridRowHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.imageView.backgroundColor = [UIColor clearColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"ROW_ID";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[myTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = _cellSelectionStyle;
        [self createGridFromColumsWithCell:cell indexPath:indexPath];
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.backgroundColor = [UIColor clearColor];
        
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor colorWithRed:(119.0/255.0) green:(156.0/255.0) blue:(164.0/255.0) alpha:1.0];//[UIColor colorWithRed:(76.0/255.0) green:(161.0/255.0) blue:(255.0/255.0) alpha:1.0]; // perfect color suggested by @mohamadHafez
        bgColorView.layer.masksToBounds = YES;
        cell.selectedBackgroundView = bgColorView;
    }
    [self addExtraViewsToCell:cell rowAtIndexPath:indexPath];
    
    [self loadColumnDataToCell:cell indexPath:indexPath];
    return cell;
}

- (void)addExtraViewsToCell:(UITableViewCell*)cell rowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(id)getDataWithIndexPath:(NSIndexPath*)indexPath
{
    return _gridData[indexPath.row];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    id data = [self getDataWithIndexPath:indexPath];
    
    if([self.baseGridDelegate  respondsToSelector:@selector(baseGridSelected:data:)])
        [self.baseGridDelegate baseGridSelected:self data:data];
}


#pragma mark -
#pragma mark grid creatin methods
- (void) createGridFromColumsWithCell:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath;
{
    NSInteger i=0;
    
    for(Column *c in _columns)
    {
        UILabel *lblCap = [[UILabel alloc] initWithFrame:c.frame];
        lblCap.font = c.font;
        lblCap.textColor = c.textColor;
        lblCap.highlightedTextColor = [UIColor whiteColor];
        lblCap.textAlignment = c.textAlignment;
        lblCap.tag = i+1;
        lblCap.backgroundColor = c.backgroundColor;
        [cell.contentView addSubview:lblCap];
        i++;
    }
    
}

- (void) loadColumnDataToCell:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath
{
    NSInteger i=0;
    id data = [self getDataWithIndexPath:indexPath];
    BOOL isString = ([data isKindOfClass:[NSString class]]);
    BOOL isNumber = NO;
    
    
    for(Column *c in _columns)
    {
        UILabel *lblCap = (UILabel*)[cell viewWithTag:i+1];
        isNumber = [[data objectForKey:c.dictEnum] isKindOfClass:[NSNumber class]];
        
        if(existInDic(data, c.dictEnum))
            lblCap.text = (isString)?data:(isNumber)?[NSString stringWithFormat:@"%@", [data objectForKey:c.dictEnum]]:[data objectForKey:c.dictEnum];
        else
            lblCap.text = @"";
        i++;
    }
}

@end
