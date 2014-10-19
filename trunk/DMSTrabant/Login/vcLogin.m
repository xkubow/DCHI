//
//  vcLogin.m
//  DMSTrabant
//
//  Created by Jan Kubis on 1/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "vcLogin.h"
#import "Base64Coding.h"
#import "DejalActivityView.h"
#import "WSDCHIDataTransfer.h"
#import "TrabantAppDelegate.h"
#import "DMSetting.h"
#import "Flurry.h"
#import "BaseDBManager.h"
#import <CoreLocation/CoreLocation.h>
#import "Config.h"



#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])

@interface vcLogin()<CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    int wsMsgDone;
    BOOL isKeyboardShown;
    BOOL _showConfig;
    CGSize kbSize;
}
- (void) EnabledAllComponentsForSelector:(id)newEnableId;

@end

@implementation vcLogin
@synthesize loginDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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

- (void) EnabledAllComponentsForSelector:(id)newEnableId
{
    BOOL newEnable = (newEnableId!=nil);
    [self EnabledAllComponents:newEnable];
}

- (void) EnabledAllComponents:(BOOL)newEnable
{
    
    UIView *v = (isKeyboardShown)?TRABANT_APP_DELEGATE.rootNavController.view :self.navigationController.view;
    if(newEnable)
        [DejalBezelActivityView removeViewAnimated:YES];
    else
        [DejalBezelActivityView activityViewForView:v];
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [txtMeno addTarget:self action:@selector(txtEditingDidFinis:) forControlEvents:UIControlEventEditingChanged];
    [txtHeslo addTarget:self action:@selector(txtEditingDidFinis:) forControlEvents:UIControlEventEditingChanged];
    txtHeslo.returnKeyType = UIReturnKeyNext;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginDataChanged:) name:@"loginDataRespondNotification" object: nil];
    isKeyboardShown = NO;
    // Listen for keyboard appearances and disappearances
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    txtMeno.placeholder = NSLocalizedString(@"Uzivatel", nil);
    txtHeslo.placeholder  = NSLocalizedString(@"Heslo", nil);
    NSString *title = NSLocalizedString(@"Prihlaseni", nil);
    [btnLogin setTitle:title forState:UIControlStateNormal];// | UIControlStateHighlighted | UIControlStateSelected | UIControlStateDisabled];

    
    txtURL.placeholder = NSLocalizedString(@"URL", nil);
    txtCertHost.placeholder = NSLocalizedString(@"Pouzity certifikat", nil);
    txtUUID.placeholder = NSLocalizedString(@"UUID", nil);
    btnDeleteCert.titleLabel.text = NSLocalizedString(@"Smaz certifikat", nil);
    btnOK.titleLabel.text = NSLocalizedString(@"OK", nil);
}


- (void)viewDidUnload
{
    txtMeno = nil;
    txtHeslo = nil;
    btnLogin = nil;
    txtURL = nil;
    txtCertHost = nil;
    txtUUID = nil;
    lblMeno = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    txtHeslo.text = @"";
    [self EnabledAllComponents:YES];
    
    NSLog(@"user defauls data :%d", [Config getMajorDBVersion]);

    [txtURL setText:[Config getURL]];//[[TRABANT_APP_DELEGATE rootNavController] retrieveFromUserDefaults:@"url_web_service"]];
//    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
//    NSString *myUUID = [Config getUUID];
//    if(!myUUID.length)
//        myUUID = TRABANT_APP_DELEGATE.myUUID;
    txtUUID.text = [Config getUUID];//[[TRABANT_APP_DELEGATE rootNavController] retrieveFromUserDefaults:@"myUUID"];
    NSString *ServerCertPath = [TRABANT_APP_DELEGATE serverCerPath];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:ServerCertPath]) {
        SecCertificateRef certificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)[NSData dataWithContentsOfFile:ServerCertPath]);
        CFStringRef certificateSubject = SecCertificateCopySubjectSummary(certificate);
        [txtCertHost setText:(__bridge NSString*)certificateSubject];
        CFRelease(certificateSubject);
    } else
        [txtCertHost setText:@""];
    
    [btnLogin setEnabled:NO];
    _showConfig = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];

}

- (void)setPosition
{
    CLLocation *location = locationManager.location;
    [Flurry setLatitude:location.coordinate.latitude
              longitude:location.coordinate.longitude
     horizontalAccuracy:location.horizontalAccuracy
       verticalAccuracy:location.verticalAccuracy];
    
    [locationManager stopUpdatingLocation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight
            || interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}
- (void)txtEditingDidFinis:(id)sender {
    
    if([[txtMeno text] length] && [[txtHeslo text] length])
        [btnLogin setEnabled:YES];
    else
        [btnLogin setEnabled:NO];
}

#pragma mark - Login implementation

- (void) logIn
{
    //4443
    /*@"http://10.219.61.87:8080/";*/
    

    [self setPosition];

    NSString *strUrl = [[Config getURL] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSURL *url = [NSURL URLWithString:strUrl];
    if(url == nil || url.host == nil || url.port == nil)
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"nespravna url",@"chyba hlaska")
                                  delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",@"chyba hlaska") otherButtonTitles: nil] show];
        return;
    }
    NSString *serviceStrUrl = [NSString stringWithFormat:@"%@://%@:%@/",url.scheme, url.host, url.port];
    TRABANT_APP_DELEGATE.dbPath = serviceStrUrl;
    wsMsgDone = 0;

    [self EnabledAllComponents:NO];
    
    NSData *data = [[NSString stringWithFormat:@"%@:%@", txtMeno.text, txtHeslo.text ] dataUsingEncoding:NSUTF8StringEncoding];
    TRABANT_APP_DELEGATE.authorization = [Base64Coding base64StringFromData:data length:data.length];
    data = [[UIDevice currentDevice].name dataUsingEncoding:NSUTF8StringEncoding];
    TRABANT_APP_DELEGATE.deviceName = [@"base64 " stringByAppendingString:[Base64Coding base64StringFromData:data length:data.length]];
    
    [DMSetting sharedDMSetting].loggedUser = nil;
    WSDCHIDataTransfer *wsLogin = [WSDCHIDataTransfer sharedWSDCHIDataTransfer];//[WSCommunications sharedWSCommunications].wsLoadCarManufactureData;
    
    [wsLogin startloginWithName:txtMeno.text heslo:txtHeslo.text];

}

- (IBAction)btnLogin:(id)sender{
    [txtHeslo endEditing:YES];
    [txtHeslo resignFirstResponder];
    [self logIn];
}


- (void) checkLogin
{
    
    NSInteger usrId = [[[DMSetting sharedDMSetting].loggedUser objectForKey:@"PERSONAL_ID"] integerValue];
    if(usrId > 0 && [[self loginDelegate] respondsToSelector:@selector(loginSuces:)])
        [loginDelegate loginSuces:self];

}


- (void)loginDataChanged:(NSNotification *)notification
{
    if(wsMsgDone > 2 || [notification.object isEqualToString:@"LoginFailed"])
    {
        wsMsgDone=0;
        [self EnabledAllComponents:YES];
        return;
    }
    
    NSInteger newDBVer = [[[DMSetting sharedDMSetting].setting valueForKey:@"DB_MAJOR_VERSION"] integerValue];
    NSInteger actualDBVer = [Config getMajorDBVersion];
    
    if(actualDBVer != newDBVer)
    {
        NSString *msg = [NSString stringWithFormat: NSLocalizedString(@"veriza DB struktury je nespravna",nil), actualDBVer, newDBVer];
        [[[UIAlertView alloc] initWithTitle:@"" message:msg
                                  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [self EnabledAllComponents:YES];
        return;
    }
    
    wsMsgDone++;
    NSInteger actualDBVersion = [[[DMSetting sharedDMSetting].setting valueForKey:@"DB_MINOR_VERSION"] integerValue];
    id date = [Config getUpdateDate];
    NSLog(@"%@", [DMSetting sharedDMSetting].setting);
    NSLog(@"%d==%d", [Config getMinorDBVersion], actualDBVersion);
    if([Config getMinorDBVersion] != actualDBVersion || date == nil)
    {
        [Config setMinorDBVersion:actualDBVersion];
        
        UIView *v = (isKeyboardShown)?TRABANT_APP_DELEGATE.rootNavController.view :self.navigationController.view;
        [DejalBezelActivityView activityViewForView:v withLabel:NSLocalizedString(@"LOADING DB",nil) width:100 progressView:YES];
        NSArray *docDirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *dochDir = [docDirs objectAtIndex:0];
        NSString *dbPath = [dochDir stringByAppendingPathComponent:@"mchi.db"];
        
        NSArray *cachDirs = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachDir = [cachDirs objectAtIndex:0];
        NSString *siluetsPath = [cachDir stringByAppendingPathComponent:@"siluetsData"];
        NSString *banersPath = [cachDir stringByAppendingPathComponent:@"banersData"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSError *e;
        if([[NSFileManager defaultManager] fileExistsAtPath:dbPath])
            [fileManager removeItemAtPath:dbPath error:&e];
        if (e)
            NSLog(@"ERROR : %@, %@, %@", e.localizedDescription, e.localizedFailureReason, e.localizedRecoverySuggestion);
        if([[NSFileManager defaultManager] fileExistsAtPath:siluetsPath])
            [fileManager removeItemAtPath:siluetsPath error:&e];
        if (e)
            NSLog(@"ERROR : %@, %@, %@", e.localizedDescription, e.localizedFailureReason, e.localizedRecoverySuggestion);
        if([[NSFileManager defaultManager] fileExistsAtPath:banersPath])
            [fileManager removeItemAtPath:banersPath error:&e];
        if (e)
            NSLog(@"ERROR : %@, %@, %@", e.localizedDescription, e.localizedFailureReason, e.localizedRecoverySuggestion);
        
        [[WSDCHIDataTransfer sharedWSDCHIDataTransfer] loadDBData];
        return;
    }
    
    if(wsMsgDone >= 2 || [Config getMinorDBVersion]) //kontrola na existenciu minorVerzie
    {
        [self EnabledAllComponents:YES];
        [self performSelectorOnMainThread:@selector(checkLogin) withObject:self waitUntilDone:YES];
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if([loginDelegate respondsToSelector:@selector(loginDidDisaper:)]) 
        [loginDelegate loginDidDisaper:self];
}

- (void)showSetWebServiceURL {
    vcLogin *vcWebServiceUrl = [self.storyboard instantiateViewControllerWithIdentifier:@"vcWebServiceURL"];
    UINavigationController * ncModalView = [[UINavigationController alloc] initWithRootViewController:vcWebServiceUrl];
    [ncModalView setNavigationBarHidden:YES animated:NO];
    [ncModalView setModalPresentationStyle:UIModalPresentationFormSheet];
    ncModalView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [[self navigationController] presentViewController:ncModalView animated:YES completion:nil];
    ncModalView.preferredContentSize = CGSizeMake(800, 250);//it's important to do this after
    ncModalView.view.superview.center = CGPointMake(TRABANT_APP_DELEGATE.rootNavController.view.superview.center.y ,TRABANT_APP_DELEGATE.rootNavController.view.superview.center.x);

}

- (IBAction)setWebServiceURL:(id)sender{
    if(isKeyboardShown) {
        _showConfig = YES;
        [self.view endEditing:YES];
        [txtMeno resignFirstResponder];
    }
    else
        [self showSetWebServiceURL];
}

- (void)setTxtUrl:(NSString *)newUrl{
    [txtURL setText:newUrl];
}

- (IBAction)setWebServiceURLDid:(id)Sender{
    [Config setURL:[txtURL text]];
    [[self navigationController] dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)URLEndingChanged:(id)sender {
    [Config setUpdateDate:nil];
}

- (IBAction)DeleteCertificate:(id)Sender {
    NSString *ServerCertPath = [TRABANT_APP_DELEGATE serverCerPath];
    if([[NSFileManager defaultManager] fileExistsAtPath:ServerCertPath]){
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:ServerCertPath error:NULL];
        [txtCertHost setText:@""];
    }
}

- (void) makeFirstResponder:(id)sender
{
    [sender becomeFirstResponder];
}

-(IBAction)textFieldShouldReturn:(UITextField*)textField;
{
    if(txtMeno.text.length == 0)
        [self performSelector:@selector(makeFirstResponder:) withObject:txtMeno afterDelay:0.2];
    else if(txtHeslo.text.length == 0)
        [self performSelector:@selector(makeFirstResponder:) withObject:txtHeslo afterDelay:0.2];
    else
        [self logIn];
}

#pragma mark - location delegate methods

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(CLLocation *)newLocation
{
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"%d", status);
}

- (void)keyboardDidShow: (NSNotification *) notif{
    kbSize = [[notif.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    isKeyboardShown = YES;
}

- (void)keyboardDidHide: (NSNotification *) notif{
    kbSize = [[notif.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    isKeyboardShown = NO;
    if(_showConfig)
        [self showSetWebServiceURL];
    _showConfig = NO;
}

@end
