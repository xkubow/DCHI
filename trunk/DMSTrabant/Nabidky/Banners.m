    //
//  Baners.m
//  DirectCheckin
//
//  Created by Jan Kubis on 14.02.13.
//
//

#import "Banners.h"
#import "FMDatabaseAdditions.h"
#import "DMSetting.h"
#import "TrabantAppDelegate.h"
#import "BaseDBManager.h"


#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])
#define ROOTNAVIGATOR ([TRABANT_APP_DELEGATE rootNavController])


@implementation Banner

@synthesize banner=_baner;
@synthesize bannerhash=_bannerhash;

-(Banner*)initWithHash:(NSString*)hash imgData:(NSData*)imgData
{
    self = [super init];
    if(self)
    {
        _bannerhash = hash;
        _baner = imgData;
    }
    return self;
}

@end


@interface DBBanners()
{
    FMDatabase *database;
    NSArray *bannerImages;
}

@end

@implementation DBBanners

-(DBBanners*)init
{
    self = [super init];
    if(self)
    {
        database = [self database];
        bannerImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"baner1"],
                        [UIImage imageNamed:@"baner2"],
                        [UIImage imageNamed:@"baner3"],
                        [UIImage imageNamed:@"baner4"],
                        [UIImage imageNamed:@"baner5"], nil];
    }
    return self;
}

-(void)checkNabidky
{
}

- (Banner*) getBannerForHash:(NSString*)hash
{
    NSString *banerHash;
    NSData *imgData;
    
    if (![database open]) {
        NSLog(@"Could not open db.");
        return nil;
    }
    
    FMResultSet *banerResult = [database executeQuery:@"SELECT hash, img FROM BANNERS WHERE hash LIKE ?", hash];

    if(database.lastError.code) {
        NSLog(@"check banner hash: %@", database.lastError);
        return nil;
    }
    
    while ([banerResult next]) {
        banerHash = [banerResult stringForColumn:@"hash"];
        imgData = [banerResult dataForColumn:@"img"];
    }
    [banerResult close];
    [database close];
    
    if(!banerHash.length)
        return nil;
    
    Banner *b = [[Banner alloc] initWithHash:banerHash imgData:imgData];
    
    return b;
}

- (void)insertBanner:(NSData *)banner banerHash:(NSString*)bannerHash
{
    if (![database open]) {
        NSLog(@"Could not open db.");
        return;
    }
    
    [database executeUpdate:@"INSERT INTO BANNERS(hash, img) values(?, ?)", bannerHash, banner];
    if(database.lastError.code)
        NSLog(@"insertBanner: %@", database.lastError);
    
    [database close];
}

- (void)setBannersFromCheckin:(NSArray*)data
{
    for(NSMutableDictionary *d in data)
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT ADVERT_BANNER FROM CHECK_OFFER WHERE CHECK_OFFER_ID = %@", [d valueForKey:@"CHECK_OFFER_ID"]];
        NSData *bannerImage = [[[BaseDBManager sharedBaseDBManager] preformOnStaticDBSelect:sql].lastObject objectForKey:@"ADVERT_BANNER"];
        [d setValue:bannerImage forKey:@"ADVERT_BANNER"];
    }
    [DMSetting sharedDMSetting].nabidky = data;
}



-(void) reloadData
{
    if([DMSetting sharedDMSetting].isLoadingCheckinData)
        return;
    
    NSString *vyrobekVoz = [[DMSetting sharedDMSetting].vozidlo valueForKey:@"BRAND_ID"];
    BaseDBManager *bdb = [BaseDBManager sharedBaseDBManager];
    
    NSDate *date = [NSDate date];
    
    NSNumber *nDate = [NSNumber numberWithDouble:[date timeIntervalSince1970]];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM (SELECT CO.ADVERT_BANNER, CO.BRAND_ID, CO.CHECK_OFFER_ID, CO.SHOW_OFFER,"
                     "ifnull(COL.CHECK_OFFER_TXT_LOC, CO.CHECK_OFFER_TXT_DEF) AS TEXT, strftime('%%Y-%%m-%%dT%%H:%%M:%%S', DATETIME(CO.INSERTED, 'unixepoch')) AS INSERTED_UTC, "
                     "strftime('%%Y-%%m-%%dT%%H:%%M:%%S', DATETIME(CO.LAST_UPDATED, 'unixepoch')) AS LAST_UPDATED_UTC, CO.SELL_PRICE, CO.SHOW_TXT, COL.LANG_ENUM, "
                     "strftime('%%Y-%%m-%%dT%%H:%%M:%%S', DATETIME(CO.VALID_FROM, 'unixepoch')) AS VALID_FROM_UTC, CO.VALID_FROM, "
                     "strftime('%%Y-%%m-%%dT%%H:%%M:%%S', DATETIME(CO.VALID_UNTIL, 'unixepoch')) AS VALID_UNTIL_UTC, CO.VALID_UNTIL "
                     "FROM CHECK_OFFER CO LEFT OUTER JOIN CHECK_OFFER_LOC COL ON COL.CHECK_OFFER_ID = CO.CHECK_OFFER_ID AND COL.LANG_ENUM= \"%1$@\") "
                     "WHERE VALID_FROM < %3$@ AND VALID_UNTIL > %3$@ "
                     "AND SHOW_OFFER = 1 AND ifnull(BRAND_ID, \"%2$@\") = \"%2$@\" ", TRABANT_APP_DELEGATE.actualLanguage, vyrobekVoz, nDate];
    [bdb openDB];
    FMResultSet *result = [bdb.database executeQuery:sql];
    
    if(bdb.database.lastError.code)
        NSLog(@"loadSiluetID error:%@", bdb.database.lastError);
    
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    NSLog(@"   Loading SQL banners   :%@", sql);
    while ([result next]) {
        NSData *bannerImage =  [result dataForColumn:@"ADVERT_BANNER"];
        NSLog(@"   Loaded image with size bytes :%d", bannerImage.length);
        [resultArray addObject: [result resultDictionary]];
    }
    
    [result close];
    [bdb closeDB];
    
    [DMSetting sharedDMSetting].nabidky = resultArray;
    
}

-(void)insertImageBaner:(NSData *)img banerId:(NSInteger)banerId
{
    NSLog(@"    Inserting baner image CHECK_OFFER_ID = %d, %d\n", banerId, img.length);
    BaseDBManager *baseDBManager = [BaseDBManager sharedBaseDBManager];
    
    [baseDBManager openDB];
    [baseDBManager.database executeUpdate:@"UPDATE CHECK_OFFER set ADVERT_BANNER=? WHERE CHECK_OFFER_ID=?", img, [NSNumber numberWithInt:banerId]];
    if(baseDBManager.database.lastError.code)
        NSLog(@"insertImageBaner error: %@\ndebug description :%@", baseDBManager.database.lastError, baseDBManager.database.debugDescription);
    
    [baseDBManager closeDB];
}

-(NSData *) getDataFromHex:(NSString *)hexStr {
//    NSString *command = @"72ff63cea198b3edba8f7e0c23acc345050187a0cde5a9872cbab091ab73e553";
    
    hexStr = [hexStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSMutableData *commandToSend= [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [hexStr length]/2; i++) {
        byte_chars[0] = [hexStr characterAtIndex:i*2];
        byte_chars[1] = [hexStr characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [commandToSend appendBytes:&whole_byte length:1];
    }
    NSLog(@"%@", commandToSend);
    return commandToSend;
}



-(void)parseBaners
{
    BOOL doIt = YES;
    BOOL isContent = NO;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachDir = [paths objectAtIndex:0];
    NSString *dataPath = [cachDir stringByAppendingPathComponent:@"banersData"];
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSData *pngHeader = [self getDataFromHex:@"89504E470D0A1A0A"];
    NSLog(@"png header :%@", pngHeader);
    
    if(![fm fileExistsAtPath:dataPath])
    {
        NSLog(@"file banersData not exist");
        return;
    }
    
    NSTimeInterval ti = [[NSDate date] timeIntervalSinceNow];
    NSLog(@"   Starting parse banners");
    NSInteger banerId = -1;
    NSData *theData = [NSData dataWithContentsOfFile:dataPath];
    NSData *lookingFor = [@"\r\n" dataUsingEncoding:NSASCIIStringEncoding];
    NSRange sepRange = {0, theData.length};
    NSRange foundSep = [theData rangeOfData:lookingFor options:0 range:sepRange];
    NSData *lineData;
    NSData *sepData= [NSData dataWithBytes:((char*) theData.bytes) length:foundSep.location-1];
    NSString *lineStr = [NSString stringWithUTF8String:sepData.bytes];
    
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
        
        if(isContent && banerId > 0)
        {
            NSRange r1 = {lineData.length-10, 10};
            NSRange r2 = {0, 8};
            NSString *log;
            NSLog(@"find Content for image :%d", banerId);
            NSLog(@"\nstart :%@\nend :%@", [lineData subdataWithRange:r2], [lineData subdataWithRange:r1]);
            log = @"\n deleted data :";
            while(![[lineData subdataWithRange:r2] isEqualToData:pngHeader] && lineData.length > 8) {
                NSRange delrange = {0,1};
                log = [log stringByAppendingFormat:@"%@",[lineData subdataWithRange:delrange]];
                NSRange newRange = {1, lineData.length-1};
                lineData = [lineData subdataWithRange:newRange];
                NSLog(@"\nnew start :%@", [lineData subdataWithRange:r2]);
            }
            log = [log stringByAppendingString:@"\n"];
            NSLog(@"%@", log);
            NSRange r = {0, lineData.length-2};//remove LF CR
            [self insertImageBaner:[lineData subdataWithRange:r] banerId:banerId];
            foundSep.length += 3; // kontrola noveho riadku
        }
        else
        {
            NSString *delimiter = @":";
            NSArray *array = [lineStr componentsSeparatedByString:delimiter];
            if([array[0] isEqualToString:@"CHECK_OFFER_ID"])
                banerId = [array[1] integerValue];
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
    NSLog(@"   End parse banners with time :%f", ti);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"parseFinishNotification" object:@"BannersParsed"];
}


@end
