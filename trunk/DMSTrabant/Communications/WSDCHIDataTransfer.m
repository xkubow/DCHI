    //
//  loadCarManufactureData.m
//  DirectCheckin
//
//  Created by Jan Kubis on 19.02.13.
//
//

#import "WSDCHIDataTransfer.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "TrabantAppDelegate.h"
#import "DejalActivityView.h"
#import "DMSetting.h"
#import "Base64Coding.h"
#import "DMPoints.h"
#import "SBJsonParser.h"
#import "SBJsonWriter.h"
#import "Flurry.h"
#import "TestFlight.h"
#import <objc/runtime.h>
#import "Config.h"
#import "Significat.h"

#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])
#define ROOTNAVIGATOR ([TRABANT_APP_DELEGATE rootNavController])

@interface WSDCHIDataTransfer()
{
    int saveStatus, picturesSaved;
    char loadedDB;
    NSDictionary *mdDBStaticData;
    NSNumber *progresBig;
    bool doSiulets;
    bool dobaners;
    NSString *updateDate;
}

-(void)updateStaticDBWithData:(NSDictionary*)data;
@end

@implementation WSDCHIDataTransfer

+ (WSDCHIDataTransfer *) sharedWSDCHIDataTransfer
{
    static WSDCHIDataTransfer * shared = nil;
    if ( !shared ) {
        shared = [[self alloc] init];
    }
    return shared;
}

- (WSDCHIDataTransfer *)init
{
    self = [super init];
    if(self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataParsed:) name:@"parseFinishNotification" object: nil];
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) startRequestGetPlanZakazky
{
//    [DejalBezelActivityView activityViewForView:TRABANT_APP_DELEGATE.rootNavController.view withLabel:@"" width:50];
    self.showErrorMessag = YES;
    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:@"pchi/CheckinOrderList", @"ACTIONURL", @"GetCheckinOrderList", @"ACTION", nil];

    [self sendGetMessage:d action:@"GetCheckinOrderList"];
    [[self queue] go];
}

- (void) startGetPacketsWithBrandId:(NSString*)brandId vin:(NSString*)vin
{
    self.showErrorMessag = NO;
    [[[WSDCHIDataTransfer sharedWSDCHIDataTransfer] backQueue] cancelAllOperations];
    
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"pchi/WorkshopPackets", @"ACTIONURL", @"GetWPForCheckIn", @"ACTION", nil];
    if(brandId.length)
        [d setValue:brandId forKey:@"brandID"];
    else
        [d setValue:@"" forKey:@"brandID"];
    
    if(vin.length)
        [d setValue:[vin stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"vin"];
    else
        [d setValue:@"" forKey:@"vin"];
    
    [d setValue:([Config getPacketDetail])?@"true":@"false" forKey:@"detail"];
    [self sendGetMessage:d action:@"GetWPForCheckIn" backgroud:YES];
    [[self backQueue] go];
}

- (void) startGetCarDataWithVozidloId:(NSInteger)vozidlo_id checkIn_id:(NSInteger)checkIn_id oZakazkaId:(NSInteger)oZakazkaId rzv:(NSString*)rzv vin:(NSString*)vin
{
    self.showErrorMessag = NO;
    [[[WSDCHIDataTransfer sharedWSDCHIDataTransfer] backQueue] cancelAllOperations];
    
    
    self.showErrorMessag = YES;
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"pchi/DataForCheckIn", @"ACTIONURL", @"GetCustomerVehicleData", @"ACTION", nil];
    if(rzv.length)
        [d setValue:[rzv stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"licenseTag"];
    else
        [d setValue:@"" forKey:@"licenseTag"];
    if(vin.length)
        [d setValue:[vin stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"vin"];
    else
        [d setValue:@"" forKey:@"vin"];
    if(vozidlo_id != -1)
        [d setValue:[NSNumber numberWithInt:vozidlo_id] forKey:@"vehicleid"];
    if(checkIn_id != -1)
        [d setValue:[NSNumber numberWithInt:checkIn_id] forKey:@"checkinid"];
    if(oZakazkaId != -1)
        [d setValue:[NSNumber numberWithInt:oZakazkaId] forKey:@"plannedorderid"];
    
    [self sendGetMessage:d action:@"GetCustomerVehicleData"];
    [[self queue] go];
}

- (void) startloginWithName:(NSString *)name heslo:(NSString*)heslo
{//userdata, d/Login
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"database/userdata", @"ACTIONURL", @"Login", @"ACTION", nil];// name, @"login", heslo, @"password", TRABANT_APP_DELEGATE.myUUID, @"deviceid", [[[UIDevice currentDevice] name] stringByReplacingOccurrencesOfString:@" " withString:@"%20"], @"deviceName", nil];
//    [DejalBezelActivityView activityViewForView:TRABANT_APP_DELEGATE.rootNavController.view withLabel:@"" width:50];
    self.showErrorMessag = YES;
    [self sendGetMessage:d action:@"Login"];
    

    
    [[self queue] go];
}

-(void)loadDBData
{

    loadedDB = 0;
    self.showErrorMessag = YES;
    [DejalBezelActivityView currentActivityView].progressView.progress = 0;
    progresBig = [NSNumber numberWithFloat:1.0/3.0];
    [[BaseDBManager sharedBaseDBManager] loadBaseDB];
    [[DMSetting sharedDMSetting] clearAllData];
    NSDictionary  *d = [NSDictionary dictionaryWithObjectsAndKeys:@"database/StaticData", @"ACTIONURL", @"GetStaticData", @"ACTION", nil];
    [self sendGetMessage:d action:@"GetStaticData"];

    d = [NSDictionary dictionaryWithObjectsAndKeys:@"silhouette/SFiles", @"ACTIONURL", @"GetFiles", @"ACTION", nil];
    [self sendGetMessage:d action:@"GetFiles"];

    d = [NSDictionary dictionaryWithObjectsAndKeys:@"pchi/Banners", @"ACTIONURL", @"GetBanners", @"ACTION", nil];
    [self sendGetMessage:d action:@"GetBanners"];

    [[self queue] go];

}

- (void) startGetPrinters
{
    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:@"pchi/Printers", @"ACTIONURL", @"GetPrinters", @"ACTION", nil];
    [self sendGetMessage:d action:@"GetPrinters"];
    [[self queue] go];
}

- (void) startSaveImages
{
    
    NSNumber *trabantIndex, *imageIndex = @0;
    
    ASINetworkQueue *q = [self queue];
    NSNumber *checkinId = [[DMSetting sharedDMSetting].vozidlo objectForKey:@"CHECKIN_ID"];
    
    NSString *sUrl = [NSString stringWithFormat:@"%@pchi/SavePhotos/?checkinID=%d", TRABANT_APP_DELEGATE.dbPath, checkinId.integerValue];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:sUrl]];
    [request setDownloadProgressDelegate:[DejalBezelActivityView currentActivityView].progressView];
    [request setPostFormat:ASIMultipartFormDataPostFormat];
    [self setHeadersForRequest:request];
    [request setRequestMethod:@"POST"];
    
    request.userInfo = [NSDictionary dictionaryWithObjects:@[@"PostCheckinPhoto"] forKeys:@[@"ACTION"]];
    self.showErrorMessag = YES;
    for(NSDictionary *d in [DMSetting sharedDMSetting].takenImages)
    {
        if(trabantIndex.integerValue != [[d objectForKey:@"TRABANTINDEX"]integerValue]+1)
            imageIndex = [NSNumber numberWithInt:0];
        trabantIndex = [d objectForKey:@"TRABANTINDEX"];
        trabantIndex = [NSNumber numberWithInt:trabantIndex.integerValue+1];
        NSLog(@"%d, %d", trabantIndex.integerValue, imageIndex.integerValue);
        NSString *imgName = [NSString stringWithFormat:@"image%d_%d.png", trabantIndex.integerValue, imageIndex.integerValue];
        
        NSString *filepath = [d valueForKey:@"FILEPATH"];
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:filepath];
        [request addHeaderMultyPartData:[NSDictionary dictionaryWithObjects:@[trabantIndex.stringValue, imageIndex.stringValue] forKeys:@[@"OBR_ENUM", @"OBR_SORT_IDX"]]];
        [request addData:data withFileName:imgName andContentType:@"image/png" forKey:@"IMAGE"];
        imageIndex = [NSNumber numberWithInt:imageIndex.integerValue+1];
    }
    
    [request buildPostBody];
    //    NSLog(@"%lld", [request postLength]);
    [request addRequestHeader: @"Content-Length" value:[NSString stringWithFormat:@"%lld",[request postLength] ]];
    [request setDelegate:self];
    [request setTimeOutSeconds: [Config getImageTimeOut]];
    [q addOperation:request];
    [q go];
    //TODO doriesit teplomer na fotky
    //    [self performSelector:@selector(updateProgressIndicators:) withObject:request afterDelay:0.5];
}

- (void) startSaveByImage
{
    NSNumber *trabantIndex, *imageIndex = @0;
    
    ASINetworkQueue *q = [self queue];
    NSNumber *checkinId = [[DMSetting sharedDMSetting].vozidlo objectForKey:@"CHECKIN_ID"];
    
    NSString *sUrl = [NSString stringWithFormat:@"%@pchi/SavePhotos/?checkinID=%d", TRABANT_APP_DELEGATE.dbPath, checkinId.integerValue];
    [[DejalBezelActivityView currentActivityView].progressView setProgress:0.0];

    
    self.showErrorMessag = YES;
    for(NSDictionary *d in [DMSetting sharedDMSetting].takenImages)
    {
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:sUrl]];
        request.timeOutSeconds = 90;
        [request setPostFormat:ASIMultipartFormDataPostFormat];
        [self setHeadersForRequest:request];
        [request setRequestMethod:@"POST"];
        
        request.userInfo = [NSDictionary dictionaryWithObjects:@[@"PostCheckinPhoto"] forKeys:@[@"ACTION"]];

        

        if(trabantIndex.integerValue != [[d objectForKey:@"TRABANTINDEX"]integerValue]+1)
            imageIndex = [NSNumber numberWithInt:0];
        trabantIndex = [d objectForKey:@"TRABANTINDEX"];
        trabantIndex = [NSNumber numberWithInt:trabantIndex.integerValue+1];
        NSLog(@"%d, %d", trabantIndex.integerValue, imageIndex.integerValue);
        NSString *imgName = [NSString stringWithFormat:@"image%d_%d.png", trabantIndex.integerValue, imageIndex.integerValue];
        
//        UIImage *img = [d valueForKey:@"IMAGE"];
//        NSData *data = [NSData dataWithData:UIImageJPEGRepresentation(img, 0.5)];//[NSData dataWithData: UIImagePNGRepresentation(img)];
        NSString *filepath = [d valueForKey:@"FILEPATH"];
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:filepath];
        NSLog(@"%d", data.length);
        [request addHeaderMultyPartData:[NSDictionary dictionaryWithObjects:@[trabantIndex.stringValue, imageIndex.stringValue] forKeys:@[@"OBR_ENUM", @"OBR_SORT_IDX"]]];
        [request addData:data withFileName:imgName andContentType:@"image/png" forKey:@"IMAGE"];
        imageIndex = [NSNumber numberWithInt:imageIndex.integerValue+1];
        
        [request buildPostBody];
        //    NSLog(@"%lld", [request postLength]);
        [request addRequestHeader: @"Content-Length" value:[NSString stringWithFormat:@"%lld",[request postLength] ]];
        [request setDelegate:self];
        [q addOperation:request];
    }


    [q go];
    //TODO doriesit teplomer na fotky
//    [self performSelector:@selector(updateProgressIndicators:) withObject:request afterDelay:0.5];
}

- (void) updateProgressIndicators:(ASIFormDataRequest*)request
{
    NSLog(@"%lld", [request totalBytesSent]);
    [DejalBezelActivityView currentActivityView].progressView.progress = [request totalBytesSent];
}

- (void) startPrintReportWithPrinterName:(NSString*)printerName
{
    NSError *error;
    NSDictionary *urlData = [NSDictionary dictionaryWithObjectsAndKeys:@"pchi/PrintReport", @"ACTIONURL", @"PrintReport", @"ACTION", nil];
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys: printerName, @"printerName", [[DMSetting sharedDMSetting].vozidlo objectForKey:@"CHECKIN_ID"], @"checkinID", nil];
    NSString *jsonStr = [writer stringWithObject:data error:&error ];
    [self sendPostMessage:jsonStr urlData:urlData action:@"PrintReport"];
    [[self queue] go];
}


- (void) startDCHIReport
{
    self.showErrorMessag = YES;
    NSNumber *n = [[DMSetting sharedDMSetting].vozidlo objectForKey:@"CHECKIN_ID"];
    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:@"pchi/PDFReport", @"ACTIONURL",@"ChiReport", @"ACTION", n, @"checkinid", @"false", @"PREVIEW", nil];
    [self sendGetMessage:d action:@"ChiReport"];
}

- (void) startDCHIReportImage
{
    self.showErrorMessag = YES;
    NSNumber *n = [[DMSetting sharedDMSetting].vozidlo objectForKey:@"CHECKIN_ID"];
    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:@"pchi/PDFReportConvert", @"ACTIONURL",@"PDFReportConvert", @"ACTION", n, @"checkinid", @"Png", @"format", @"false", @"PREVIEW", nil];
    [self sendGetMessage:d action:@"PDFReportConvert"];
}

- (void) startDCHIAllData
{
    self.showErrorMessag = YES;
    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:@"database/StaticData", @"ACTIONURL", @"GetStaticData", @"ACTION", nil];
    [self sendGetMessage:d action:@"GetStaticData"];
    [[self queue] go];
}

- (void) startDCHIAllSiluets
{
    self.showErrorMessag = YES;
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:@"silhouette/SFiles", @"ACTIONURL", @"GetFiles", @"ACTION", nil];
    [self sendGetMessage:data action:@"GetFiles"];
    [[self queue] go];
}

- (void) startGetPhotos
{
    self.showErrorMessag = NO;
    NSNumber *n = [[DMSetting sharedDMSetting].vozidlo objectForKey:@"CHECKIN_ID"];
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:@"pchi/photos", @"ACTIONURL", @"GetPhotos", @"ACTION", n, @"checkinid", nil];
    [self sendGetMessage:data action:@"GetFiles" backgroud:YES];
    [[self backQueue] go];
}

- (void)saveData
{
    NSDictionary *data = [self getSaveData];
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    
    // parse the JSON string into an object - assuming [response asString] is a NSString of JSON data
    NSError *error;
    NSString *jsonStr = [writer stringWithObject:data error:&error ];
    
    if(error)
        NSLog(@"%@", error);
    
    self.showErrorMessag = YES;
    NSMutableDictionary *urlData = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"pchi/SaveCheckin", @"ACTIONURL", @"PostSaveCheckin", @"ACTION", nil];
    
    [self sendPostMessage:jsonStr urlData:urlData action:@"PostSaveCheckin"];
    [[self queue] go];

}

- (void) startSendEmail:(NSString *)emailAddress subject:(NSString *)subject message:(NSString *)message
{
    self.showErrorMessag = YES;
    //chi/GetReport/?deviceID= =&guid= &checkinID=&lang=
    NSNumber *n = [[DMSetting sharedDMSetting].vozidlo objectForKey:@"CHECKIN_ID"];
    NSError *error;
    NSDictionary *urlData = [NSDictionary dictionaryWithObjectsAndKeys:@"pchi/SendEmail", @"ACTIONURL", @"SendEmail", @"ACTION", nil];
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys: n, @"checkinid", emailAddress, @"EmailAddress", subject, @"Subject",message, @"EmailText", nil];
    NSString *jsonStr = [writer stringWithObject:data error:&error ];
    [self sendPostMessage:jsonStr urlData:urlData action:@"SendEmail"];
}

#pragma mark -
#pragma mark SOAP mesages

-(NSDictionary*)getSaveData
{
    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *mDicTmp = [[NSMutableDictionary alloc] init];
    DMSetting *s = [DMSetting sharedDMSetting];

    //**************** VOZIDLO ****************//
    [mDic setValue:[[NSMutableDictionary alloc] initWithDictionary:s.vozidlo copyItems:YES] forKey:@"CHECKIN"];
    NSString *vin = [[s.vozidlo valueForKey:@"VIN"] stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[mDic objectForKey:@"CHECKIN"] setValue:vin forKey:@"VIN"];
    [mDic setValue:[self getTrabantData] forKey:@"CHECKIN_DAMAGE_POINT"];
    
    NSMutableArray *smtmp = [[NSMutableArray alloc] init];
    NSMutableArray *rmArray = [[NSMutableArray alloc] init];
    
    //**************** CELKY ****************//
    NSMutableArray *mtmp = [[NSMutableArray alloc] initWithArray:s.casti copyItems:YES];//[NSMutableArray arrayWithArray:s.casti.copy];
    for(NSArray *a in mtmp)
    {
        for(NSMutableDictionary *d in a)
        {
            mDicTmp = d.mutableCopy;
            if([mDicTmp objectForKey:@"WORKSHOP_PACKET"] != nil)
            {
                NSMutableDictionary *workShopPacked = [mDicTmp objectForKey:@"WORKSHOP_PACKET"];
                [workShopPacked removeObjectsForKeys:@[@"BRAND_ID", @"CHCK_PART_ID", @"CHCK_PART_TXT", @"CHCK_UNIT_ID", @"CHCK_UNIT_TXT"]];
            }
            [mDicTmp removeObjectsForKeys:@[@"BRAND_ID", @"CHCK_PART_TXT", @"CHCK_POSITION_ABBREV_TXT", @"CHCK_POSITION_ID", @"CHCK_POSITION_TXT"]];//5.11 removed, @"REQUIRED_DESCRIPTION"]];
            [smtmp addObject:mDicTmp.copy];
        }
    }
    [mDic setValue:smtmp.copy forKey:@"CHECKIN_UNIT"];
    
    //**************** NABIDKY ****************//
    [mDicTmp removeAllObjects];
    [smtmp removeAllObjects];
    [mtmp removeAllObjects];
    NSMutableArray *nabidkyCopy = [[NSMutableArray alloc] initWithArray:s.nabidky copyItems:YES];//[NSMutableArray arrayWithArray:s.nabidky.copy];
    for(NSMutableDictionary *d in nabidkyCopy)
    {
        NSLog(@"%@", [d valueForKey:@"CHECKIN_OFFER_ID"]);
        mDicTmp = d.mutableCopy;
        [mDicTmp removeObjectsForKeys:@[@"ADVERT_BANNER", @"BRAND_ID", @"INSERTED_UTC", @"LAST_UPDATED_UTC", @"SHOW_TXT", @"VALID_FROM_UTC", @"VALID_UNTIL_UTC", @"TEXT"]];
        [smtmp addObject:mDicTmp];
    }
    NSLog(@"%@", smtmp);
    [mDic setValue:smtmp.copy forKey:@"CHECKIN_OFFER"];
    
    //**************** SLUZBY ****************//
    [smtmp removeAllObjects];
    [mtmp removeAllObjects];
    [rmArray removeAllObjects];
    NSMutableArray *sluzbyCopy = [[NSMutableArray alloc] initWithArray:s.sluzby copyItems:YES];//[NSMutableArray arrayWithArray:s.sluzby.copy];
//    for(NSMutableDictionary *d in mtmp)
    for(NSDictionary *d in sluzbyCopy)
    {
        mDicTmp = d.mutableCopy;
//        id e = [d objectForKey:@"EDITABLE"];
        if(existInDic(mDicTmp, @"EDITABLE"))
        {
//            if([((NSNumber*)e) isEqualToNumber:@1])
//            {
                [mDicTmp removeObjectForKey:@"EDITABLE"];
                if(existInDic(mDicTmp, @"CHECKED"))
                    [smtmp addObject:mDicTmp];
//            }
            [rmArray addObject:d];
        }
        else
        {
            [mDicTmp removeObjectsForKeys:@[@"BRAND_ID", @"CHECK_SERVICE_ENUM", @"CHECK_SERVICE_ID:1", @"CHECK_SERVICE_TXT_DEF", @"CHECK_SERVICE_TXT_LOC", @"INSERTED", @"LANG_ENUM", @"LAST_UPDATED", @"TEXT", @"VALID_FROM", @"VALID_UNTIL"]];
//            [mtmp addObject:mDicTmp];
        }
    }
    [sluzbyCopy removeObjectsInArray:rmArray];
    [mDic setValue:sluzbyCopy.copy forKey:@"CHECKIN_SERVICE"];
    [mDic setValue:smtmp.copy forKey:@"CHECKIN_SERVICE_FREE"];

    [rmArray removeAllObjects];
    
    //**************** VYBAVY ****************//
    NSArray *a = [s.povVybavy arrayByAddingObjectsFromArray:s.vybavy];
    [mtmp removeAllObjects];
    [rmArray removeAllObjects];
    [smtmp removeAllObjects];
    for(NSDictionary *d in a)
    {
        mDicTmp = d.mutableCopy;
        id e = [mDicTmp objectForKey:@"EDITABLE"];
        if(e != nil)
        {
            if([((NSNumber*)e) isEqualToNumber:@1])
            {
                [mDicTmp removeObjectForKey:@"EDITABLE"];
                if(existInDic(mDicTmp, @"CHECKED"))
                    [smtmp addObject:mDicTmp];
            }
            [rmArray addObject:mDicTmp];
        }
        else
        {
            [mDicTmp removeObjectsForKeys:@[@"BRAND_ID", @"CAR_EQUIPMENT_ENUM", @"CAR_EQUIPMENT_ID:1", @"CAR_EQUIPMENT_TXT_DEF", @"CAR_EQUIPMENT_TXT_LOC", @"INSERTED", @"LANG_ENUM", @"LAST_UPDATED", @"SHOW_EQUIPMENT", @"TEXT"]];
            [mtmp addObject:mDicTmp.copy];
        }
    }
    [mtmp removeObjectsInArray:rmArray];
    [mDic setValue:mtmp.copy forKey:@"CHECKIN_EQUIPMENT"];
    [mDic setValue:smtmp.copy forKey:@"CHECKIN_EQUIPMENT_FREE"];
    
    //**************** PAKETY ****************//
    //CHCK_STATUS_ID.intvalue
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"CHCK_STATUS_ID.intvalue = %d", @1];
    NSArray *pakety = [[DMSetting sharedDMSetting].pakety filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"CHCK_STATUS_ID.intValue = 1"]];
    [smtmp removeAllObjects];
    smtmp = [NSMutableArray arrayWithArray:pakety.copy];
    for (NSMutableDictionary *d in smtmp) {
        [d removeObjectForKey:@"DETAIL_LIST"];
    }
    [mDic setValue:smtmp.copy forKey:@"CHECKIN_WORKSHOP_PACKET"];
    
    NSLog(@"############# Data to be saved : #############\n%@", mDic);
    return mDic;
}

-(NSArray*)getTrabantData
{
    NSInteger ix, iy;
//    CGFloat fx, fy;
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    const BOOL recompute = [DMPoints sharedDMPoints].recomputePositions;
    DMPoints *points = [DMPoints sharedDMPoints];
    NSArray *keys = [NSArray arrayWithObjects:@"DAMAGE_ENUM", @"IMAGE_ENUM", @"COORD_X", @"COORD_Y", @"ORDER", @"DESCRIPTION", nil];
    
    for(NSInteger i=1; i<6; i++){
        NSArray *p = [points getPointsByIndex:(i-1)];
        for(mPoint *obj in p){
            if(recompute)
            {
                ix = obj.pozicia.x;
                iy = obj.pozicia.y;
            }
            else
            {
                CGFloat npX = obj.pointButton.center.x;
                CGFloat npY = obj.pointButton.center.y;
                CGFloat nsX = points.imgRect.origin.x;
                CGFloat nsY = points.imgRect.origin.y;
                CGFloat nWidth = points.imgCorpSize.width;
                CGFloat nHeigth = points.imgCorpSize.height;
                ix = (npX - nsX) * nWidth * points.pomerWidth;
                iy = (npY - nsY) * nHeigth * points.pomerHeigth;
            }

            [mArray addObject:[NSDictionary dictionaryWithObjects:@[ [NSNumber numberWithInt:[[obj pointButton] tag]], [NSNumber numberWithInt:i], [NSNumber numberWithInt:ix], [NSNumber numberWithInt:iy], [NSNumber numberWithInt:[obj index]+1], [obj popis]] forKeys:keys]];
        }
    }
    
    return mArray;
}

- (void)requestDidFinish:(ASIHTTPRequest *)request
{
    NSString *action = [request.userInfo objectForKey:@"ACTION"];
    
    NSLog(@"\n\nAction did finish: %@", action);
    NSLog(@"\n%d, %@", request.responseStatusCode, request.responseStatusMessage);// request.responseString);
    

    if(request.responseStatusCode == 412)
    {
        NSLog(@"%@", [request responseHeaders]);
        NSString *debug = [NSString stringWithFormat:@"Updating DB data - (response code 412):%@, %@", [Config getUpdateDate],request.responseString];
        [TestFlight passCheckpoint:debug];

        [[DejalBezelActivityView currentActivityView] setLabelWidth:180];
        [[DejalBezelActivityView currentActivityView] setLabelText:NSLocalizedString(@"updating static data", nil)];
        [[DejalBezelActivityView currentActivityView] addProgressView];
        [[DejalBezelActivityView currentActivityView].progressView setProgress:0.0];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *data = [parser objectWithString:request.responseString error:nil];
        
        [self updateStaticDBWithData:data];
        [Config setUpdateDate:[[request responseHeaders]  valueForKey:@"Last-Modified" ]];
        
        if(![action isEqualToString:@"PostSaveCheckin"])
        {
            id date = [Config getUpdateDate];
            ASIHTTPRequest *newRequest = [request copy];
            
            if(date != nil)
            {
                NSLog(@"%@", (NSString *)date);
                [newRequest addRequestHeader:@"if-Unmodified-Since" value:(NSString *)date];
            }
            NSLog(@"%@", [[newRequest requestHeaders] valueForKey:@"if-Unmodified-Since"]);
            
            [[self queue] addOperation:newRequest];
            [[self queue] go];
            return;
        }
        
        [DejalBezelActivityView removeView];
        return;
    } else if(request.responseStatusCode/100 != 2)
    {
        NSLog(@"%d, %@, %@", request.responseStatusCode, request.responseStatusMessage, request.responseString);
        [DejalBezelActivityView removeViewAnimated:YES];
        if(self.showErrorMessag)
        {
            NSString *msg, *msgTitle = NSLocalizedString(@"Chyba komunikace", @"chyba msg");
        
            if(request.responseString.length)
            {
                NSError *error;
                SBJsonParser *parser = [[SBJsonParser alloc] init];
                NSDictionary *object = [parser objectWithString:request.responseString error:&error];
                
                if(error)
                {
                    msgTitle = @"";
                    msg = [NSString stringWithFormat:@"%@", request.responseString];
                } else
                {
                    NSDictionary *d = [object objectForKey:@"RESULT"];
                    if(existInDic(d, @"SAVE_STATUS_MESSAGE"))
                        msg = [d valueForKey:@"SAVE_STATUS_MESSAGE"];
                    else if(existInDic(d, @"ERROR_MESSAGE"))
                        msg = [d valueForKey:@"ERROR_MESSAGE"];
                }
                
            }
            else
                msg = [NSString stringWithFormat:@"%@: %@, %@",NSLocalizedString(@"Chyba komunikace", @"chyba msg"), request.responseStatusMessage, request.responseString];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:msgTitle
                                                            message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            self.showErrorMessag = NO;
        }
        return;
    }

    NSLog(@"\n\n%@", request.responseString);
    
    if([action isEqualToString:@"PostSaveCheckin"])
    {
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *object = [parser objectWithString:request.responseString error:nil];
        NSLog(@"############# PostSaveCheckin : #############\n%@", object);
        NSDictionary *d = [object objectForKey:@"RESULT"];
        
        if(existInDic(d, @"SAVE_STATUS") && [[d valueForKey:@"SAVE_STATUS"] integerValue] != 1)
        {
            [[[UIAlertView alloc] initWithTitle:@"" message:[d valueForKey:@"SAVE_STATUS_MESSAGE"]
                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",@"chyba hlaska") otherButtonTitles:nil] show];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"dataSavedNotification" object:@"ErrorSaveCheckin"];
            return;
        }
        
        if(existInDic(d, @"SAVE_DMS_STATUS") && [[d valueForKey:@"SAVE_DMS_STATUS"] integerValue] != 1) {
            [[DMSetting sharedDMSetting].vozidlo setValue:[d valueForKey:@"CHECKIN_NUMBER"] forKey:@"CHECKIN_NUMBER"];
            [[[UIAlertView alloc] initWithTitle:@"" message:[d valueForKey:@"SAVE_DMS_STATUS_MESSAGE"]//NSLocalizedString(@"Neprebehlo ulozenie do DMS", nil)
                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",@"chyba hlaska") otherButtonTitles:nil] show];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"dataSavedNotification" object:@"ErrorSaveCheckin"];
            return;
        }
        
        [[DMSetting sharedDMSetting].vozidlo setValue:[d valueForKey:@"CHECKIN_ID"] forKey:@"CHECKIN_ID"];
        [[DMSetting sharedDMSetting].vozidlo setValue:[d valueForKey:@"CHECKIN_NUMBER"] forKey:@"CHECKIN_NUMBER"];
        if([DMSetting sharedDMSetting].takenImages.count)
            [self startSaveImages];
        else if([DMSetting sharedDMSetting].showProtocol)
            [self startDCHIReport];
        else
            [[NSNotificationCenter defaultCenter] postNotificationName:@"dataSavedNotification" object:@"PostSaveCheckin"];
        return;
    }
    else if([action isEqualToString:@"PostCheckinPhoto"])
    {
//        if([self queue].requestsCount > 0) {
//            float step = 1.0 / [DMSetting sharedDMSetting].takenImages.count;
//            step += [DejalBezelActivityView currentActivityView].progressView.progress;
//            [[DejalBezelActivityView currentActivityView].progressView setProgress:step];
//            return;
//        }
        [request setUploadProgressDelegate:nil];
        if([DMSetting sharedDMSetting].showProtocol)
            [self startDCHIReport];
        else
            [[NSNotificationCenter defaultCenter] postNotificationName:@"dataSavedNotification" object:@"PostSaveCheckin"];
        return;
    }
    else if([action isEqualToString:@"GetCheckinOrderList"])
    {

        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *object = [parser objectWithString:request.responseString error:nil];
        [DMSetting sharedDMSetting].planovaneZakazky = [object objectForKey:@"CHECKIN_ORDER_LIST"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"dataRespondNotification" object:@"GetCheckinOrderList"];
        });
        return;
    }
    else if([action isEqualToString:@"GetFiles"])
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachDir = [paths objectAtIndex:0];
        NSString *writablePath = [cachDir stringByAppendingPathComponent:@"siluetsData"];
        [request.responseData writeToFile:writablePath atomically:YES];
        
        [DejalBezelActivityView currentActivityView].progressView.progress += progresBig.floatValue;
        
        if(doSiulets)
        {
            [[DMSetting sharedDMSetting].siluets performSelectorInBackground:@selector(parseSiluets) withObject:mdDBStaticData ] ;
            return;
        }
        loadedDB |= 4;
        
        if(loadedDB == 7)
            [self performSelectorInBackground:@selector(setDBData:) withObject:mdDBStaticData];
        return;
    }
    else if([action isEqualToString:@"GetBanners"])
    {
        if(dobaners && !request.responseData.length)
            return;
        
        if(!request.responseData.length)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginDataRespondNotification" object:@"GetDefaulData"];
            return;
        }
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachDir = [paths objectAtIndex:0];
        NSString *writablePath = [cachDir stringByAppendingPathComponent:@"banersData"];
        [request.responseData writeToFile:writablePath atomically:YES];

        [DejalBezelActivityView currentActivityView].progressView.progress += progresBig.floatValue;
        
        if(dobaners)
        {
            [[DMSetting sharedDMSetting].baners performSelectorInBackground:@selector(parseBaners) withObject:mdDBStaticData];
            return;
        }
        
        loadedDB |= 2;
        
        if(loadedDB == 7)
            [self performSelectorInBackground:@selector(setDBData:) withObject:mdDBStaticData];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginDataRespondNotification" object:@"GetDefaulData"];
        return;
    }
    else if([action isEqualToString:@"GetCustomerVehicleData"])
    {
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *object = [parser objectWithString:request.responseString error:nil];
        NSLog(@"############# GetCustomerVehicleData : #############\n%@", object);
        [[DMSetting sharedDMSetting] removeAllData];
        if(existInDic(object, @"CUSTOMER_VEHICLES"))
        {
            [DMSetting sharedDMSetting].vozidla = [object objectForKey:@"CUSTOMER_VEHICLES"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"dataRespondNotification" object:@"ShowVozidla"];
            return;
        }
        [DMSetting sharedDMSetting].vozidlo = [object objectForKey:@"CHECKIN"];
        [DMSetting sharedDMSetting].zakaznikInfo = [object objectForKey:@"BUSINESS_PARTNER_INFO"];
        [DMSetting sharedDMSetting].vozInfo = [object objectForKey:@"CUSTOMER_VEHICLE_INFO"];
        [DMSetting sharedDMSetting].vozHistory = [object objectForKey:@"VEHICLE_HISTORY"];
        [DMSetting sharedDMSetting].SDA = [object objectForKey:@"RECALLS"];
        [DMSetting sharedDMSetting].PZ = [object objectForKey:@"PLANNED_ORDER"];
        [DMSetting sharedDMSetting].odlozPoloz = [object objectForKey:@"DEFERRED_SERVICE_DEMANDS"];
        
        NSString *brandId = [[DMSetting sharedDMSetting].vozidlo valueForKey:@"BRAND_ID"];
        NSString *vin = [[DMSetting sharedDMSetting].vozidlo valueForKey:@"VIN"];
        
        if(existInDic([DMSetting sharedDMSetting].vozidlo, @"CHECKIN_ID") && [[[DMSetting sharedDMSetting].vozidlo valueForKey:@"CHECKIN_ID"] integerValue] > 0)
        {
            [DMSetting sharedDMSetting].isLoadingCheckinData = YES;
            [[DMSetting sharedDMSetting] parseCheckinData:object];
            [[DMSetting sharedDMSetting] parseLoadedScenare:object];
            [[DMPoints sharedDMPoints] loadPoints:[object objectForKey:@"DAMAGE_POINTS"]];
            [[DMSetting sharedDMSetting].baners setBannersFromCheckin:[object objectForKey:@"OFFER"]];
//            [self startGetPhotos];
        }
        else
            [DMSetting sharedDMSetting].isLoadingCheckinData = NO;
        
        if([[[DMSetting sharedDMSetting].setting valueForKey:@"WORKSHOP_PACKETS_ALLOWED"] boolValue]
           && existInDic([DMSetting sharedDMSetting].vozidlo, @"VIN") && existInDic([DMSetting sharedDMSetting].vozidlo, @"BRAND_ID"))
            [self startGetPacketsWithBrandId:brandId vin:vin];
        else
            [DMSetting sharedDMSetting].pakety = nil;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dataRespondNotification" object:@"GetCarData"];
        return;
    }
    else if ([action isEqualToString:@"GetWPForCheckIn"])
    {
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *object = [parser objectWithString:request.responseString error:nil];
        NSLog(@"############# GetWPForCheckIn : #############\n%@", object);
        if(existInDic(object, @"CUSTOMER_VEHICLES"))
        {
            NSLog(@"%d, %@", request.responseStatusCode, request.responseStatusMessage);
            return;
        }
        if(existInDic(object , @"WORKSHOP_PACKET_DMS"))
            [DMSetting sharedDMSetting].pakety = [object objectForKey:@"WORKSHOP_PACKET_DMS"];

        else
            [DMSetting sharedDMSetting].pakety = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"dataRespondNotification" object:@"GetWPForCheckIn"];
        });
        return;
    }
    else if([action isEqualToString:@"GetStaticData"])
    {
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        updateDate = [[request responseHeaders]  valueForKey:@"Last-Modified" ];
        if(updateDate.length == 0)
            updateDate = @"01 Sep 2000 12:12:12 GMT";
        
        mdDBStaticData = [parser objectWithString:request.responseString error:nil];
        [DejalBezelActivityView currentActivityView].progressView.progress += progresBig.floatValue;
        loadedDB |= 1;
        
        if(loadedDB == 7) //prve 3 bity
        {
            [self performSelectorInBackground:@selector(setDBData:) withObject:mdDBStaticData];
        }

        return;
    }
    else if([action isEqualToString:@"Login"])
    {
        if(!request.responseString.length)
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginDataRespondNotification" object:@"Login"];            
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *object = [parser objectWithString:request.responseString error:nil];
        [DMSetting sharedDMSetting].loggedUser = [object objectForKey:@"USER"] ;
        NSLog(@"%@", object);
        [DMSetting sharedDMSetting].setting = [object objectForKey:@"CONFIGURATION"];
        NSLog(@"%@", object);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginDataRespondNotification" object:@"Login"];
        return;
    }
    else if ([action isEqualToString:@"ChiReport"]) {
        NSLog(@"new pdf protocol :%d", request.responseData.length);
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *fileName = [NSString stringWithFormat:@"protocol.pdf"];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
        
        // Convert UIImage object into NSData (a wrapper for a stream of bytes) formatted according to PNG spec
        [request.responseData writeToFile:filePath atomically:YES];
        [DMSetting sharedDMSetting].pdfReportFilePath = filePath;
        [self startDCHIReportImage];
        return;
    }
    else if([action isEqualToString:@"PDFReportConvert"]) {
        //        [DMSetting sharedDMSetting].pdfReport = request.responseData;
        NSLog(@"new pdf protocol image:%d", request.responseData.length);
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *fileName = [NSString stringWithFormat:@"protocolImage.png"];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
        
        // Convert UIImage object into NSData (a wrapper for a stream of bytes) formatted according to PNG spec
        [request.responseData writeToFile:filePath atomically:YES];
        [DMSetting sharedDMSetting].pdfReportImageFilePath = filePath;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dataRespondNotification" object:@"ChiReport"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dataSavedNotification" object:@"PostSaveCheckin"];
        return;
    }
    else if([action isEqualToString:@"GetFile"])
    {
        if(!request.responseData.length)
        {
            [self.queue cancelAllOperations];
            [DejalBezelActivityView removeViewAnimated:YES];
            return;
        }
        UIImage *img = [UIImage imageWithData:request.responseData];
        if(img == nil)
        {
            NSLog(@"%@", request.responseString);
            [self.queue cancelAllOperations];
            [DejalBezelActivityView removeViewAnimated:YES];
            return;
        }
        NSMutableArray *ma = [DMSetting sharedDMSetting].loadetSiluets.mutableCopy;
        NSInteger i = [[request.userInfo valueForKey:@"siluetatyp_id"] integerValue];
        ma[i-1] = img;
        [DMSetting sharedDMSetting].loadetSiluets = ma;
        [DejalBezelActivityView removeViewAnimated:YES];
        return;
    }
    else if ([action isEqualToString:@"GetPrinters"])
    {
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error;
        NSDictionary *data = [jsonParser objectWithString:request.responseString error:&error];
        if(error)
        {
            [DejalBezelActivityView removeViewAnimated:YES];
            return;
        }
        
        [DMSetting sharedDMSetting].defaultPrinterIdx =
        [[data objectForKey:@"PRINTERS"] indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [obj isEqualToString:[data valueForKey:@"DEFAULT_PRINTER"]];
        }];
        
        [DMSetting sharedDMSetting].printers = [data objectForKey:@"PRINTERS"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Printers" object:@"serverPrinters"];
    } else if([action isEqualToString:@"GetPhotos"])
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachDir = [paths objectAtIndex:0];
        NSString *writablePath = [cachDir stringByAppendingPathComponent:@"checkinPhotos"];
        [request.responseData writeToFile:writablePath atomically:YES];
        
//        [DejalBezelActivityView currentActivityView].progressView.progress += progresBig.floatValue;
//        loadedDB |= 4;
//        
//        if(loadedDB == 7)
//            [self performSelectorInBackground:@selector(setDBData:) withObject:mdDBStaticData];
        return;
    } else if([action isEqualToString:@"GetWorkstepId"]) {
        NSLog(@"Xyzmo : %@",request.responseString);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error;
        NSDictionary *data = [jsonParser objectWithString:request.responseString error:&error];
        NSString *workstepId = [data valueForKey:@"WorkstepId"];
        [DMSetting sharedDMSetting].workStepId = workstepId;
        
        //http.xyzmo.designplus.cz
        //http.10.219.61.104:57003
        [Config synchronize];
        NSString *XizmoUrlStr = [NSString stringWithFormat:@"significant://%@/WorkstepController.Process.asmx?workstepId=%@", [Config retrieveFromUserDefaults:@"SignificantServerUrl"], workstepId];
        NSLog(@"Xyzmo : %@", XizmoUrlStr);
        
        if([Config useExternalSignificant]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:XizmoUrlStr]];
            [DejalBezelActivityView removeViewAnimated:YES];
        }
        else
            dispatch_async(dispatch_get_main_queue(), ^{
                Significat *sig = [[Significat alloc] init];
                [sig openSignificantViewer];
//                [ROOTNAVIGATOR presentViewController:vcSign animated:YES completion:nil];
            });
    }

}

-(void)updateStaticDBWithData:(NSDictionary*)data
{
    BaseDBManager* baseDB = [[BaseDBManager alloc] init];
    doSiulets = NO;
    dobaners = NO;
    
    NSInteger count = 0;
    for(NSString *key in data.allKeys)
    {
        if([key isEqualToString:@"SILHOUETTE_IMAGE"])
            doSiulets = YES;
        if([key isEqualToString:@"CHECK_OFFER"]) {
            NSLog(@"     CHECK_OFFER DATA\n\n%@\n", [data valueForKey:@"CHECK_OFFER"]);
            dobaners = YES;
        }
        if([key isEqualToString:@"OBD_DTC"] || [key isEqualToString:@"OBD_DTC_LOC"])
            continue;
        id d = [data objectForKey:key];
        if([d isKindOfClass:[NSArray class]])
            count += [d count];
        else
            count +=1;
    }
    
    baseDB.progressStep = [NSNumber numberWithDouble:1.0/count];
    
    for(NSString *key in data.allKeys)
        [baseDB insertRecordsForTable:key data:[data objectForKey:key]];
    
    if(!doSiulets && !dobaners)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dataRespondNotification" object:@"StaticDataUpdate"];
    

    NSDictionary *d;
    if(doSiulets)
    {
        d = [NSDictionary dictionaryWithObjectsAndKeys:@"silhouette/SFiles", @"ACTIONURL", @"GetFiles", @"ACTION", nil];
        [self sendGetMessage:d action:@"GetFiles"];
    }
    if(dobaners)
    {
        d = [NSDictionary dictionaryWithObjectsAndKeys:@"pchi/Banners", @"ACTIONURL", @"GetBanners", @"ACTION", nil];
        [self sendGetMessage:d action:@"GetBanners"];
    }
}

-(void)processImages
{
    
}

-(void)clearProgressBar {
    [DejalBezelActivityView currentActivityView].activityLabel.text = NSLocalizedString(@"PARSING DATA", nil);
    [[DejalBezelActivityView currentActivityView].progressView setProgress:0.0];
}

- (void) setDBData:(NSDictionary*)object
{
    BaseDBManager* baseDB = [[BaseDBManager alloc] init];
    NSInteger count = 0;
    for(NSString *key in object.allKeys)
    {
        if([key isEqualToString:@"OBD_DTC"] || [key isEqualToString:@"OBD_DTC_LOC"])
            continue;
        id d = [object objectForKey:key];
        if([d isKindOfClass:[NSArray class]])
            count += [d count];
        else
            count +=1;
    }
    count += [[object objectForKey:@"SILHOUETTE"] count];
    count += [[object objectForKey:@"CHECK_OFFER"] count];
    
    baseDB.progressStep = [NSNumber numberWithDouble:1.0/count];
    [NSThread sleepForTimeInterval: 0.01];
    [self performSelectorOnMainThread: @selector(clearProgressBar) withObject: nil waitUntilDone: NO];

    [baseDB insertRecordsForTable:@"BRAND" data:[object objectForKey:@"BRAND"]];
    [baseDB insertRecordsForTable:@"BRAND_LOC" data:[object objectForKey:@"BRAND_LOC"]];
    [baseDB insertRecordsForTable:@"BRAND_CARBODYCODE" data:[object objectForKey:@"BRAND_CARBODYCODE"]];
    [baseDB insertRecordsForTable:@"BRAND_CARBODYTYPE" data:[object objectForKey:@"BRAND_CARBODYTYPE"]];
    [baseDB insertRecordsForTable:@"BRAND_SILHOUETTE" data:[object objectForKey:@"BRAND_SILHOUETTE"]];
    [baseDB insertRecordsForTable:@"CAR_EQUIPMENT" data:[object objectForKey:@"CAR_EQUIPMENT"]];
    [baseDB insertRecordsForTable:@"CAR_EQUIPMENT_LOC" data:[object objectForKey:@"CAR_EQUIPMENT_LOC"]];
    [baseDB insertRecordsForTable:@"CARBODYTYPE" data:[object objectForKey:@"CARBODYTYPE"]];
    [baseDB insertRecordsForTable:@"SYS_CONFIG" data:[object objectForKey:@"SYS_CONFIG"]];
    [baseDB insertRecordsForTable:@"CHCK_PART" data:[object objectForKey:@"CHCK_PART"]];
    [baseDB insertRecordsForTable:@"CHCK_PART_LOC" data:[object objectForKey:@"CHCK_PART_LOC"]];
    [baseDB insertRecordsForTable:@"CHCK_PART_POSITION" data:[object objectForKey:@"CHCK_PART_POSITION"]];
    [baseDB insertRecordsForTable:@"CHCK_PART_POSITION_STATUS" data:[object objectForKey:@"CHCK_PART_POSITION_STATUS"]];
    [baseDB insertRecordsForTable:@"CHCK_POSITION" data:[object objectForKey:@"CHCK_POSITION"]];
    [baseDB insertRecordsForTable:@"CHCK_POSITION_LOC" data:[object objectForKey:@"CHCK_POSITION_LOC"]];
    [baseDB insertRecordsForTable:@"CHCK_REQUIRED" data:[object objectForKey:@"CHCK_REQUIRED"]];
    [baseDB insertRecordsForTable:@"CHCK_REQUIRED_LOC" data:[object objectForKey:@"CHCK_REQUIRED_LOC"]];
    [baseDB insertRecordsForTable:@"CHCK_STATUS" data:[object objectForKey:@"CHCK_STATUS"]];
    [baseDB insertRecordsForTable:@"CHCK_STATUS_LOC" data:[object objectForKey:@"CHCK_STATUS_LOC"]];
    [baseDB insertRecordsForTable:@"CHCK_UNIT" data:[object objectForKey:@"CHCK_UNIT"]];
    [baseDB insertRecordsForTable:@"CHCK_UNIT_LOC" data:[object objectForKey:@"CHCK_UNIT_LOC"]];
    [baseDB insertRecordsForTable:@"CHECK_OFFER" data:[object objectForKey:@"CHECK_OFFER"]];
    [baseDB insertRecordsForTable:@"CHECK_OFFER_LOC" data:[object objectForKey:@"CHECK_OFFER_LOC"]];
    [baseDB insertRecordsForTable:@"CHECK_SCENARIO" data:[object objectForKey:@"CHECK_SCENARIO"]];
    [baseDB insertRecordsForTable:@"CHECK_SCENARIO_LOC" data:[object objectForKey:@"CHECK_SCENARIO_LOC"]];
    [baseDB insertRecordsForTable:@"CHECK_SCENARIO_UNIT" data:[object objectForKey:@"CHECK_SCENARIO_UNIT"]];
    [baseDB insertRecordsForTable:@"CHECK_SERVICE" data:[object objectForKey:@"CHECK_SERVICE"]];
    [baseDB insertRecordsForTable:@"CHECK_SERVICE_LOC" data:[object objectForKey:@"CHECK_SERVICE_LOC"]];
    [baseDB insertRecordsForTable:@"SILHOUETTE" data:[object objectForKey:@"SILHOUETTE"]];
    [baseDB insertRecordsForTable:@"SILHOUETTE_IMAGE" data:[object objectForKey:@"SILHOUETTE_IMAGE"]];
    [baseDB insertRecordsForTable:@"SILHOUETTE_TYPE" data:[object objectForKey:@"SILHOUETTE_TYPE"]];
    [baseDB insertRecordsForTable:@"TYPE_CODE" data:[object objectForKey:@"TYPE_CODE"]];
    [baseDB insertRecordsForTable:@"FUEL" data:[object objectForKey:@"FUEL"]];
    [baseDB insertRecordsForTable:@"FUEL_LOC" data:[object objectForKey:@"FUEL_LOC"]];
//    [baseDB insertRecordsForTable:@"SYS_CONFIG" data:[object objectForKey:@"SYS_CONFIG"]];
    [Config saveToUserDefaults:@"OBD_DTC_LOAD" value:@"0"];
//    [baseDB insertRecordsForTable:@"OBD_DTC" data:[object objectForKey:@"OBD_DTC"]];
//    [baseDB insertRecordsForTable:@"OBD_DTC_LOC" data:[object objectForKey:@"OBD_DTC_LOC"]];
    NSLog(@"%zd", [baseDB getDBVersion]);
    [Config setMinorDBVersion:[baseDB getDBVersion]];
    NSLog(@"%zd", [Config getMinorDBVersion]);
    
    if([Config getMinorDBVersion] < 0)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"parsovanie do DB sa nezdarilo", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        [DejalBezelActivityView removeViewAnimated:YES];
        return;
    }
    
    [[DMSetting sharedDMSetting].siluets parseSiluets];
    NSLog(@"done siluets");
    
    [[DMSetting sharedDMSetting].baners parseBaners];
    NSLog(@"done banners");
    [self performSelectorInBackground:@selector(parseChybKody:) withObject:mdDBStaticData];
    [Config setUpdateDate:updateDate];
//    [standardUserDefaults setObject:updateDate forKey:@"staticDBDataUpdateDate"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginDataRespondNotification" object:@"GetDefaulData"];
}

- (void) parseChybKody:(NSDictionary*)object
{
 
    BaseDBManager* baseDB = [[BaseDBManager alloc] init];
    
    [baseDB insertRecordsForTable:@"OBD_DTC" data:[object objectForKey:@"OBD_DTC"]];
    NSLog(@"done DTC");
    [baseDB insertRecordsForTable:@"OBD_DTC_LOC" data:[object objectForKey:@"OBD_DTC_LOC"]];
    NSLog(@"done DTC_LOC");
    
    [Config saveToUserDefaults:@"OBD_DTC_LOAD" value:@"1"];
}

- (void)dataParsed:(NSNotification *)notification
{
    if([notification.object isEqualToString:@"SiluetsParsed"])
        doSiulets = NO;
    else if([notification.object isEqualToString:@"BannersParsed"])
        dobaners = NO;
    
    if(!doSiulets && !dobaners){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"dataRespondNotification" object:@"StaticDataUpdate"];
        });
    }
}

-(void) signProtocol
{
    self.showErrorMessag = NO;
    NSNumber *n = [[DMSetting sharedDMSetting].vozidlo objectForKey:@"CHECKIN_ID"];
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:@"Signing/getWorkstepId", @"ACTIONURL", @"GetWorkstepId", @"ACTION", n, @"checkinid", nil];
    [self sendGetMessage:data action:@"GetFiles" backgroud:YES];
    [[self backQueue] go];
}



@end
