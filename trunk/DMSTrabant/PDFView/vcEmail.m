//
//  vcEmail.m
//  DirectCheckin
//
//  Created by Jan Kubis on 09.09.14.
//
//

#import "vcEmail.h"
#import "WSDCHIDataTransfer.h"
#import "DMSetting.h"
#import "TrabantAppDelegate.h"
#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])

@interface vcEmail ()
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPredmet;
@property (weak, nonatomic) IBOutlet UITextView *txtMessage;

@end

@implementation vcEmail

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
    
    self.navigationController.title = NSLocalizedString(@"Email", nil);
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"pozadie_ciste.png"]]];
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    UIImage *img = [Rezident imageWithImage:[UIImage imageNamed:@"alu_texture_navigation.png"] scaledToSize:self.navigationController.navigationBar.frame.size];
    [self.navigationController.navigationBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
    
    NSString *localizedStr = NSLocalizedString(@"Back", @"back");
    UIImage *btnImg = [[UIImage imageNamed:@"tlacitko"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16)];
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:localizedStr style:UIBarButtonItemStyleBordered target:self action:@selector(loadBack:)];
    [back setTitleTextAttributes: @{NSFontAttributeName : [UIFont fontWithName:@"Verdana-Bold" size:12.0]
                                    , NSForegroundColorAttributeName:[UIColor whiteColor]}
                        forState:UIControlStateNormal];
    [back setBackgroundImage:btnImg forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [back setBackgroundImage:btnImg forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [back setBackgroundImage:btnImg forState:UIControlStateDisabled barMetrics:UIBarMetricsDefault];
    
    localizedStr = NSLocalizedString(@"Send email", @"Send email");
    UIBarButtonItem *send = [[UIBarButtonItem alloc] initWithTitle:localizedStr style:UIBarButtonItemStyleBordered target:self action:@selector(loadNext:)];
    [send setTitleTextAttributes: @{NSFontAttributeName : [UIFont fontWithName:@"Verdana-Bold" size:12.0]
                                    , NSForegroundColorAttributeName:[UIColor whiteColor]}
                        forState:UIControlStateNormal];
    [send setBackgroundImage:btnImg forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [send setBackgroundImage:btnImg forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [send setBackgroundImage:btnImg forState:UIControlStateDisabled barMetrics:UIBarMetricsDefault];

    [self.navigationItem setLeftBarButtonItem:back];
    [self.navigationItem setRightBarButtonItem:send];
    if([[DMSetting sharedDMSetting].vozidlo valueForKey:@"CUSTOMER_CONTACT_EMAIL"] != [NSNull null])
        _txtEmail.text = [[DMSetting sharedDMSetting].vozidlo valueForKey:@"CUSTOMER_CONTACT_EMAIL"];
    _txtPredmet.text = [NSString stringWithFormat: NSLocalizedString(@"email predmet", nil), [[DMSetting sharedDMSetting].vozidlo valueForKey:@"VIN"], [[DMSetting sharedDMSetting].vozidlo valueForKey:@"CHECKIN_NUMBER"]];
    _txtMessage.text = [NSString stringWithFormat: NSLocalizedString(@"email sprava", nil),
                        [[DMSetting sharedDMSetting].vozidlo valueForKey:@"VEHICLE_DESCRIPTION"],
                        [[DMSetting sharedDMSetting].vozidlo valueForKey:@"LICENSE_TAG"],
                        [[DMSetting sharedDMSetting].vozidlo valueForKey:@"VIN"],
                        [NSString stringWithFormat:@"%@ %@", [[DMSetting sharedDMSetting].loggedUser valueForKey:@"NAME"], [[DMSetting sharedDMSetting].loggedUser valueForKey:@"SURNAME"]],
                        [[DMSetting sharedDMSetting].loggedUser valueForKey:@"DEPARTMENT_NAME"]];
}

-(void)viewWillAppear:(BOOL)animated
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
    _lblNavBar.text = NSLocalizedString(@"Odoslanie emailu", nil);
    _lblNavBar.lineBreakMode = NSLineBreakByTruncatingTail;
    _lblNavBar.backgroundColor = [UIColor clearColor];
    _lblNavBar.textColor = [UIColor whiteColor];
    _lblNavBar.font = [UIFont fontWithName:@"Verdana" size:25 ];
    _lblNavBar.textAlignment = NSTextAlignmentCenter;
    _lblNavBar.clipsToBounds = NO;
    _lblNavBar.numberOfLines = 0;
    _lblNavBar.adjustsFontSizeToFitWidth = NO;
    self.navigationItem.titleView = _lblNavBar;
    
    [self updateViewConstraints];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadBack:(id) Sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadNext:(id) Sender {
    NSString *emailMessage = [[_txtMessage.text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@"\r\n"];
    [[WSDCHIDataTransfer sharedWSDCHIDataTransfer] startSendEmail:_txtEmail.text subject:_txtPredmet.text message:emailMessage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidUnload {
    [self setTxtEmail:nil];
    [self setTxtPredmet:nil];
    [self setTxtMessage:nil];
    [super viewDidUnload];
}
@end
