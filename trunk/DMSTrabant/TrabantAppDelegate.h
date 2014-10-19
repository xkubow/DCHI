//
//  TrabantAppDelegate.h
//  DMSTrabant
//
//  Created by Jan Kubis on 1/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ncRootNavControlller.h"
#import "vcMenu.h"

@interface TrabantAppDelegate : UIResponder <UIApplicationDelegate>{
    NSInteger pracovnik_id, checking_id;
    ncRootNavControlller *rootNavController;
    NSString *appVer, *serverCerPath;
    NSDate *suspendTime;
    NSNumberFormatter *numFormat;

}

@property (strong, nonatomic) UIWindow *window;


//@property (assign, nonatomic) NSInteger pracovnik_id;
@property (assign, nonatomic) NSInteger checking_id;
@property (assign, nonatomic) NSString *ncTitle1, *ncTitle2;
@property (retain, nonatomic) ncRootNavControlller *rootNavController;
@property (readonly, nonatomic) NSString* appVer;
@property (readonly, nonatomic) NSString* serverCerPath;
@property (readonly, nonatomic) NSNumberFormatter *numFormat;
@property (retain, nonatomic) NSString *dbPath;
@property (retain, nonatomic) NSString *actualLanguage;
@property (retain, nonatomic) NSString *authorization;
@property (retain, nonatomic) NSString *deviceName;

@end
