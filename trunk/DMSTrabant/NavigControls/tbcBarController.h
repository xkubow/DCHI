//
//  tbcBarController.h
//  Mobile checkin
//
//  Created by  on 16.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface tbcBarController : UITabBarController <UITabBarControllerDelegate>
{
    NSArray *titles;
}

@property (nonatomic, readwrite) BOOL reloadData;
@property (nonatomic, readwrite) BOOL reloadPackets;

@end
