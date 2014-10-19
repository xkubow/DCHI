//
//  WSProtocolRequest.h
//  DirectCheckin
//
//  Created by Jan Kubis on 06.12.12.
//
//

#import <Foundation/Foundation.h>

@interface WSProtocolRequest : NSObject

- (id) initWithOwner:(id)newSender;
//- (id) printRequest:(NSString*)printerName;
- (void) cancelAllComunication;

@end
