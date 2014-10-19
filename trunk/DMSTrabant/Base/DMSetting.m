//
//  DMSetting.m
//  Mobile checkin
//
//  Created by Jan Kubis on 29.02.12.
//  Copyright (c) 2012 jan.kubis@t-systems.cz. All rights reserved.
//

#import "DMSetting.h"
#import "TrabantAppDelegate.h"
#import "DejalActivityView.h"

#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])
#define ROOTNAVIGATOR ([TRABANT_APP_DELEGATE rootNavController])

@interface DMSetting()
{
}

@end

@implementation DMSetting
@synthesize nabidky=_nabidky;
@synthesize vybavy=_vybavy;
@synthesize povVybavy=_povVybavy;
@synthesize pozadavky, vozInfo, zakaznikInfo, vozHistory, SDA, PZ;
@synthesize vozidlo=_vozidlo;
@synthesize zakaznik=_zakaznik;
@synthesize scenar=_scenar;
@synthesize printers;
@synthesize sluzby=_sluzby;
@synthesize loadetSiluets=_loadetSiluets;
@synthesize planovaneZakazky=_planovaneZakazky;
@synthesize setting=_setting;
@synthesize loggedUser=_loggedUser;
@synthesize takenImages=_takenImages;
@synthesize pdfReportFilePath=_pdfReport;
@synthesize baners=_baners;
@synthesize siluets=_siluets;
@synthesize vyrobekVoz=_vyrobekVoz;
@synthesize palivoArray=_palivoArray;
@synthesize celky=_celky;
@synthesize casti=_casti;
@synthesize pakety=_pakety;
@synthesize points=_points;
@synthesize vozidla=_vozidla;
@synthesize showProtocol=_showProtocol;
@synthesize isLoadingCheckinData=_isLoadingCheckinData;
@synthesize defaultPrinterIdx=_defaultPrinterIdx;
@synthesize odlozPoloz=_odlozPoloz;
@synthesize workStepId=_workStepId;

-(id) init
{
    self = [super init];
    if(self) {
        _baners = [[DBBanners alloc] init];
        _siluets = [[DBSiluets alloc] init];
        _loadetSiluets = [NSMutableArray arrayWithObjects:[UIImage imageNamed:@"OctavkaLavyBok.png"], [UIImage imageNamed:@"OctavkaZadok.png"], [UIImage imageNamed:@"OctavkaPravyBok.png"], [UIImage imageNamed:@"OctavkaPredok.png"], [UIImage imageNamed:@"OctavkaStrecha.png"], nil];
        _takenImages = [[NSMutableArray alloc]init];
        _points = [DMPoints sharedDMPoints];
        _showProtocol = NO;
        _isLoadingCheckinData = NO;
    }
    return self;
}

+ (DMSetting *) sharedDMSetting { 
    static DMSetting * shared = nil;
    if ( !shared )
        shared = [[self alloc] init];
    return shared; 
}

-(NSDictionary*)vozidlo
{
    if(_vozidlo == nil)
        _vozidlo = [[NSMutableDictionary alloc] init];
    
    return _vozidlo;
}

- (void) dealloc
{
    _workStepId = nil;
    _vybavy = nil;
    _povVybavy = nil;
    _nabidky = nil;
    _vyrobekVoz = nil;
    _scenar = nil;
    pozadavky = nil;
    vozInfo = nil;
    zakaznikInfo = nil;
    vozHistory = nil;
    SDA = nil;
    PZ = nil;
    _odlozPoloz = nil;
    _celky = nil;
    _casti = nil;
    _vozidlo = nil;
    printers = nil;
    _sluzby = nil;
    _pdfReport=nil;
}

- (NSDictionary *) setting
{
    if(_setting == nil)
        _setting = [[NSDictionary alloc] init];
    return _setting;
}

- (void)setNabidky:(NSArray *)nabidky
{
    _nabidky = nabidky;
    [_baners checkNabidky];
}

- (NSArray *) getArrayByRonwNum:(NSInteger)rowNum
{
    NSArray *ret = nil;
    switch (rowNum) {
        case 0:
            ret = _vybavy;
            break;
        case 1:
            ret = _povVybavy;
            break;
        case 2:
            ret = _nabidky;
            break;
            
        default:
            break;
    }
    
    
    return ret;
}

- (void)setAllValuesTo:(BOOL)val
{

    for (NSMutableDictionary *d in _vybavy)
        [d setValue:@"0" forKey:@"CHECKED"];
    for (NSMutableDictionary *d in _povVybavy)
        [d setValue:@"0" forKey:@"CHECKED"];
    for (NSMutableDictionary *d in _nabidky)
        [d setValue:@"0" forKey:@"CHECKED"];
    for (NSMutableDictionary *d in _sluzby)
        [d setValue:@"0" forKey:@"CHECKED"];
}

-(UIImage *) getPozadIcon:(NSInteger)enumPozad
{
    switch(enumPozad)
    {
        case -1:
            return [UIImage imageNamed:@"celky_nezadano"];
            break;
        case 0:
            return [UIImage imageNamed:@"celky_povinny_ok"];
            break;
        case 20:
            return [UIImage imageNamed:@"celky_olozeni"];
            break;
        default:
            return [UIImage imageNamed:@"celky_servis"];
    }
    
    return nil;
}

- (NSDictionary*) getActualScenarData
{
    NSInteger scenarId = [[_vozidlo valueForKey:@"CHECK_SCENARIO_ID"] integerValue];
    NSDictionary *d = [_scenar filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"CHECK_SCENARIO_ID.intValue == %d", scenarId]].lastObject;
    return d;
}

- (void)clearAllData
{
    _workStepId = @"";
    _vozidla = nil;
    _vozidlo = nil;
    pozadavky = nil;
    vozInfo = nil;
    zakaznikInfo = nil;
    vozHistory = nil;
    _nabidky = nil;
    SDA = nil;
    PZ = nil;
    _celky = nil;
    _casti = nil;
    _takenImages = [[NSMutableArray alloc]init];
    [_points removeAllData];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *imageSubdirectory = [documentsDirectory stringByAppendingPathComponent:@"CheckinImages"];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if ([fileMgr fileExistsAtPath:imageSubdirectory]) {
        NSError *error = nil;
        [fileMgr removeItemAtPath:imageSubdirectory error:&error];
        if(error != nil)
            NSLog(@"%@", [error description]);
    }
}

- (void) removeProtokolFiles
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileNameProt = [NSString stringWithFormat:@"protocol.pdf"];
    NSString *fileNameProtImg = [NSString stringWithFormat:@"protocolImage.png"];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileNameProt];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    
    if([fm fileExistsAtPath:filePath])
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    
    filePath = [documentsDirectory stringByAppendingPathComponent:fileNameProtImg];
    if([fm fileExistsAtPath:filePath])
        [[NSFileManager defaultManager] removeItemAtPath:fileNameProtImg error:&error];
}

- (void) reloadSiluets
{
    NSString *typKod = @"";
    UIImage *img;
    NSArray *siluets;
    NSString *vyrobekVoz = [_vozidlo valueForKey:@"BRAND_ID"];
    if(existInDic(_vozidlo, @"VEHICLE_TYPE"))
        typKod = [_vozidlo valueForKey:@"VEHICLE_TYPE"];
    
    if(existInDic(_vozidlo, @"SILHOUETTE_ID"))
        siluets = [_siluets loadImagesWithSiluetaId:[_vozidlo valueForKey:@"SILHOUETTE_ID"]];
    else
    {
        siluets = [_siluets loadSiluetsWithVyrVoz:vyrobekVoz typKod:typKod][0];
        if(existInDic(siluets[0], @"SILHOUETTE_ID"))
            [[DMSetting sharedDMSetting].vozidlo setValue:[siluets[0] valueForKey:@"SILHOUETTE_ID"] forKey:@"SILHOUETTE_ID"];
    }
    
    for(NSDictionary *d in siluets)
    {
        NSInteger siluetaTypId = [[d valueForKey:@"SILHOUETTE_TYPE_ID"] integerValue];
        if([d valueForKey:@"IMAGE"] != [NSNull null])
        {
            NSData *imgData = [d valueForKey:@"IMAGE"];
            img = [UIImage imageWithData:imgData];
        }
        else
            img = [[UIImage alloc] init];
        [DMSetting sharedDMSetting].loadetSiluets[siluetaTypId-1] = img;
    }
    [DejalBezelActivityView removeViewAnimated:YES];
}

-(void)removeSluzbyData
{
    [_vybavy removeAllObjects];
    _povVybavy = nil;
    [_sluzby removeAllObjects];
}

-(void)removeAllData
{
    _workStepId = @"";
    _pakety = nil;
    _vozidla = nil;
    _vozidlo = nil;
    zakaznikInfo = nil;
    vozInfo = nil;
    vozHistory = nil;
    SDA = nil;
    PZ = nil;
}

- (void) parseCheckinData:(NSDictionary*)data
{
    NSDictionary *actualScenar = [self getActualScenarData];
    NSArray *equipment = [data objectForKey:@"EQUIPMENT"];
    
    for(NSMutableDictionary *d in equipment)
    {
        [d setValue:[d objectForKey:@"CAR_EQUIPMENT_TXT"] forKey:@"TEXT"];
        [d removeObjectForKey:@"CAR_EQUIPMENT_TXT"];
    }

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"OBLIGATORY_EQUIPMENT.intValue = %@", @0];
    NSArray *vybavyNoObArray = [equipment filteredArrayUsingPredicate:predicate];
    
    NSInteger freeOptionCount = [[actualScenar valueForKey:@"EQUIPMENT_FREE_COUNT"] integerValue];
    NSMutableArray *freeEquitment;
    if(existInDic(data, @"EQUIPMENT_FREE"))
        freeEquitment = [data objectForKey:@"EQUIPMENT_FREE"];
    else
        freeEquitment = [[NSMutableArray alloc] init];
    
    for(int i=0; i<freeOptionCount; i++)
    {
        if(i<freeEquitment.count)
        {
            NSMutableDictionary *d = freeEquitment[i];
            [d setValue:@1 forKey:@"EDITABLE"];
            [d setValue:@1 forKey:@"CHECKED"];
            [d setValue:[d objectForKey:@"CHECKIN_EQUIPMENT_FREE_TXT"] forKey:@"TEXT"];
            [d removeObjectForKey:@"CHECKIN_EQUIPMENT_FREE_TXT"];
        }
        else
            [freeEquitment addObject:[@{@"EDITABLE":@1} mutableCopy]];
    }
    
    NSIndexSet *index = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, vybavyNoObArray.count)];
    [freeEquitment insertObjects:vybavyNoObArray atIndexes:index];
    [DMSetting sharedDMSetting].vybavy = freeEquitment.mutableCopy;
    
    predicate = [NSPredicate predicateWithFormat:@"OBLIGATORY_EQUIPMENT.intValue = %@", @1];
    NSArray *vybavyObArray = [equipment filteredArrayUsingPredicate:predicate];
    [DMSetting sharedDMSetting].povVybavy = vybavyObArray;
    
    NSArray *sluzbyArray = [data objectForKey:@"SERVICE"];
    for(NSMutableDictionary *d in sluzbyArray)
    {
        [d setValue:[d valueForKey:@"CHECK_SERVICE_TXT"] forKey:@"TEXT"];
        [d removeObjectForKey:@"CHECK_SERVICE_TXT"];
    }
    
    NSMutableArray *freeSluzbyArray;
    if(existInDic(data, @"SERVICE_FREE"))
        freeSluzbyArray = [data objectForKey:@"SERVICE_FREE"];
    else
        freeSluzbyArray = [[NSMutableArray alloc] init];

    freeOptionCount = [[actualScenar valueForKey:@"SERVICE_FREE_COUNT"] integerValue];
    for(int i=0; i<freeOptionCount; i++)
    {
        if(i < freeSluzbyArray.count)
        {
            NSMutableDictionary *d = freeSluzbyArray[i];
            [d setValue:@1 forKey:@"EDITABLE"];
            [d setValue:@1 forKey:@"CHECKED"];
            [d setValue:[d objectForKey:@"CHECKIN_SERVICE_FREE_TXT"] forKey:@"TEXT"];
            [d removeObjectForKey:@"CHECKIN_SERVICE_FREE_TXT"];
        }
        else
            [freeSluzbyArray addObject:[@{@"EDITABLE":@1} mutableCopy]];
    }
    
    index = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, sluzbyArray.count)];
    [freeSluzbyArray insertObjects:sluzbyArray atIndexes:index];
    [DMSetting sharedDMSetting].sluzby = freeSluzbyArray;
}

-(void)parseLoadedScenare:(NSDictionary*)data
{
    
    NSArray *units = [[data objectForKey:@"UNIT"] valueForKeyPath:@"@distinctUnionOfObjects.CHCK_UNIT_ID"];
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT DATA.*, 0 AS MANDATORY FROM "
           "(SELECT ifnull(UL.CHCK_UNIT_TXT_LOC, U.CHCK_UNIT_TXT_DEF) AS TEXT, U.CHCK_UNIT_ID "
           "FROM CHCK_UNIT U LEFT OUTER JOIN CHCK_UNIT_LOC UL ON U.CHCK_UNIT_ID = UL.CHCK_UNIT_ID AND UL.LANG_ENUM = '%1$@') DATA "
           "WHERE DATA.CHCK_UNIT_ID IN (%2$@) ", TRABANT_APP_DELEGATE.actualLanguage, [units componentsJoinedByString:@", "]];
    
    NSArray *unitsArray = [[BaseDBManager sharedBaseDBManager] preformOnStaticDBSelect:sql];
    _celky = unitsArray;

    
    NSMutableArray *detailData =[[NSMutableArray alloc] initWithCapacity:unitsArray.count];
    for(NSDictionary *dUnits in unitsArray)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"CHCK_UNIT_ID.intValue = %@", [dUnits valueForKey:@"CHCK_UNIT_ID"]];
        NSArray *casti = [[data objectForKey:@"UNIT"] filteredArrayUsingPredicate:predicate];
        for(NSMutableDictionary *d in casti)
        {
            if(existInDic(d, @"CHECKIN_WORKSHOP_PACKET_ID"))
            {
                NSMutableDictionary *wd = [[NSMutableDictionary alloc] init];
                if(existInDic(d, @"SPARE_PART_DISPON_ID"))
                   [wd setValue:[d valueForKey:@"SPARE_PART_DISPON_ID"] forKey:@"SPARE_PART_DISPON_ID"];
                else
                   [wd setValue:@0 forKey:@"SPARE_PART_DISPON_ID"];
                
                if(existInDic(d, @"ECONOMIC"))
                    [wd setValue:[d valueForKey:@"ECONOMIC"] forKey:@"ECONOMIC"];
                else
                    [wd setValue:@0 forKey:@"ECONOMIC"];
                
                if(existInDic(d, @"WORKSHOP_PACKET_NUMBER"))
                    [wd setValue:[d valueForKey:@"WORKSHOP_PACKET_NUMBER"] forKey:@"WORKSHOP_PACKET_NUMBER"];
                else
                    [wd setValue:[NSNull null] forKey:@"WORKSHOP_PACKET_NUMBER"];
                
                if(existInDic(d, @"WORKSHOP_PACKET_DESCRIPTION"))
                    [wd setValue:[d valueForKey:@"WORKSHOP_PACKET_DESCRIPTION"] forKey:@"WORKSHOP_PACKET_DESCRIPTION"];
                else
                    [wd setValue:[NSNull null] forKey:@"WORKSHOP_PACKET_DESCRIPTION"];
                
                if(existInDic(d, @"RESTRICTIONS"))
                {
                    NSString *text = [NSString stringWithFormat:@"%@ %@", [d objectForKey:@"CHCK_REQUIRED_TXT"], [d objectForKey:@"RESTRICTIONS"]];
                    [d setValue:text forKey:@"CHCK_REQUIRED_TXT"];
                }
                [d setValue:wd forKey:@"WORKSHOP_PACKET"];
            }
        }
        [detailData addObject:casti];
    }
    
    _casti = detailData;
    
}

-(void)loadScenarDataFromDB
{
    NSDictionary *actualScenar = [self getActualScenarData];
    NSMutableArray *freeOptions = [[NSMutableArray alloc] init];
    NSInteger freeOptionCount;// = [[actualScenar valueForKey:@"SERVICE_FREE_COUNT"] integerValue];
    NSMutableString *sql;
    
    NSDate *date = [NSDate date];
    NSNumber *nDate = [NSNumber numberWithDouble:[date timeIntervalSince1970]];
    
    //*********************** UNITS ***********************//
    
    //load datat from DB
    sql = [NSMutableString stringWithFormat:@"SELECT DATA.*, SU.MANDATORY AS MANDATORY FROM "
           "(SELECT ifnull(UL.CHCK_UNIT_TXT_LOC, U.CHCK_UNIT_TXT_DEF) AS TEXT, U.CHCK_UNIT_ID "
           "FROM CHCK_UNIT U LEFT OUTER JOIN CHCK_UNIT_LOC UL ON U.CHCK_UNIT_ID = UL.CHCK_UNIT_ID AND UL.LANG_ENUM = '%@') DATA, CHECK_SCENARIO_UNIT SU "
           "WHERE DATA.CHCK_UNIT_ID = SU.CHCK_UNIT_ID "
           "AND SU.CHECK_SCENARIO_ID = %@", TRABANT_APP_DELEGATE.actualLanguage, [actualScenar valueForKey:@"CHECK_SCENARIO_ID"]];
    
    NSArray *unitsArray = [[BaseDBManager sharedBaseDBManager] preformOnStaticDBSelect:sql];
    _celky = unitsArray;
    
    [sql setString: @"SELECT DATAPOS.*, DATAPART.*, PP.CHCK_PART_POSITION_ID AS CHCK_PART_POSITION_ID, '' AS SELL_PRICE "
     "FROM (SELECT ifnull(PL.CHCK_POSITION_TXT_LOC, P.CHCK_POSITION_TXT_DEF) AS CHCK_POSITION_TXT, "
     " ifnull(PL.CHCK_POSITION_ABBREV_TXT_LOC, P.CHCK_POSITION_ABBREV_TXT_DEF) AS CHCK_POSITION_ABBREV_TXT, P.CHCK_POSITION_ID "
     "FROM CHCK_POSITION P LEFT OUTER JOIN CHCK_POSITION_LOC PL "
     "ON PL.CHCK_POSITION_ID = P.CHCK_POSITION_ID "
     "AND PL.LANG_ENUM = '%1$@') DATAPOS, "
     "(SELECT ifnull(PL.CHCK_PART_TXT_LOC, P.CHCK_PART_TXT_DEF) AS CHCK_PART_TXT, P.CHCK_PART_ID, P.CHCK_UNIT_ID "
     "FROM CHCK_PART P LEFT OUTER JOIN CHCK_PART_LOC PL "
     "ON PL.CHCK_PART_ID = P.CHCK_PART_ID "
     "AND PL.LANG_ENUM = '%1$@' "
     "WHERE P.CHCK_UNIT_ID = %2$@) DATAPART, "
     "CHCK_PART_POSITION PP "
     "WHERE DATAPOS.CHCK_POSITION_ID = PP.CHCK_POSITION_ID "
     "AND PP.CHCK_PART_ID = DATAPART.CHCK_PART_ID "];
    
    NSMutableArray *detailData =[[NSMutableArray alloc] initWithCapacity:unitsArray.count];
    for (NSDictionary *d in unitsArray) {
        NSString *theSql = [NSString stringWithFormat:sql, TRABANT_APP_DELEGATE.actualLanguage, [d valueForKey:@"CHCK_UNIT_ID"]];
        NSArray *partArray = [[BaseDBManager sharedBaseDBManager] preformOnStaticDBSelect:theSql];
        [detailData addObject:partArray];
    }
    
    _casti = detailData;
    //*********************** UNITS ***********************//
    
    
    //*********************** EQUITMENTS ***********************//
    
    NSString *brandId = [[DMSetting sharedDMSetting].vozidlo valueForKey:@"BRAND_ID"];
    sql = [NSMutableString stringWithString:@"SELECT * FROM ( SELECT CE.*, CEL.*, ifnull(CEL.CAR_EQUIPMENT_TXT_LOC, CE.CAR_EQUIPMENT_TXT_DEF) AS TEXT "];
    [sql appendString:@"FROM CAR_EQUIPMENT CE LEFT OUTER JOIN CAR_EQUIPMENT_LOC CEL ON CE.CAR_EQUIPMENT_ID = CEL.CAR_EQUIPMENT_ID "];
    [sql appendFormat:@"AND CEL.LANG_ENUM = \"%@\")", TRABANT_APP_DELEGATE.actualLanguage];
    [sql appendFormat:@"WHERE SHOW_EQUIPMENT = 1 AND ifnull(BRAND_ID, \"%1$@\") = \"%1$@\"", brandId];
    NSArray *vybavyArray = [[BaseDBManager sharedBaseDBManager] preformOnStaticDBSelect:sql];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"OBLIGATORY_EQUIPMENT.intValue = %@", @0];
    NSArray *vybavyNoObArray = [vybavyArray filteredArrayUsingPredicate:predicate];
    
    freeOptionCount = [[actualScenar valueForKey:@"EQUIPMENT_FREE_COUNT"] integerValue];
    NSArray *allKeys = @[@"OBLIGATORY_EQUIPMENT",
                         @"LAST_UPDATED",
                         @"CAR_EQUIPMENT_TXT_LOC",
                         @"CAR_EQUIPMENT_ID",
                         @"INSERTED",
                         @"BRAND_ID",
                         @"CAR_EQUIPMENT_TXT_DEF",
                         @"TEXT",
                         @"SHOW_EQUIPMENT",
                         @"LANG_ENUM"];
    for(int i=0; i<freeOptionCount; i++)
    {
        [freeOptions addObject:[NSMutableDictionary dictionaryWithSharedKeySet:[NSDictionary sharedKeySetForKeys:allKeys/*[vybavyArray[0] allKeys]*/]]];
        [freeOptions.lastObject setValue:@1 forKey:@"EDITABLE"];
    }
    NSIndexSet *index = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, vybavyNoObArray.count)];
    [freeOptions insertObjects:vybavyNoObArray atIndexes:index];
//    _log = [NSString stringWithFormat:@"%@\n\n      VOLNE VYBAVY\n%@", _log, freeOptions];
    [DMSetting sharedDMSetting].vybavy = freeOptions.mutableCopy;
    
    predicate = [NSPredicate predicateWithFormat:@"OBLIGATORY_EQUIPMENT.intValue = %@", @1];
    NSArray *vybavyObArray = [vybavyArray filteredArrayUsingPredicate:predicate];
    
    if([[[DMSetting sharedDMSetting].setting valueForKey:@"OBLIGATORY_EQUIPMENT_CHECKED"] boolValue])
        for(NSDictionary *d in vybavyObArray)
            [d setValue:@"1" forKey:@"CHECKED"];
//    _log = [NSString stringWithFormat:@"%@\n\n      POVINNE VYBAVY\n%@", _log, vybavyObArray];    
    [DMSetting sharedDMSetting].povVybavy = vybavyObArray;
    //*********************** EQUITMENTS ***********************//
    
    
    
    //*********************** SERVICES ***********************//
    
    sql = [NSMutableString stringWithString:@"SELECT * FROM ( SELECT S.*, SL.*, ifnull(SL.CHECK_SERVICE_TXT_LOC, S.CHECK_SERVICE_TXT_DEF) AS TEXT "];
    [sql appendString:@"FROM CHECK_SERVICE S LEFT OUTER JOIN CHECK_SERVICE_LOC SL ON S.CHECK_SERVICE_ID = SL.CHECK_SERVICE_ID "];
    [sql appendFormat:@"AND SL.LANG_ENUM = \"%1$@\") ", TRABANT_APP_DELEGATE.actualLanguage];
    [sql appendFormat:@"WHERE ifnull(BRAND_ID, \"%1$@\") = \"%1$@\" ", brandId];
    [sql appendFormat:@"AND SHOW_SERVICE = 1 AND VALID_FROM < %1$@ AND VALID_UNTIL > %1$@ ", nDate];
    NSArray *sluzbyArray = [[BaseDBManager sharedBaseDBManager] preformOnStaticDBSelect:sql];
    
    allKeys = @[@"OBLIGATORY_EQUIPMENT",
               @"LAST_UPDATED",
               @"CAR_EQUIPMENT_TXT_LOC",
               @"CAR_EQUIPMENT_ID",
               @"INSERTED",
               @"BRAND_ID",
               @"CAR_EQUIPMENT_TXT_DEF",
               @"TEXT",
               @"SHOW_EQUIPMENT",
               @"LANG_ENUM"];
    freeOptionCount = [[actualScenar valueForKey:@"SERVICE_FREE_COUNT"] integerValue];
    [freeOptions removeAllObjects];
    for(int i=0; i<freeOptionCount; i++)
    {
        [freeOptions addObject:[NSMutableDictionary dictionaryWithSharedKeySet:[NSDictionary sharedKeySetForKeys:allKeys/*[vybavyArray[0] allKeys]*/]]];
        [freeOptions.lastObject setValue:@1 forKey:@"EDITABLE"];
    }
    index = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, sluzbyArray.count)];
    [freeOptions insertObjects:sluzbyArray atIndexes:index];
    [DMSetting sharedDMSetting].sluzby = freeOptions;
    //*********************** SERVICES ***********************//
}

- (void)reloadScenare
{
    NSString *brandId = [_vozidlo valueForKey:@"BRAND_ID"];
    NSMutableString *sql = [NSMutableString stringWithString:@"SELECT * FROM ( SELECT CS.*, CSL.*, ifnull(CSL.CHECK_SCENARIO_TXT_LOC, CS.CHECK_SCENARIO_TXT_DEF) AS TEXT "];
    [sql appendString:@"FROM CHECK_SCENARIO CS LEFT OUTER JOIN CHECK_SCENARIO_LOC CSL ON CS.CHECK_SCENARIO_ID = CSL.CHECK_SCENARIO_ID "];
    [sql appendFormat:@"AND CSL.LANG_ENUM = \"%@\") ", TRABANT_APP_DELEGATE.actualLanguage];
    [sql appendFormat:@"WHERE ifnull(BRAND_ID, \"%1$@\") = \"%1$@\" AND SHOW_SCENARIO = 1", brandId];
    _scenar = [[BaseDBManager sharedBaseDBManager] preformOnStaticDBSelect:sql];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"BRAND_ID = %@", brandId];
    NSDictionary *vyrVozDic = [[DMSetting sharedDMSetting].vyrobekVoz filteredArrayUsingPredicate:predicate].lastObject;
    NSInteger scenarId = -1;
    

    if([_vozidlo valueForKey:@"CHECK_SCENARIO_ID"] != nil && [_vozidlo valueForKey:@"CHECK_SCENARIO_ID"] != [NSNull null])
        scenarId = [[_vozidlo valueForKey:@"CHECK_SCENARIO_ID"] integerValue];
    
    predicate = [NSPredicate predicateWithFormat:@"CHECK_SCENARIO_ID.intValue = %d", scenarId];
    NSArray *scenar = [_scenar filteredArrayUsingPredicate:predicate];
    
    if(!scenar.count)
        scenarId = [[vyrVozDic valueForKey:@"CHECK_SCENARIO_ID_DEF"] integerValue];
    
    [_vozidlo setValue:[NSNumber numberWithInt:scenarId] forKey:@"CHECK_SCENARIO_ID"];
    
    //load UNIT DATA
    
    
    //load datat from returned Checkin
    if(_isLoadingCheckinData)
        return;
    
    [self loadScenarDataFromDB];
}

-(void)loadVyrVoz
{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT B.*, ifnull(BL.BRAND_TXT_LOC, B.BRAND_TXT_DEF) AS BRAND_TXT FROM BRAND B LEFT OUTER JOIN BRAND_LOC BL ON BL.BRAND_ID = B.BRAND_ID AND BL.LANG_ENUM = '%@'", TRABANT_APP_DELEGATE.actualLanguage];
    [DMSetting sharedDMSetting].vyrobekVoz = [[BaseDBManager sharedBaseDBManager] preformOnStaticDBSelect:sql];
}

-(void)loadPalivo
{
    NSString *sql = [NSString stringWithFormat:@"SELECT F.*, ifnull(FL.FUEL_TXT_LOC, F.FUEL_TXT_DEF) AS TEXT "
           "FROM FUEL F LEFT OUTER JOIN FUEL_LOC FL ON F.FUEL_ID = FL.FUEL_ID "
           "AND FL.LANG_ENUM = '%@'", TRABANT_APP_DELEGATE.actualLanguage];
    [DMSetting sharedDMSetting].palivoArray = [[BaseDBManager sharedBaseDBManager] preformOnStaticDBSelect:sql];
}

@end
