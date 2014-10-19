//
//  vcPhotoMenu.h
//  DirectCheckin
//
//  Created by Jan Kubis on 14.10.13.
//
//

#import <UIKit/UIKit.h>

@protocol PhotoMenuDelegate;

@interface vcPhotoMenu : UIViewController

@property (nonatomic, retain) id<PhotoMenuDelegate> delegate;

@end


@protocol PhotoMenuDelegate <NSObject>

- (void)showImg;
- (void)deleteImg;

@end