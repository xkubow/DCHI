//
//  SignPDFInit.m
//  DirectCheckin
//
//  Created by Jan Kubis on 08.10.14.
//
//

#import "SignPDFInit.h"

@implementation SignPDFInit


- (void) XCASDK_Initialize_initControlElement: 		(id)  	pCocoaControl
                                     fromType: 		(XCAControlType)  	pControlType
                                      onPlace: 		(XCAControlPlace)  	pXCAPlace
                           withIdentification: 		(NSString *)  	pXCAIdentification
{
    NSLog(@"%@", pCocoaControl);
    
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

-(UIColor *)XCASDK_Initialize_colorForReusableControlWithId:(NSString *)pXCAIdentification onPlace:(XCAControlPlace)pXCAPlace
{
    // iOS 7
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7" options:NSNumericSearch] != NSOrderedAscending)
    {
        if ([pXCAIdentification isEqualToString:@"navBarBackgroundColor"] ||
            [pXCAIdentification isEqualToString:@"toolbarBackgroundColor"] ||
            [pXCAIdentification isEqualToString:@"tabBarBackgroundColor"])
        {
            return [UIColor colorWithRed:1.0 green:0.7 blue:0.7 alpha:1.0];
        }
    }
    
    return [UIColor redColor];
}

@end
