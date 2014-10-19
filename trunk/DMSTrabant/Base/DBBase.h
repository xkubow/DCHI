//
//  DBBase.h
//  DirectCheckin
//
//  Created by Jan Kubis on 11.01.13.
//
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface DBBase : NSObject

@property (retain, nonatomic)FMDatabase *db;

-(BOOL)Connect;

@end
