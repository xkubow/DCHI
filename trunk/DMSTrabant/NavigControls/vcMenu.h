//
//  vcMenu.h
//  Direct checkin
//
//  Created by Jan Kubis on 09.10.12.
//  Copyright (c) 2012 jan.kubis@t-systems.cz. All rights reserved.
//

#import <UIKit/UIKit.h>
//#include "webServices.h"

@class vcBase;

@interface vcMenu : NSObject <UIActionSheetDelegate>
{
    UITabBarController *rootTBC;
    vcBase *viewControlerBase;
    NSString *insertResultMessage;
    NSInteger insertResult;
}

@property (retain, nonatomic)UIActionSheet *menu;

- (id)initAndShowInView:(id)Sender;

@end
