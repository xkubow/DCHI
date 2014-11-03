//
//  SignPDFInit.m
//  DirectCheckin
//
//  Created by Jan Kubis on 08.10.14.
//
//

#import "SignPDFInit.h"
#import "Rezident.h"
#import "TrabantAppDelegate.h"
#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])
#define ROOTNAVIGATOR ([TRABANT_APP_DELEGATE rootNavController])

@implementation SignPDFInit


- (void) XCASDK_Initialize_initControlElement: 		(id)  	pCocoaControl
                                     fromType: 		(XCAControlType)  	pControlType
                                      onPlace: 		(XCAControlPlace)  	pXCAPlace
                           withIdentification: 		(NSString *)  	pXCAIdentification
{
    if(pControlType == kUINavigationBar) {
        NSLog(@"Navigation BARRR, %@", pCocoaControl);
        
        UINavigationBar *navBar = (UINavigationBar *)pCocoaControl;
        [navBar setBackgroundColor:[UIColor greenColor]];
//        [navBar setBackgroundImage:[UIImage imageNamed:@"alu_texture_navigation.png"] forBarMetrics:UIBarMetricsDefault];
//        CGRect r = navBar.frame;
//        UILabel *lblNavBar = [Rezident setNavigationTitle:CGRectMake(0, 0, navBar.frame.size.width, r.size.height)];
//        lblNavBar.text = ROOTNAVIGATOR.vozCaption;
//        self.navigationItem.titleView = lblNavBar;
    }
    else if(pControlType == kUIView && kXCAMainView == pXCAPlace) {
        UIView *v = (UIView *)pCocoaControl;
        NSLog(@"%@", v.superview);
        UIImage *img = [UIImage imageNamed:@"alutexture_bg.png"];
        UIImageView *imgViev = [[UIImageView alloc] initWithImage:img];
        [v addSubview:imgViev];
        [v setBackgroundColor:[UIColor clearColor]];
    } else if(pControlType == kUIToolbar && pXCAPlace == kXCASignatureView)
    {
        UIToolbar *tb = (UIToolbar *) pCocoaControl;
        [tb setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"alu_texture_navigation.png"]]];
    }
    
    NSString *controlTyp = [[self class] ControlTypesEnums][pControlType];
    NSString *place = [[self class] ControlPlacesEnums][pXCAPlace];
    
    NSLog(@"%@:%@", controlTyp, place);
    
}

- (UIColor *) XCASDK_Initialize_colorOfType: 		(XCAColorType)  	pXCAColorType
                                    onPlace: 		(XCAControlPlace)  	pXCAPlace
{
    NSLog(@"%@", [[self class] ControlPlacesEnums][pXCAPlace]);
    NSLog(@"%@", [[self class] ColorTypesEnums][pXCAColorType]);
    if(pXCAColorType == kXCAToolbarBackgroundColor)
    {
        return [UIColor colorWithRed:0.471 green:0.612 blue:0.639 alpha:1];
    }
    return  [UIColor whiteColor];
}

-(NSString *)XCASDK_Initialize_GetPreferenceForKey:(NSString *)pPreferenceKey {
    if (pPreferenceKey == nil) return nil;
    NSLog(@"wants value for %@", pPreferenceKey);
    NSString *result = nil;
    
    if (NSOrderedSame == [pPreferenceKey compare:@"server_address_v1"]) {
        result = @"http://10.219.61.104:57003";
    }
    NSLog(@"returning value %@", result);
    return result;
}


/*
 //Change the encryption certificate
 //By default, the xyzmo encryption certificate will be used. Here is a sample code to set the encryption certificate (public part of the certificate) in InitializeDelegate.m. The certificate must be a DER encoded X.509 certificate.
 // used to configure custom biometric certificates
 -(NSString *)XCASDK_Initialize_GetEncryptionCertificate
 {
 NSString *certDataPath = [[NSBundle mainBundle] pathForResource:@"encryptioncertificate_der_base64" ofType:@"cer"];
 NSError *error = nil;
 NSString *res = [NSString stringWithContentsOfFile:certDataPath encoding:NSUTF8StringEncoding error:&error];
 if (error)
 {
 NSLog(@"Error on loading b64 encryption certificate %@", error.description);
 return nil;
 }
 return res;
 }
 */

+ (NSArray *)ControlTypesEnums
{
    static NSArray *enums;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        enums = @[@"kUIButton",
                    @"kUISwitch",
                    @"kUIView",
                    @"kUIImageView",
                    @"kUIToolbar",
                    @"kUIToolbarButton",
                    @"kUILabel",
                    @"kUISlider",
                    @"kUINavigationBar",
                    @"kUIBarButtonItem"];
    });
    return enums;
}

+ (NSArray *)ControlPlacesEnums
{
    static NSArray *enums;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        enums = @[@"kXCAMainToolbar",
                  @"kXCAMainView",
                  @"kXCASignatureView",
                  @"kXCAHelpScreen",
                  @"kXCAOfflineWsPicker",
                  @"kXCADocumentList",
                  @"kXCATaskList",
                  @"kXCAEntireApp",
                  @"kXCALicenseScreen",
                  @"kXCASettingsList",
                  @"kXCASyncStateList",
                  @"kXCAMenuBar",
                  @"kXCADocumentView",
                  @"kXCAFreeHandToolbar",
                  @"kXCAPictureAnnotationToolbar"];
    });
    return enums;
}

+ (NSArray *)ColorTypesEnums
{
    static NSArray *enums;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        enums = @[@"kXCAMainTintColor",
                 @"kXCAViewBackgroundColor",
                 @"kXCANavBarTintColor",
                 @"kXCANavBarTitleTextColor",
                 @"kXCANavBarBackgroundColor",
                 @"kXCATabBarTintColor",
                 @"kXCATabBarBackgroundColor",
                 @"kXCAToolbarTintColor",
                 @"kXCAToolbarTitleTextColor",
                 @"kXCAToolbarBackgroundColor",
                 @"kXCATableViewBackgroundColor",
                 @"kXCATableViewCellBackgroundColor",
                 @"kXCATableViewCellSelectedBackgroundColor",
                 @"kXCATableViewCellTitleColor",
                 @"kXCAFormFieldDisabledBackgroundColor",
                 @"kXCAFormFieldFocusedBackgroundColor",
                 @"kXCAFormFieldEmptyBackgroundColor",
                 @"kXCAFormFieldDefaultBackgroundColor",
                 @"kXCAFormFieldDisabledBorderColor",
                 @"kXCAFormFieldRequiredBorderColor",
                 @"kXCAFormFieldDefaultBorderColor"];
    });
    return enums;
}

@end
