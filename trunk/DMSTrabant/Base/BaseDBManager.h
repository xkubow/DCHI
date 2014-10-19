//
//  BaseDBManager.h
//  DirectCheckin
//
//  Created by Jan Kubis on 07.03.13.
//
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface BaseDBManager : NSObject

@property (retain, nonatomic)FMDatabase* database;
@property (readonly, nonatomic)BOOL isOpen;
@property (nonatomic, retain)NSNumber *progressStep;
@property (nonatomic, retain)NSNumber *theProgress;

+(BaseDBManager *)sharedBaseDBManager;
+(BOOL)isDBready;

-(void)openDB;
-(void)closeDB;
-(void)commitDB;

-(void)insertRecordsForTable:(NSString*)tableName data:(NSArray*)data;
-(NSArray *)getStaticDataFromTable:(NSString *)tableName;
-(NSArray *)preformOnStaticDBSelect:(NSString *)sql;
-(NSInteger)getDBVersion;
-(void)loadBaseDB;
@end
