//
//  webBaseService.h
//  DirectCheckin
//
//  Created by Jan Kubis on 30.11.12.
//
//

#import <Foundation/Foundation.h>
#import "ASINetworkQueue.h"

@interface WSBaseService : NSObject 

@property (nonatomic, readwrite)BOOL showErrorMessag;

- (void) sendPostMessage:(NSString *)body urlData:(NSDictionary *)urlData action:(NSString*)action;
- (void) sendGetMessage:(NSDictionary *)sendData action:(NSString*)action;
- (void) sendGetMessage:(NSDictionary *)sendData action:(NSString*)action backgroud:(BOOL)backgroud;
- (void) sendFormMessage:(NSDictionary *)sendData action:(NSString*)action;
- (ASINetworkQueue*)queue;
- (ASINetworkQueue*)backQueue;
- (void)setHeadersForRequest:(id)request;
@end

@protocol webBaseServiceDelegate <NSObject>

- (void)webBaseQueueDidFinish:(id)Sender;
- (void)webBSRequestDidFinish:(id)Sender;
- (void)webBSRequestDidFail:(id)Sender;
@end
