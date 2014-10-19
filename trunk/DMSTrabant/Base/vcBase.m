//
//  vcBase.m
//  Direct checkin
//
//  Created by Jan Kubis on 09.10.12.
//  Copyright (c) 2012 jan.kubis@t-systems.cz. All rights reserved.
//

#import "vcBase.h"
#import "TrabantAppDelegate.h"
#import "DejalActivityView.h"
#import "DMSetting.h"
#import "ZoomingPDFViewerViewController.h"
#import "vcTrabantInfo.h"
#import "vcNabidky.h"
#import "vcPDFImageViewver.h"

#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])
#define ROOTNAVIGATOR ([TRABANT_APP_DELEGATE rootNavController])


@implementation NAVLabel

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];//CGRectMake(212, 10, 600, 25)];
}

@end



@interface vcBase()
- (void) loadNavBar;

@end


@implementation vcBase
@synthesize enableSave, btnSaveInfo, lblNavBar=_lblNavBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) setEnableSave:(BOOL)newVal
{
    enableSave = newVal;
    if(enableSave == NO)
    {
        if(self.navigationController.tabBarItem.badgeValue == nil)
            self.navigationController.tabBarItem.badgeValue = @"";
    }
    else
        self.navigationController.tabBarItem.badgeValue = nil;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) EnabledAllComponentsForSelector:(id)newEnableId
{
    BOOL newEnable = (newEnableId!=nil);
    [self EnabledAllComponents:newEnable];
}

- (void) EnabledAllComponents:(BOOL)newEnable
{
    if(!newEnable && [DejalBezelActivityView currentActivityView] != nil)
        return;
    
    if(newEnable)
        [DejalBezelActivityView removeViewAnimated:YES];
    else
        [DejalBezelActivityView activityViewForView:TRABANT_APP_DELEGATE.rootNavController.view];
}

- (void) dealloc
{
    intSetting = nil;
    btnSaveInfo = nil;
}

- (NSString *)parseXML
{
    return nil;
}

- (void) refreshData
{
    if(vPoznamka != nil)
        [vPoznamka performSelector:@selector(refreshData) ];
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
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"alu_texture_navigation.png"] forBarMetrics:UIBarMetricsDefault];
    intSetting = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    btnSaveInfo = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSaveInfo.frame = CGRectMake(.0, .0, 24.0, 24.0);
    btnSaveInfo.userInteractionEnabled = NO;
    [btnSaveInfo setBackgroundImage:[UIImage imageNamed:@"disketa_r"] forState:UIControlStateNormal];
    [btnSaveInfo setBackgroundImage:[UIImage imageNamed:@"disketa_r"] forState:UIControlStateHighlighted];
    [btnSaveInfo setBackgroundImage:[UIImage imageNamed:@"disketa_g"] forState:UIControlStateSelected];
    
    [self loadNavBar];
    
    if((existInDic([DMSetting sharedDMSetting].vozidlo, @"CHECKIN_ID") && [[[DMSetting sharedDMSetting].vozidlo valueForKey:@"CHECKIN_ID"] integerValue] > 0) )
        enableSave = YES;
    else
        enableSave = NO;
    
//    UIView *v = ((UIView *) self.view.subviews.lastObject).subviews.lastObject;
//    NSInteger Y = self.navigationController.navigationBar.frame.size.height + v.frame.origin.x + v.frame.size.height + 24;
    
    btnPoz = [[UIButton alloc] initWithFrame:CGRectMake(793, 711, 108, 42)];
    
    [btnPoz setBackgroundImage:[UIImage imageNamed:@"zalozka1_p.png"] forState:UIControlStateNormal];
    [btnPoz setBackgroundImage:[UIImage imageNamed:@"zalozka1_p.png"] forState:UIControlStateHighlighted];
    [btnPoz setBackgroundImage:[UIImage imageNamed:@"zalozka1_a.png"] forState:UIControlStateSelected];
    [btnPoz setBackgroundImage:[btnPoz backgroundImageForState:btnPoz.state] forState:UIControlStateHighlighted];
    [btnPoz addTarget:self action:@selector(loadPoznamka:) forControlEvents:UIControlEventTouchUpInside];
    
    btnHlav = [[UIButton alloc] initWithFrame:CGRectMake(901, 711, 108, 42)];
    [btnHlav setBackgroundImage:[UIImage imageNamed:@"zalozka2_p.png"] forState:UIControlStateNormal];
    [btnHlav setBackgroundImage:[UIImage imageNamed:@"zalozka2_p.png"] forState:UIControlStateHighlighted];
    [btnHlav setBackgroundImage:[UIImage imageNamed:@"zalozka2_a.png"] forState:UIControlStateSelected];
    [btnHlav addTarget:self action:@selector(closePoznamka:) forControlEvents:UIControlEventTouchUpInside];
    btnHlav.selected = YES;
    [btnHlav setBackgroundImage:[btnHlav backgroundImageForState:btnPoz.state] forState:UIControlStateHighlighted];

    
}

- (IBAction)loadPoznamka:(id)sender
{
    btnHlav.selected = NO;
    btnPoz.selected = YES;
//    [btnHlav setBackgroundImage:[btnHlav backgroundImageForState:UIControlStateNormal] forState:UIControlStateNormal];
//    [btnPoz setBackgroundImage:[btnPoz backgroundImageForState:UIControlStateSelected] forState:UIControlStateNormal];
    
    if(vPoznamka == nil)
        vPoznamka = [[vcPoznamka alloc] initWithNibName:@"vcPoznamka" bundle:[NSBundle mainBundle]];
    
    if([vMain.subviews containsObject:vPoznamka.view])
        return;
    
    CGRect r = CGRectMake(0, 0, 0, 0);
    r.size = vMain.frame.size;
    vPoznamka.view.frame = r;
    
//    ((UIImageView *)[self.view viewWithTag:eSPONA]).hidden = YES;
    [UIView beginAnimations:@"PozPartialPageCurlEffect" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:1];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:vMain cache:YES];
    [UIView setAnimationDidStopSelector:@selector(pozAniDone:finished:context:)];
    
    [vMain addSubview:vPoznamka.view];
    
    [UIView commitAnimations];
    
}

- (IBAction)closePoznamka:(id)sender
{
    btnHlav.selected = YES;
    btnPoz.selected = NO;
//    [btnHlav setBackgroundImage:[btnHlav backgroundImageForState:UIControlStateSelected] forState:UIControlStateNormal];
//    [btnPoz setBackgroundImage:[btnPoz backgroundImageForState:UIControlStateNormal] forState:UIControlStateNormal];
    
    if(vPoznamka != nil && [vMain.subviews containsObject:vPoznamka.view])
    {
//        ((UIImageView *)[self.view viewWithTag:eSPONA]).hidden = YES;
        [UIView beginAnimations:@"MainPartialPageCurlEffect" context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:1];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:vMain cache:YES];
        [UIView setAnimationDidStopSelector:@selector(pozAniDone:finished:context:)];
        
        [vMain.subviews.lastObject removeFromSuperview];
        
        [UIView commitAnimations];
        
        vPoznamka = nil;
        return;
    }
}

- (void) pozAniDone:(NSString *) aniname finished:(BOOL) finished context:(void *) context
{
    ((UIImageView *)[self.view viewWithTag:eSPONA]).hidden = NO;
//    if ([aniname isEqualToString:@"PozPartialPageCurlEffect"]) {
//        
//    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataChanged:) name:@"dataRespondNotification" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataDidSave:) name:@"dataSavedNotification" object: nil];
    [self.navigationController.tabBarController.view addSubview:btnHlav];
    [self.navigationController.tabBarController.view addSubview:btnPoz];
    vMain = [self.view viewWithTag:eBASEVIEW];
    self.lblNavBar.text = ROOTNAVIGATOR.vozCaption;
}

- (void) viewDidAppear:(BOOL)animated
{
    NSLog(@"base did apear");
    [super viewDidAppear:animated];
    NSLog(@"base did apear done");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [menu.menu dismissWithClickedButtonIndex:-1 animated:YES];
    [btnHlav removeFromSuperview];
    [btnPoz removeFromSuperview];
    if([vMain.subviews containsObject:vPoznamka.view])
        [vMain.subviews.lastObject removeFromSuperview];
    btnHlav.selected = YES;
    btnPoz.selected = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self]; //dataRespondNotification, dataSavedNotification
}

-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    btnNavleft = nil;
    btnNavright = nil;
    btnNavBarSave = nil;
    
    vMain = nil;;
    btnPoz = nil;
    btnHlav = nil;
    menu = nil;
    vPoznamka = nil;
    intSetting = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
//    return YES;
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight
            || interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void) setStatusOdeslani:(BOOL)odeslani
{
    for(UINavigationController *nc in self.tabBarController.viewControllers)
    {
        vcBase *vcb = nc.viewControllers.lastObject;
        vcb.btnSaveInfo.selected = odeslani;
    }
}

-(BOOL) statusOdeslani
{
    return btnSaveInfo.selected;
}

-(void) loadNavBar
{
    if(_lblNavBar == nil)
    {
        _lblNavBar = [[NAVLabel alloc] initWithFrame:CGRectMake(0, 0, 600, 25)];
        _lblNavBar.text = ROOTNAVIGATOR.vozCaption;
        _lblNavBar.lineBreakMode = NSLineBreakByTruncatingTail;
        _lblNavBar.backgroundColor = [UIColor clearColor];
        _lblNavBar.textColor = [UIColor whiteColor];
        _lblNavBar.font = [UIFont fontWithName:@"Verdana" size:25 ];
        _lblNavBar.textAlignment = NSTextAlignmentCenter;
        _lblNavBar.clipsToBounds = NO;
        _lblNavBar.numberOfLines = 0;
        _lblNavBar.adjustsFontSizeToFitWidth = NO;
        self.navigationItem.titleView = _lblNavBar;
    }
    
    
    btnNavBarSave = [[UIBarButtonItem alloc] initWithCustomView:btnSaveInfo];
    btnNavBarSave.tag = 12;
    
    NSString *localizedStr = NSLocalizedString(@"Menu", @"tlacitko odhlasenia");//@"Menu";
    UIImage *btnImg = [[UIImage imageNamed:@"tlacitko"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16)];
    btnNavright = [[UIBarButtonItem alloc] initWithTitle:localizedStr style:UIBarButtonItemStyleBordered target:self action:@selector(btnRightClick:)];
    [btnNavright setTitleTextAttributes: @{NSFontAttributeName : [UIFont fontWithName:@"Verdana-Bold" size:12.0]
                                           , NSForegroundColorAttributeName:[UIColor whiteColor]}
                               forState:UIControlStateNormal];
    [btnNavright setBackgroundImage:btnImg forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [btnNavright setBackgroundImage:btnImg forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [btnNavright setBackgroundImage:btnImg forState:UIControlStateDisabled barMetrics:UIBarMetricsDefault];
    
    localizedStr = NSLocalizedString(@"LogOff btn", @"tlacitko odhlasenia");
    btnNavleft = [[UIBarButtonItem alloc] initWithTitle:localizedStr style:UIBarButtonItemStyleBordered target:self action:@selector(btnLeftClick:)];
    [btnNavleft setTitleTextAttributes: @{NSFontAttributeName : [UIFont fontWithName:@"Verdana-Bold" size:12.0]
                                           , NSForegroundColorAttributeName:[UIColor whiteColor]}
                               forState:UIControlStateNormal];
    [btnNavleft setBackgroundImage:btnImg forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [btnNavleft setBackgroundImage:btnImg forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [btnNavleft setBackgroundImage:btnImg forState:UIControlStateDisabled barMetrics:UIBarMetricsDefault];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: btnNavright, btnNavBarSave, nil];
    [self.navigationItem setLeftBarButtonItem:btnNavleft animated:NO];
    btnSaveInfo.selected =  ((vcBase*)[[self.tabBarController.viewControllers objectAtIndex:0] viewControllers].lastObject).statusOdeslani;
    
}

- (void)btnLeftClick:(id) Sender {
//    [webServices sharedwebServices];
    [[DMSetting sharedDMSetting] clearAllData];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TRABANT_APP_DELEGATE setChecking_id:-1];
    [ROOTNAVIGATOR popToRootViewControllerAnimated:YES];
}

- (void)btnRightClick:(id) Sender
{
    if(!(menu && menu.menu.visible))
        menu = [[vcMenu alloc]initAndShowInView:Sender];
}

- (void)dataChanged:(NSNotification *)notification
{
    NSLog(@"data changet");
    if([notification.object isEqualToString:@"StaticDataUpdate"])
    {
        [ROOTNAVIGATOR releaseData];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:NSLocalizedString(@"StaticDataUpdate", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    } else if([notification.object isEqualToString:@"ChiReport"])
    {
        [self setStatusOdeslani:YES];
        [self refreshData];
        [self showProtocol];
    }
    [self EnabledAllComponents:YES];
    NSLog(@"data changet done ");
}

-(void)showProtocol
{
    [self setStatusOdeslani:YES];
    UITabBarController *rootTBC = TRABANT_APP_DELEGATE.rootNavController.viewControllers.lastObject;
    UINavigationController *nc = (UINavigationController *)rootTBC.selectedViewController;
    UIViewController *vc = nc.viewControllers.lastObject;

//    NSString *pdfFilePAth = [DMSetting sharedDMSetting].pdfReportFilePath;
    
    vcPDFImageViewver *zvc = [[vcPDFImageViewver alloc] init];
//    [zvc.view setFrame:CGRectMake(0,0,1000, 700)];
    
//    ZoomingPDFViewerViewController *zvc = [[ZoomingPDFViewerViewController alloc] initWithNibName:@"ZoomingPDFViewerViewController" bundle:[NSBundle mainBundle] PDFData:pdfData];
    [zvc setModalPresentationStyle:UIModalPresentationFormSheet];
    
    UINavigationController *ncPicker = [[UINavigationController alloc] initWithRootViewController:zvc];
    ncPicker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [ncPicker setModalPresentationStyle:UIModalPresentationFormSheet];
    [nc presentViewController:ncPicker animated:YES completion:nil];
    ncPicker.preferredContentSize = CGSizeMake(1000, 680);
    ncPicker.view.superview.center = CGPointMake(vc.view.superview.center.x, vc.view.superview.center.y);
    [self EnabledAllComponents:YES];
}

- (void)dataDidSave:(NSNotification *)notification
{
    if([notification.object isEqualToString:@"ErrorSaveCheckin"])
    {
        [self EnabledAllComponents:YES];
        return;
    }
    
    [self setStatusOdeslani:YES];
    [self EnabledAllComponents:YES];
    [self refreshData];
}

@end
