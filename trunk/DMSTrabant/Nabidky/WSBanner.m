//
//  WSBaner.m
//  DirectCheckin
//
//  Created by Jan Kubis on 14.02.13.
//
//

#import "WSBanner.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "DMSetting.h"
#import "Banners.h"

#import "TrabantAppDelegate.h"
#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])
#define ROOTNAVIGATOR ([TRABANT_APP_DELEGATE rootNavController])

@interface WSBanner()<NSXMLParserDelegate, ASIHTTPRequestDelegate>
{
    DBBanners *banners;
    ASINetworkQueue *queue;
}
- (void)downloadBaner:(NSString *)nabidkaEnum bannerHash:(NSString*)bannerHash;

@end

@implementation WSBanner

-(WSBanner*)initWithBaners:(id)theBanners
{
    self = [super init];
    if(self)
    {
        banners = theBanners;
    }
    return self;
}

- (void)dealloc
{
    banners = nil;
    queue = nil;
}

- (ASINetworkQueue*)queue
{
    if (!queue) {
        queue = [[ASINetworkQueue alloc] init];
        [queue setDelegate:self];
        [queue setRequestDidStartSelector:@selector(requestStarted:)];
        [queue setRequestDidFinishSelector:@selector(requestForBanerObrDone:)];
        [queue setRequestDidFailSelector:@selector(requestWentWrong:)];
        [queue setQueueDidFinishSelector:@selector(queueFinished:)];
    }
    return queue;
}

- (void)checkNabidky
{
    [[self queue] cancelAllOperations];
    NSArray *nabidky = [DMSetting sharedDMSetting].nabidky;

    
    for(NSDictionary *d in nabidky)
    {
        NSString *hash = [d objectForKey:@"HASH"];
        if(!hash.length)
            continue;
        
        banners = [[DBBanners alloc] init];
        Banner *banner = [banners getBannerForHash:hash];
        
        if(!banner || !banner.banner.length)
            [self downloadBaner:[d objectForKey:@"ENUM"] bannerHash:[d objectForKey:@"HASH"]];
    }
    
    if(queue.operationCount)
        [queue go];

}


- (void)downloadBaner:(NSString *)nabidkaEnum bannerHash:(NSString*)bannerHash
{
    if(!bannerHash.length)
        return;

    NSMutableString *baseUrl = [TRABANT_APP_DELEGATE.rootNavController retrieveFromUserDefaults:@"url_web_service"].lowercaseString.mutableCopy;
    [baseUrl replaceCharactersInRange:[baseUrl rangeOfString:@"mobilecheckin.asmx" options:NSBackwardsSearch] withString:@"GetFile.ashx"];
    [baseUrl appendString:[NSString stringWithFormat:@"?typ=BannerImage&nabEnum=%@", nabidkaEnum]];
    
    ASIHTTPRequest *httpRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:baseUrl]];
    
    [httpRequest setAllowCompressedResponse:YES];
    [httpRequest setTimeOutSeconds:60];
    httpRequest.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:nabidkaEnum, @"ENUM", bannerHash, @"HASH", nil];
    [httpRequest setDidFailSelector:@selector(requestWentWrong:)];
    
    [queue addOperation:httpRequest]; //queue is an ASINetworkQueue

}

- (void)requestStarted:(ASINetworkQueue *)_queue
{
    NSLog(@"Baners queue stated:%@", _queue);
}

- (void)queueFinished:(ASINetworkQueue *)_queue
{
    NSLog(@"Baners queue done:%@", _queue);
}

-(void)requestForBanerObrDone:(ASIHTTPRequest *)request
{
    NSString *nabidHash = [request.userInfo objectForKey:@"HASH"];
    [banners insertBanner:request.responseData banerHash:nabidHash];
}

-(void)requestWentWrong:(ASIHTTPRequest *)request
{
    NSLog(@"Baners request error:%@", request.error);
}


@end
