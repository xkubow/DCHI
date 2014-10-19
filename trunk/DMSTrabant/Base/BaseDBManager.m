 //
//  BaseDBManager.m
//  DirectCheckin
//
//  Created by Jan Kubis on 07.03.13.
//
//

#import "BaseDBManager.h"
#import "FMDatabaseAdditions.h"
#import "DejalActivityView.h"
#import "TrabantAppDelegate.h"
#import "DMSetting.h"
#import "Flurry.h"
#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])


@interface BaseDBManager()
{
    int requestCount;
}
@end


@implementation BaseDBManager
@synthesize database=_database;
@synthesize isOpen=_isOpen;
@synthesize progressStep=_prograsStep;
@synthesize theProgress=_theProgress;


+(BaseDBManager *)sharedBaseDBManager
{
    static BaseDBManager *shared = nil;
    if(!shared)
        shared = [[self alloc] init];
    
    return shared;
}

- (BaseDBManager*)init
{
    self = [super init];
    if(self)
    {
        NSArray *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [documentsPath objectAtIndex:0];
        NSString *databasePath = [docDir stringByAppendingPathComponent:@"mchi.db"];
        _database = [FMDatabase databaseWithPath:databasePath];
        requestCount = 0;
        [_database setLogsErrors:YES];
        
    }
    return  self;
}

-(void)openDB
{
    requestCount++;
    if(_isOpen)
        return;
    NSArray *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [documentsPath objectAtIndex:0];
    NSString *databasePath = [docDir stringByAppendingPathComponent:@"mchi.db"];
    _database = [FMDatabase databaseWithPath:databasePath];
    _database.logsErrors = YES;
    
    _isOpen = [_database open];
    if (!_isOpen) {
        NSLog(@"Could not open db.");
    }
}

-(void)closeDB
{
    if(--requestCount == 0)
    {
        [_database close];
        _isOpen = NO;
    }
}

-(void)commitDB
{
    [self openDB];
    if(![_database commit])
        NSLog(@"Nepodaril sa commit");
    [self closeDB];
}

-(void)dealloc
{
    [_database close];
    _database = nil;
}

-(void)prograsStep:(NSNumber*)newNumber
{
    _theProgress = [NSNumber numberWithFloat:0.0];
    _prograsStep = newNumber;
}

+(BOOL)isDBready
{
    BOOL success;
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *writableDBPath = [docDir stringByAppendingPathComponent:@"mchi.db"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    
    if (!success) {
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"mchiBase.db"];
        success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
        if (!success)
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
        else
            [[NSURL fileURLWithPath:writableDBPath] setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
        if(error != nil)
            NSLog(@"Setting DB file error: %@", error.localizedDescription);
    }
    
    
    
    return success;
}

-(void)loadBaseDB
{
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *writableDBPath = [docDir stringByAppendingPathComponent:@"mchi.db"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success)
    {
        [fileManager removeItemAtPath:writableDBPath error:&error];
        if(error)
            NSLog(@"%@", error.debugDescription);
    }

    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"mchiBase.db"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success)
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    else
        [[NSURL fileURLWithPath:writableDBPath] setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    if(error != nil)
        NSLog(@"Setting DB file error: %@", error.localizedDescription);

}

-(void)deleteDataInTable:(NSString*)tableName
{
    [self openDB];

    [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", tableName]];
    
    if(_database.lastError.code)
        NSLog(@"insertRecordsForTable error: %@", _database.lastError);
    [self closeDB];
}

-(void)insertRecordsForTable:(NSString*)tableName data:(NSArray*)data
{
    [self deleteDataInTable:tableName];
    [self openDB];
    NSArray *keys;
    NSMutableString *sql;
    NSMutableString *keysStr = [[NSMutableString alloc] init];
    NSMutableString *qMark = [[NSMutableString alloc] init];
    NSMutableArray *valsArray = [[NSMutableArray alloc] init];
    NSString *val;
    NSDate *date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Etc/UTC"]];
    NSArray *tz;
    NSInteger count = 0;
    
    for(NSDictionary *d in data)
    {
        sql = [NSMutableString stringWithFormat:@"INSERT INTO [%@] ", tableName];
        keys = d.allKeys;
        [qMark setString:@""];
        [keysStr setString:@""];
        [valsArray removeAllObjects];
        for(NSString *key in keys)
        {
            if([d valueForKey:key] == nil || [d valueForKey:key] == [NSNull null])
                continue;
            val = [NSString stringWithFormat:@"%@", [d valueForKey:key]];
            
            [keysStr appendFormat:@"\"%@\",", key];
            
            date = [dateFormatter dateFromString:val];
            if(date){
                if([tableName isEqualToString:@"CHECK_OFFER"])
                    tz = [NSTimeZone knownTimeZoneNames];
                [valsArray addObject:date];
            }
            else
                [valsArray addObject:[d valueForKey:key]];
            [qMark appendString:@"?,"];
            
        }
        [keysStr deleteCharactersInRange:NSMakeRange(keysStr.length-1,1)];
        [qMark deleteCharactersInRange:NSMakeRange(qMark.length-1,1)];
        [sql appendFormat:@"(%@) VALUES (%@)",keysStr, qMark];
        
        [_database executeUpdate:sql withArgumentsInArray:valsArray];
        count++;
        if(count > 1000)
        {
            _theProgress = [NSNumber numberWithDouble:_theProgress.doubleValue+count*_prograsStep.doubleValue];
            count = 0;
//            [NSThread sleepForTimeInterval: 0.01];
            [self performSelectorOnMainThread: @selector(clearProgressBar) withObject: nil waitUntilDone: NO];
        }
        
        if(_database.lastError.code) {
            NSLog(@"  SQLite DB insert error:%@", _database.lastError);
            [Flurry logError:@"  SQLite DB insert error" message:@"isert error" error:_database.lastError];
            break;
        }
    }
    [self closeDB];
    
    if(count != 0 )
    {
        _theProgress = [NSNumber numberWithDouble:_theProgress.doubleValue+count*_prograsStep.doubleValue];
        [NSThread sleepForTimeInterval: 0.01];
        [self performSelectorOnMainThread: @selector(clearProgressBar) withObject: nil waitUntilDone: NO];
    }
    NSLog(@"done %@, %d", tableName, data.count);
}

-(NSArray *)getStaticDataFromTable:(NSString *)tableName
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", tableName];
    
    return [self preformOnStaticDBSelect:sql];

}

-(NSArray *)preformOnStaticDBSelect:(NSString *)sql
{
    [self openDB];
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    
    FMResultSet *result = [_database executeQuery:sql];
    
    if(_database.lastError.code) {
        NSLog(@"preformOnStaticDBSelect error : %@", _database.lastError);
        [self closeDB];
        return nil;
    }
    
    while ([result next]) {
        [resultArray addObject:[result resultDictionary]];
    }
    [self closeDB];
    return resultArray;
    
}

-(NSInteger)getDBVersion
{
    NSInteger _dbVersion = -1;
    
    [self openDB];
    
    NSArray *result = [self preformOnStaticDBSelect:@"SELECT DB_MINOR_VERSION FROM SYS_CONFIG"];
    
    if(result.count == 1)
        _dbVersion = [[result[0] valueForKey:@"DB_MINOR_VERSION"] integerValue];
    
    [self closeDB];
    
    return _dbVersion;
}

-(void)clearProgressBar {
    [DejalBezelActivityView currentActivityView].progressView.progress =_theProgress.doubleValue;
}


@end
