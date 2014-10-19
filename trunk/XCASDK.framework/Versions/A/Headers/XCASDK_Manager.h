//
//  XCASDK_Manager.h
//  XCA
//
//  Created by xyzmo on 14.10.11.
//  Copyright (c) 2011 xyzmo Software GmbH. All rights reserved.
//

/*!
 @copyright 2011-2013 xyzmo Software GmbH
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class XCASDK_Initialize;
@class XCASDK_Operations;

/*!
 @abstract The SIGNIficant SDK Manager for registering the initialize/operations delegates.
 */
@interface XCASDK_Manager : NSObject
{
	XCASDK_Initialize *sdkInitialize;
	XCASDK_Operations *sdkOperations;
}

@property (nonatomic, retain, readonly) XCASDK_Initialize *sdkInitialize;
@property (nonatomic, retain, readonly) XCASDK_Operations *sdkOperations;
@property (nonatomic, retain) UIViewController *currentViewController;

/*!
 @abstract Returns the SDK Manager shared instance.
 
 @return The SDK Manager instance.
 */
+(XCASDK_Manager *)sharedManager;

/*!
 @abstract Returns the main view controller of the SIGNificant SDK.
 
 @return The main view controller.
 */
-(UIViewController *)getXCAViewController;

/*!
 @abstract Returns the SIGNificant SDK version information.
 
 @return The version information as string.
 */
-(NSString *)getSDKVersionInformation;

/*!
 @abstract Returns the SIGNificant SDK build date.
 
 @return The build date as string.
 */
-(NSString *)getSDKBuildDate;

@end
