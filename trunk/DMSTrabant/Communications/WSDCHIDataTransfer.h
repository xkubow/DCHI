//
//  loadCarManufactureData.h
//  DirectCheckin
//
//  Created by Jan Kubis on 19.02.13.
//
//

#import "WSBaseService.h"

@interface WSDCHIDataTransfer : WSBaseService

+ (WSDCHIDataTransfer *) sharedWSDCHIDataTransfer;

//- (void) startGetSiluets;
//- (void) startRequestWithVyrobekVoz:(NSString*)vyrobekVoz;
- (void) startRequestGetPlanZakazky;
- (void) startGetCarDataWithVozidloId:(NSInteger)vozidlo_id checkIn_id:(NSInteger)checkIn_id oZakazkaId:(NSInteger)oZakazkaId rzv:(NSString*)rzv vin:(NSString*)vin;
- (void) startloginWithName:(NSString *)name heslo:(NSString*)heslo;
- (void) startPrintReportWithPrinterName:(NSString*)printerName;
- (void) startDCHIReport;
- (void) startDCHIReportImage;
//- (void) startGetSiluetsImages:(NSString*)siluetaId;
- (void) startDCHIAllData;
- (void) startDCHIAllSiluets;
- (void) loadDBData;
- (void) startGetPrinters;
- (void) signProtocol;
- (void) startSendEmail:(NSString *)emailAddress subject:(NSString *)subject message:(NSString *)message;

- (void)saveData;
@end