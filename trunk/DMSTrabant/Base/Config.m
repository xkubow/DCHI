//
//  Config.m
//  DirectCheckin
//
//  Created by Jan Kubis on 05.11.13.
//
//

#import "Config.h"

@implementation Config

+(NSInteger)getGenerationVersion {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:@"GENERATIN_VERSION"];
}

+(void)setGenerationVersion:(NSInteger)version {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:version forKey:@"GENERATIN_VERSION"];
    [defaults setValue:[NSString stringWithFormat:@"%d",version] forKey:@"GENERATIN_VERSION_STR"];
}

+(NSInteger)getMajorDBVersion {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:@"DB_MAJOR_VERSION"];
}

+(void)setMajorDBVersion:(NSInteger)version {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:version forKey:@"DB_MAJOR_VERSION"];
    [defaults setValue:[NSString stringWithFormat:@"%d",version] forKey:@"DB_MAJOR_VERSION_STR"];
}

+(NSInteger)getMinorDBVersion {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:@"DB_MINOR_VERSION"];
}

+(void)setMinorDBVersion:(NSInteger)version {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:version forKey:@"DB_MINOR_VERSION"];
    [defaults setValue:[NSString stringWithFormat:@"%d",version] forKey:@"DB_MINOR_VERSION_STR"];
}

+(NSInteger)getCommunicationVersion {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:@"CommunicationVersion"];
}

+(void)setCommunicationVersion:(NSInteger)version {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:version forKey:@"CommunicationVersion"];
    [defaults setValue:[NSString stringWithFormat:@"%d",version] forKey:@"CommunicationVersion_str"];
}

+(NSString *)getUpdateDate {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:@"DB_UPDATE_DATE"];
}

+(void)setUpdateDate:(NSString *)date {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(date == nil)
        [defaults removeObjectForKey:@"DB_UPDATE_DATE"];
    else
        [defaults setValue:date forKey:@"DB_UPDATE_DATE"];
    [defaults setValue:[NSString stringWithFormat:@"Last BD update date:%@", date] forKey:@"DB_UPDATE_DATE_STR"];
}

+(double)getImageResolution {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults doubleForKey:@"imageResolution"];
}

+(NSInteger)getImageTimeOut {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:@"ImgTimeOut"];
}

+(NSString *)getUUID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:@"myUUID"];
}

+(void)setUUID:(NSString *)uuid {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:uuid forKey:@"myUUID"];
}

+(NSString *)getURL {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"%@", [defaults stringForKey:@"url_web_service"]);
    return [defaults stringForKey:@"url_web_service"];
}

+(void)setURL:(NSString *)url {
    NSLog(@"%@", url);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:url forKey:@"url_web_service"];
}

+(void)synchronize {
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)getPacketDetail {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"%d", [defaults boolForKey:@"detailPaket"]);
    return [defaults boolForKey:@"detailPaket"];
}

+(BOOL)useExternalSignificant {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"%d", [defaults boolForKey:@"useExternalSignificantApp"]);
    return [defaults boolForKey:@"useExternalSignificantApp"];
}

+(NSString *)getSignificantURL {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"%@", [defaults mutableSetValueForKey:@"SignificantServerUrl"]);//objectForKey:@"SignificantServerUrl"]);
    return [defaults stringForKey:@"SignificantServerUrl"];
}

+ (void)saveToUserDefaults:(NSString*)key value:(NSString*)valueString
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        [standardUserDefaults setObject:valueString forKey:key];
        [standardUserDefaults synchronize];
    } else {
        NSLog(@"Unable to save %@ = %@ to user defaults", key, valueString);
    }
}

+ (NSString*)retrieveFromUserDefaults:(NSString*)key
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *val = nil;
    
    if (standardUserDefaults)
        val = [standardUserDefaults objectForKey:key];
    
    // TODO: / apparent Apple bug: if user hasn't opened Settings for this app yet (as if?!), then
    // the defaults haven't been copied in yet.  So do so here.  Adds another null check
    // for every retrieve, but should only trip the first time
    if (val == nil) {
        NSLog(@"user defaults may not have been loaded from Settings.bundle ... doing that now ...");
        //Get the bundle path
        NSString *bPath = [[NSBundle mainBundle] bundlePath];
        NSString *settingsPath = [bPath stringByAppendingPathComponent:@"Settings.bundle"];
        NSString *plistFile = [settingsPath stringByAppendingPathComponent:@"Root.plist"];
        
        //Get the Preferences Array from the dictionary
        NSDictionary *settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:plistFile];
        NSArray *preferencesArray = [settingsDictionary objectForKey:@"PreferenceSpecifiers"];
        
        //Loop through the array
        NSDictionary *item;
        for(item in preferencesArray)
        {
            //Get the key of the item.
            NSString *keyValue = [item objectForKey:@"Key"];
            
            //Get the default value specified in the plist file.
            id defaultValue = [item objectForKey:@"DefaultValue"];
            
            if (keyValue && defaultValue) {
                [standardUserDefaults setObject:defaultValue forKey:keyValue];
                if ([keyValue compare:key] == NSOrderedSame)
                    val = defaultValue;
            }
        }
        [standardUserDefaults synchronize];
    }
    return val;
}

@end
