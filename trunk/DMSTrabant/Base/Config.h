//
//  Config.h
//  DirectCheckin
//
//  Created by Jan Kubis on 05.11.13.
//
//

#import <Foundation/Foundation.h>

@interface Config : NSObject
+ (NSString*)retrieveFromUserDefaults:(NSString*)key;
+ (void)saveToUserDefaults:(NSString*)key value:(NSString*)valueString;

+(NSInteger)getGenerationVersion;
+(void)setGenerationVersion:(NSInteger)version;
+(void)setMajorDBVersion:(NSInteger)version;
+(NSInteger)getMajorDBVersion;
+(NSInteger)getMinorDBVersion;
+(void)setMinorDBVersion:(NSInteger)version;
+(NSInteger)getCommunicationVersion;
+(void)setCommunicationVersion:(NSInteger)version;
+(NSString *)getUpdateDate;
+(void)setUpdateDate:(NSString *)date;
+(NSString *)getUUID;
+(void)setUUID:(NSString *)uuid;
+(NSString *)getURL;
+(void)setURL:(NSString *)url;
+(void)synchronize;
+(double)getImageResolution;
+(NSInteger)getImageTimeOut;
+(BOOL)useExternalSignificant;
+(NSString *)getSignificantURL;
+(BOOL)getPacketDetail;
@end
