//
//  Base64Coding.h
//  Mobile checkin
//
//  Created by Jan Kubis on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Base64Coding : NSObject
+ (NSString *) base64StringFromData:(NSData *)data length:(int)length;
+ (NSData *) base64DataFromString:(NSString *)string;
+ (NSString *)md5:(NSString *)str;

@end
