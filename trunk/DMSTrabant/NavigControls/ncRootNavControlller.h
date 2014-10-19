//
//  ncRootNavControlller.h
//  DMSTrabant
//
//  Created by Jan Kubis on 1/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "vcLogin.h"
#import "vcTrabantPictures.h"

@interface NavControllerDisKeyboard : UINavigationController
@end

@interface ncRootNavControlller : UINavigationController <LoginDelegate>{
    NavControllerDisKeyboard *ncModalView;
    UIEdgeInsets contentInsets;
    vcLogin *Login;
}

@property (retain, nonatomic)NSString *userCaption;
@property (retain, nonatomic)NSString *vozCaption;
@property (retain, nonatomic)UITableView *tbvcActive;
@property (retain, nonatomic)id txtActive;

//@property (retain, nonatomic) vcTrabantPictures *trabnatPictureVC;



- (void)showLogin;
- (void)setNavigationBar:(UIViewController *)Sender;
//- (void) setSwipeGesture:(UIViewController *) Sender;
- (BOOL)isLoginShowed;
- (void) releaseData;

@end
