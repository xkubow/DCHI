//
//  OBDIICom.h
//  DirectCheckin
//
//  Created by Jan Kubis on 09.05.13.
//
//

#import <Foundation/Foundation.h>

@interface OBDIICom : NSObject <NSStreamDelegate>

@property (nonatomic, retain) NSMutableArray *data;

+ (OBDIICom *)sharedOBDIICom;
- (BOOL) createConnection;

@end
