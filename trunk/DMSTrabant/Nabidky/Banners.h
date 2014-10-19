//
//  Baners.h
//  DirectCheckin
//
//  Created by Jan Kubis on 14.02.13.
//
//

#import <Foundation/Foundation.h>
#import "BaseDBManager.h"


@interface Banner : NSObject

@property (nonatomic, retain) NSData * banner;
@property (nonatomic, retain) NSString * bannerhash;

@end

@interface DBBanners : BaseDBManager
- (Banner*) getBannerForHash:(NSString*)hash;
- (void) insertBanner:(NSData *)banner banerHash:(NSString*)bannerHash;

- (void) checkNabidky;
- (void) reloadData;
- (void) parseBaners;
- (void) setBannersFromCheckin:(NSArray*)data;
@end