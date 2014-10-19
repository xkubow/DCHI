//
//  DMSetting.h
//  Mobile checkin
//
//  Created by Jan Kubis on 29.02.12.
//  Copyright (c) 2012 jan.kubis@t-systems.cz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDBManager.h"
#import "Banners.h"
#import "DBSiluets.h"
#import "DMPoints.h"
#import "Rezident.h"

#define existInDic(dic, enum)([dic objectForKey:enum] != nil && [dic objectForKey:enum] != [NSNull null])

@interface DMSetting : NSObject

@property (retain, nonatomic)NSMutableArray *vybavy;
@property (retain, nonatomic)NSArray *povVybavy;
@property (retain, nonatomic)NSArray *nabidky;
@property (retain, nonatomic)NSArray *vyrobekVoz;
@property (retain, nonatomic)NSMutableArray *sluzby;
@property (retain, nonatomic)NSArray *scenar;
@property (retain, nonatomic)NSArray *pozadavky;
@property (retain, nonatomic)NSArray *vozInfo;
@property (retain, nonatomic)NSArray *zakaznikInfo;
@property (retain, nonatomic)NSArray *vozHistory;
@property (retain, nonatomic)NSArray *SDA;
@property (retain, nonatomic)NSDictionary *PZ;
@property (retain, nonatomic)NSArray *odlozPoloz;
@property (retain, nonatomic)NSArray *celky;
@property (retain, nonatomic)NSArray *casti;
@property (retain, nonatomic)NSArray *pakety;
@property (retain, nonatomic)NSMutableDictionary *vozidlo;
@property (retain, nonatomic)NSArray *vozidla;
@property (retain, nonatomic)NSDictionary *zakaznik;
@property (retain, nonatomic)NSArray *printers;
@property (retain, nonatomic)NSArray *palivoArray;
@property (retain, nonatomic)NSMutableArray *loadetSiluets;
@property (retain, nonatomic)NSArray *planovaneZakazky;
@property (retain, nonatomic)NSDictionary *setting;
@property (retain, nonatomic)NSDictionary *loggedUser;
@property (retain, nonatomic)NSMutableArray *takenImages;
@property (retain, nonatomic)NSString *pdfReportFilePath;
@property (retain, nonatomic)NSString *pdfReportImageFilePath;
@property (retain, nonatomic)DBBanners *baners;
@property (retain, nonatomic)DBSiluets *siluets;
@property (retain, nonatomic)DMPoints *points;
@property (nonatomic, readwrite)BOOL showProtocol;
@property (nonatomic, readwrite)BOOL isLoadingCheckinData;
@property (nonatomic, readwrite)NSInteger defaultPrinterIdx;
@property (retain, nonatomic)NSString *workStepId;

//@property (nonatomic, readwrite) NSInteger scenarId;

+ (DMSetting *) sharedDMSetting;
- (NSDictionary *) getArrayByRonwNum:(NSInteger)rowNum;
- (void)setAllValuesTo:(BOOL)val;
- (void)clearAllData;
- (void)removeSluzbyData;
- (void)removeAllData;
- (void) removeProtokolFiles;
- (UIImage *) getPozadIcon:(NSInteger)enumPozad;
- (NSDictionary*) getActualScenarData;
- (void) parseCheckinData:(NSDictionary*)data;
- (void) parseLoadedScenare:(NSDictionary*)data;

- (void) reloadSiluets;
- (void)reloadScenare;
-(void)loadVyrVoz;
-(void)loadPalivo;

@end
