 //
//  Siluets.m
//  DirectCheckin
//
//  Created by Jan Kubis on 07.03.13.
//
//

#import "DBSiluets.h"
#import "DMSetting.h"
//#import "WSBaseService.h"
#import "ASIHTTPRequest.h"
#import "DejalActivityView.h"
#import "WSDCHIDataTransfer.h"




@interface DBSiluets()
{
    FMDatabase *_database;
//    WSSiluets *wsSiluets;
    BaseDBManager *baseDBManager;
}

@end

@implementation DBSiluets

-(DBSiluets*)init
{
    self = [super init];
    if(self)
    {
        baseDBManager = [BaseDBManager sharedBaseDBManager];
        _database = baseDBManager.database;
    }
    return self;
}

-(NSArray *)loadSiluetsWithVyrVoz:(NSString*)vyrobekVoz
{
    NSString *query = [NSString stringWithFormat:@"SELECT SILHOUETTE_ID "
                       "FROM BRAND_SILHOUETTE "
                       "WHERE BRAND_ID LIKE '%@' ", vyrobekVoz];
    
    [baseDBManager openDB];
    if(baseDBManager.database.lastError.code) {
        NSLog(@"loadSiluetID error:%@", baseDBManager.database.lastError);
        return nil;
    }
    
    FMResultSet *result = [baseDBManager.database executeQuery:query];
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    while ([result next])
    {
        NSString *siId = [result stringForColumn:@"SILHOUETTE_ID"];
        if(siId == NULL)
            continue;
        [dataArray addObject:siId];
    }
    [result close];
    
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    
    for(NSString *s in dataArray)
        [resultArray addObject:[self loadImagesWithSiluetaId:s]];

    [baseDBManager closeDB];
    
    if(!resultArray.count)
        return nil;
    else
        return resultArray;
    
}

-(NSArray *)loadSiluetsWithVyrVoz:(NSString*)vyrobekVoz typKod:(NSString*)typKod
{
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM( "
                                "SELECT TK.VALUE||'.*' AS KOD, TK.SILHOUETTE_ID, '1' AS I "
                                "FROM TYPE_CODE TK "
                                "WHERE TK.BRAND_ID LIKE '%@' "
                                "UNION "
                                "SELECT '..'||VVK.CODE||'.*' AS KOD, VVK.SILHOUETTE_ID, '2' AS I "
                                "FROM BRAND_CARBODYCODE VVK "
                                "WHERE VVK.BRAND_ID LIKE '%@' "
                                "UNION "
                                "SELECT '.*' AS KOD, VV.SILHOUETTE_ID, '3' AS I "
                                "FROM BRAND VV "
                                "WHERE VV.BRAND_ID LIKE '%@'"
                                "UNION "
                                "SELECT '.*' AS KOD, C.SILHOUETTE_ID, '4' AS I "
                                "FROM SYS_CONFIG C) DATA "
                                "ORDER BY I", vyrobekVoz, vyrobekVoz, vyrobekVoz];
    
    [baseDBManager openDB];
    if(baseDBManager.database.lastError.code) {
        NSLog(@"loadSiluetID error:%@", baseDBManager.database.lastError);
        return nil;
    }
    
    FMResultSet *result = [baseDBManager.database executeQuery:query];
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    while ([result next])
        if([result stringForColumn:@"SILHOUETTE_ID"] != NULL)
            [dataArray addObject:[result resultDictionary]];

    [result close];
    
    NSPredicate *predicate;
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    NSMutableArray *siluetIds = [[NSMutableArray alloc]init];
    
    for(NSDictionary *d in dataArray)
    {
        if([siluetIds indexOfObject:[d valueForKey:@"SILHOUETTE_ID"]] != NSNotFound)
            continue;
        NSString *filtr = [d valueForKey:@"KOD"];
        predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", filtr];
        
        if(typKod.length || [predicate evaluateWithObject:typKod]) {
            [siluetIds addObject: [d valueForKey:@"SILHOUETTE_ID"]];
            [resultArray addObject:[self loadImagesWithSiluetaId:siluetIds.lastObject]];
        }
    }
    [baseDBManager closeDB];
    
    if(!resultArray.count)
        return nil;
    else
        return resultArray;
    
}


-(void)reloadImgaes
{
    [[WSDCHIDataTransfer sharedWSDCHIDataTransfer] startDCHIAllSiluets];
//    [[WSCommunications sharedWSCommunications].wsLoadCarManufactureData startDCHIAllSiluets];
}

-(void)insertImgWithSiluetaId:(NSInteger)siluetaId siluetsTypId:(NSInteger)siluetsTypId image:(NSData*)image
{
    [baseDBManager openDB];
    NSString *sql = [NSString stringWithFormat:@"UPDATE SILHOUETTE_IMAGE set IMAGE=? WHERE SILHOUETTE_ID=%i AND SILHOUETTE_TYPE_ID=%i", siluetaId, siluetsTypId];
    [baseDBManager.database executeUpdate:sql, image];
    if(baseDBManager.database.lastError.code)
        NSLog(@"insertImgWithSiluetaId error: %@", baseDBManager.database.lastError);
    
    [baseDBManager closeDB];

}

-(NSArray *)loadImagesWithSiluetaId:(NSString*)SiluetaId
{
    [baseDBManager openDB];
    
    FMResultSet *result = [baseDBManager.database executeQuery:@"SELECT SI.SILHOUETTE_ID, S.TEXT AS STEXT, SI.SILHOUETTE_TYPE_ID, ST.TEXT AS STTEXT, SI.IMAGE "
                                                "FROM SILHOUETTE_IMAGE SI, SILHOUETTE S, SILHOUETTE_TYPE ST "
                                                "WHERE S.ID=SI.SILHOUETTE_ID "
                                                "AND ST.ID=SI.SILHOUETTE_TYPE_ID "
                                                " AND SI.SILHOUETTE_ID=?", SiluetaId];
    
    if(baseDBManager.database.lastError.code) {
        NSLog(@"loadSiluetID error:%@", baseDBManager.database.lastError);
        return nil;
    }
    
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    while ([result next])
        [resultArray addObject: [result resultDictionary]];


    [result close];
    [baseDBManager closeDB];
    return resultArray;
}

-(void)parseSiluets
{
    BOOL doIt = YES;
    BOOL isContent = NO;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachDir = [paths objectAtIndex:0];
    NSString *dataPath = [cachDir stringByAppendingPathComponent:@"siluetsData"];
    NSFileManager *fm = [[NSFileManager alloc] init];
    
    if(![fm fileExistsAtPath:dataPath])
    {
        NSLog(@"file sileutsData not exist");
        return;
    }
    NSTimeInterval ti = [[NSDate date] timeIntervalSinceNow];
    NSLog(@"   Starting parse siluets");
    NSInteger siluetaId = -1, siluetaTypId = -1;
    NSData *theData = [NSData dataWithContentsOfFile:dataPath];
    NSData *lookingFor = [@"\r\n" dataUsingEncoding:NSASCIIStringEncoding];
    NSRange sepRange = {0, theData.length};
    NSRange foundSep = [theData rangeOfData:lookingFor options:0 range:sepRange];
    NSData *lineData;
    NSData *sepData= [NSData dataWithBytes:((char*) theData.bytes) length:foundSep.location-1];
    NSString *lineStr;// = [NSString stringWithUTF8String:sepData.bytes];
    
    while(doIt)
    {
        NSInteger pos = (foundSep.location+foundSep.length);
        NSRange newRange = {pos, theData.length - pos};
        foundSep = [theData rangeOfData:lookingFor options:0 range:newRange];
        
        if(foundSep.location == NSNotFound)
            break;
        else
            lineData = [NSData dataWithBytes:((char*) theData.bytes)+pos length:foundSep.location-pos];
        
        if(lineData.bytes)
            lineStr = [NSString stringWithUTF8String:lineData.bytes];
        else
            lineStr = @"";
        
        if(isContent)
        {
            NSRange r = {0, lineData.length-2};//remove LF CR
            [self insertImgWithSiluetaId:siluetaId siluetsTypId:siluetaTypId image:[lineData subdataWithRange:r]];
            foundSep.length += 3; // kontrola noveho riadku
        }
        else
        {
            NSString *delimiter = @":";
            NSArray *array = [lineStr componentsSeparatedByString:delimiter];
            if([array[0] isEqualToString:@"SiluetaTypID"])
                siluetaTypId = [array[1] integerValue];
            else if([array[0] isEqualToString:@"SiluetaID"])
                siluetaId = [array[1] integerValue];

        }
        
        if(!lineStr.length && !isContent)//[line isEqualToData:[@"\r" dataUsingEncoding:NSASCIIStringEncoding]])
        {
            isContent = YES;
            lookingFor = sepData;
        }
        else
        {
            isContent = NO;
            lookingFor = [@"\r\n" dataUsingEncoding:NSASCIIStringEncoding];
        }
        
    }
    [fm removeItemAtPath:dataPath error:nil];
    
    NSLog(@"    Ending parse siluets with time :%f", ti);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"parseFinishNotification" object:@"SiluetsParsed"];
}



@end
