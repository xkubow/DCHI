//
//  DMOBDII.h
//  DirectCheckin
//
//  Created by Jan Kubis on 5/9/13.
//
//

#import <Foundation/Foundation.h>

union cosi {
    struct {
        unsigned int subsystem:4;
        unsigned int type:2;
        unsigned int system:2;
        unsigned int subsystem2:4;
        unsigned int subsystem1:4;
    };
    UInt16 hodnota;
};

@interface DMOBDII : NSObject

+ (NSString *) decodeMultyFrameInData:(NSMutableDictionary *)data;
+ (NSString *) decodeOBDIIErrorInCode:(NSString *)hexStr;

@end
