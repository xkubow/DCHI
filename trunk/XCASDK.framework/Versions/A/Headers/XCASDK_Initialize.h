//
//  XCASDK_Initialize.h
//  XCA
//
//  Created by xyzmo on 14.10.11.
//  Copyright (c) 2011 xyzmo Software GmbH. All rights reserved.
//

/*!
 @copyright 2011-2013 xyzmo Software GmbH
 */

#import <Foundation/Foundation.h>
#import "XCAEnums.h"

/*!
 @abstract The delegate protocol for customizing the appearance of the SIGNificant view.
 */
@protocol XCASDK_InitializeDelegate

@required

/*!
 @abstract Will be called whenever a new GUI element is created and initialized to override styles, etc.
 
 @param pCocoaControl The control element
 @param pControlType The type of the GUI element
 @param pXCAPlace The place of the GUI element
 @param pXCAIdentification The ID of the GUI element
 */
-(void)XCASDK_Initialize_initControlElement:(id)pCocoaControl fromType:(XCAControlType)pControlType onPlace:(XCAControlPlace)pXCAPlace withIdentification:(NSString*)pXCAIdentification;

@optional

/*!
 @abstract Will be called whenever a color is defined for several (e.g. reusable) GUI elements.
 
 @param pXCAColorType The color type
 @param pXCAPlace The place of the GUI element
 @return The desired color
 */
-(UIColor *)XCASDK_Initialize_colorOfType:(XCAColorType)pXCAColorType onPlace:(XCAControlPlace)pXCAPlace;

/*!
 @abstract Will be called whenever a new font is defined / used.
 
 @param pSize The size of the font
 @param pBold Specifies if a bold font should be provided
 @return The custom font, or nil if the default should be used
 */
-(UIFont *)XCASDK_Initialize_CustomFontOfSize:(CGFloat)pSize withStyle:(XCAFontStyle)pStyle;

/*!
 @abstract Get Preference value for a key (normally et in the application setings, override here).
 
 @param pPreferenceKey The preference key
 @return The preference value as string
 */
-(NSString *)XCASDK_Initialize_GetPreferenceForKey:(NSString *)pPreferenceKey;

/*!
 @abstract Specifies if a particular hint element should be displayed.
 
 @param pHintType The hint type
 @return YES if the hint should be displayed
 */
-(BOOL)XCASDK_Initialize_ShouldShowHint:(XCAHintType)pHintType;

/*!
 @abstract Specifies the biometric encryption certificate to use.
 
 @return The encryption certificate as string
 */
-(NSString *)XCASDK_Initialize_GetEncryptionCertificate;

/*!
 @abstract Specifies if the current user name should be shown in title instead of document name.
 
 @return YES to show the user name
 */
-(BOOL)XCASDK_Initialize_ShowUserNameInApplicationTitle;

/*!
 @abstract Specifies the preferred status bar style for iOS 7 devices.
 
 @return The preferred status bar style
 */
-(UIStatusBarStyle)XCASDK_Initialize_PreferredStatusBarStyle;

/*!
 @abstract Specifies if the status bar should be hidden on iOS 7 devices.
 
 @return YES to hide the status bar, NO otherwise
 */
- (BOOL)XCASDK_Initialize_PrefersStatusBarHidden;

@end

/*!
 @abstract The initialize object for registering the initialize delegate.
 */
@interface XCASDK_Initialize : NSObject
{
	id<XCASDK_InitializeDelegate> delegate;
}

@property(nonatomic, retain) id<XCASDK_InitializeDelegate> delegate;

@end
