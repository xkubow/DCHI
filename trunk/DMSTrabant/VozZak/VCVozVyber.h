//
//  VCVozVyberViewController.h
//  DirectCheckin
//
//  Created by Jan Kubis on 22.01.13.
//
//

#import "VCBaseGrid.h"

@protocol VozVyberDelegate;

@interface VCVozVyber : VCBaseGrid

@property(nonatomic,assign)    id<VozVyberDelegate>    vozVyberDelegate;
@property(nonatomic, retain) NSDictionary *selectedData;

@end


@protocol VozVyberDelegate <NSObject>

//- (void)vozVyberSelected:(VCVozVyber *)Sender data:(NSDictionary *)data;
- (void)vozVyberDisaper:(VCVozVyber *)Sender;

@end