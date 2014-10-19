//								
//  TrabantAppDelegate.m
//  DMSTrabant
//
//  Created by Jan Kubis on 1/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TrabantAppDelegate.h"
#import "DMSetting.h"
#import "UUIDCreator.h"
#import "Base64Coding.h"
#import "Flurry.h"
#import "FMDatabaseAdditions.h"
#import "TestFlight.h"
#import "Config.h"
#import "DejalActivityView.h"
#import "WSDCHIDataTransfer.h"
#import <AdSupport/ASIdentifierManager.h>



@implementation TrabantAppDelegate

@synthesize window = _window;
@synthesize rootNavController, checking_id, ncTitle1, ncTitle2, appVer, serverCerPath, numFormat;
@synthesize actualLanguage=_actualLanguage;
@synthesize dbPath=_dbPath;
@synthesize authorization=_authorization;
@synthesize deviceName=_deviceName;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    appVer = [NSString stringWithFormat:@"%@ -%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    
    [Flurry setAppVersion:appVer];
    [Flurry startSession:@"WWRHW36D3PN9SDCJ79QK"];
    [Flurry logEvent:@"application: didFinishLaunchingWithOptions:"];
//    [Flurry setShowErrorInLogEnabled:YES];
//    [Flurry setDebugLogEnabled:YES];
    [Flurry setSecureTransportEnabled:YES];
    pracovnik_id = checking_id = -1;
    rootNavController = nil;
//    if(setting == nil)
//        setting = [[NSMutableDictionary alloc] init];
    
    
    NSData *macData = [[UUIDCreator getMacAddress] dataUsingEncoding:NSMacOSRomanStringEncoding];
    NSString *myUUID;
    if (NSClassFromString(@"ASIdentifierManager")) {
        myUUID = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    } else
        myUUID = [[Base64Coding base64StringFromData:macData length:[macData length]] uppercaseString];
    [Flurry setUserID:myUUID];
//    [Flurry setDebugLogEnabled:YES];
//    [Flurry setEventLoggingEnabled:YES];
    [Flurry setLogLevel:FlurryLogLevelDebug];
    [TestFlight addCustomEnvironmentInformation:@"UUID" forKey:myUUID];
    [TestFlight takeOff:@"ef64e3d9-d519-4011-926f-49381befec75"];
    
//    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
//    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
//    NSString* preferredLang = [languages objectAtIndex:0];
//    NSLog(@"localeIdentifier: %@", preferredLang);
    

//    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
//    [standardUserDefaults setObject:@"Wed, 30 Oct 2013 15:16:54 GMT" forKey:@"staticDBDataUpdateDate"];
//    [[NSUserDefaults standardUserDefaults] setObject:myUUID forKey:@"myUUID"];
    
// ******************************** nastavenie verzii  **********************************************
    [Config setUUID:myUUID];
    [Config setGenerationVersion:3];
    [Config setMajorDBVersion:0];
    [Config setCommunicationVersion:0];
    
// ******************************** nastavenie verzii  **********************************************
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"%d", [Config getMajorDBVersion]);
    
    serverCerPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"/mySrvCert.cer"];
    
    _actualLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    numFormat = [[NSNumberFormatter alloc] init];
    [numFormat setFormatterBehavior:NSFoundationVersionNumber10_4];
    [numFormat setNumberStyle:NSNumberFormatterDecimalStyle];
    numFormat.maximumFractionDigits = 2;
//    [numFormat setRoundingMode:NSNumberFormatterRoundDown];
//    [numFormat setFormatWidth:6];
//    [numFormat setPositiveFormat:@"### ### ### ##0.00"];
//    [numFormat setNegativeFormat:@"-### ### ### ##0.00"];
    
//    [self createEditableCopyOfDatabaseIfNeeded];
    
    NSLog(@"Is DB ready :%d",[BaseDBManager isDBready]);
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [Config synchronize];
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    suspendTime = [NSDate date];
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    NSNumber *timeOut = [[DMSetting sharedDMSetting].setting objectForKey:@"AUTO_LOG_OFF_MINUTES"];
//    NSTimeInterval logOffTime = //[[strTimeOut stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] integerValue];
    if([[NSDate date] timeIntervalSinceDate:suspendTime] > (timeOut.integerValue*60))
        [rootNavController showLogin];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    suspendTime = 0;
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"handleOpenURL: %@", url);
    [[WSDCHIDataTransfer sharedWSDCHIDataTransfer] startDCHIReport];
    
    return YES;
}


@end
