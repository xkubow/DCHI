//
//  webBaseService.m
//  DirectCheckin
//
//  Created by Jan Kubis on 30.11.12.
//
//

#import "WSBaseService.h"
#import "Base64Coding.h"
#import "DMSetting.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "DejalActivityView.h"
#import "TestFlight.h"
#import "TrabantAppDelegate.h"
#import "Config.h"
#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])
#define ROOTNAVIGATOR ([TRABANT_APP_DELEGATE rootNavController])
#define VALIDAT_SECURE_CERT NO

@interface WSBaseService()<ASIProgressDelegate, NSURLConnectionDelegate>
{
    ASINetworkQueue *queue;
    ASINetworkQueue *backgroundQueue;
    ASIHTTPRequest *theConnection;
    NSInteger timeOut;
    NSURL *url;
    NSURL *XyzmoUrl;
}

//- (void) sendMessage:(NSString *)sendData action:(NSString*)action;
@end

@implementation WSBaseService
@synthesize showErrorMessag=_showErrorMessage;

- (WSBaseService*)init
{
    self = [super init];
    if(self)
    {
//        NSString *strUrl = [[TRABANT_APP_DELEGATE rootNavController] retrieveFromUserDefaults:@"url_web_service"];
        url = [NSURL URLWithString:[Config getURL]];
        XyzmoUrl = [NSURL URLWithString:@""];
//        NSString *strTimeOut = [[DMSetting sharedDMSetting].setting valueForKey:@"MChICommunicTimeout"];
//        timeOut = [[strTimeOut stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] integerValue];
    }
    return self;
}

- (ASINetworkQueue*)queue
{
    if (!queue) {
        queue = [[ASINetworkQueue alloc] init];
        [queue setDelegate:self];
        [queue setRequestDidStartSelector:@selector(requestDidStart:)];
        [queue setRequestDidFinishSelector:@selector(requestDidFinish:)];
        [queue setRequestDidFailSelector:@selector(requestDidFail:)];
        [queue setQueueDidFinishSelector:@selector(queueDidFinish:)];
        [queue setRequestDidReceiveResponseHeadersSelector:@selector(requestDidReceiveResponseHeadersSelector:)];
        [queue setMaxConcurrentOperationCount:1];
    }
//    [queue setDownloadProgressDelegate:[DejalActivityView currentActivityView].progressView];
    return queue;
}

- (ASINetworkQueue*)backQueue
{
    if (!backgroundQueue) {
        backgroundQueue = [[ASINetworkQueue alloc] init];
        [backgroundQueue setDelegate:self];
        [backgroundQueue setRequestDidStartSelector:@selector(requestDidStart:)];
        [backgroundQueue setRequestDidFinishSelector:@selector(requestDidFinish:)];
        [backgroundQueue setRequestDidFailSelector:@selector(requestDidFail:)];
        [backgroundQueue setQueueDidFinishSelector:@selector(queueDidFinish:)];
        [backgroundQueue setRequestDidReceiveResponseHeadersSelector:@selector(requestDidReceiveResponseHeadersSelector:)];
    }
    return backgroundQueue;
}

- (void)cancelQueue
{
    [queue cancelAllOperations];
}


- (void) sendFormMessage:(NSDictionary *)sendData action:(NSString*)action
{
    ASINetworkQueue *q = [self queue];
    
    NSMutableString *baseUrl = [Config getURL].lowercaseString.mutableCopy;
    [baseUrl replaceCharactersInRange:[baseUrl rangeOfString:@"mobilecheckin.asmx" options:NSBackwardsSearch] withString:@"PostImage.aspx"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:baseUrl]];
    request.validatesSecureCertificate = VALIDAT_SECURE_CERT;
    
//    [request setTimeOutSeconds:60];
    request.userInfo = [NSDictionary dictionaryWithObjects:@[action] forKeys:@[@"ACTION"]];
//    [request setDownloadProgressDelegate:[DejalActivityView currentActivityView].progressView];
//    [request setShowAccurateProgress:YES];
//    [request setShouldContinueWhenAppEntersBackground:YES];
    
    UIImage *img = [[DMSetting sharedDMSetting].takenImages[0] valueForKey:@"IMAGE"];
    NSData *data = [NSData dataWithData:UIImageJPEGRepresentation(img, 0.5)];//[NSData dataWithData: UIImagePNGRepresentation(img)];

    [request setData:data withFileName:@"defaultImage.jpg" andContentType:@"image/jpg" forKey:@"IMAGE"];

    [request setDelegate:self];
    [request setUploadProgressDelegate:self];
    
    [q addOperation:request];
    [q go];
    
}

- (void) sendPostMessage:(NSString *)body urlData:(NSDictionary *)urlData action:(NSString*)action
{
    ASINetworkQueue *q = [self queue];
    NSString *valSeparator = @"?";
    NSMutableString *sUrl = [NSMutableString stringWithFormat:@"%@", TRABANT_APP_DELEGATE.dbPath];
    
    [sUrl appendFormat:@"%@/", [urlData valueForKey:@"ACTIONURL"] ];
    
    for(NSString *key in urlData.allKeys){
        if([key isEqualToString:@"ACTION"] || [key isEqualToString:@"ACTIONURL"])
            continue;
        [sUrl appendFormat:@"%@%@=%@", valSeparator, key, [urlData valueForKey:key]];
        valSeparator = @"&";
    }
    NSString *strUTF8 = [sUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@", strUTF8);
    
//    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:sUrl]];
//    request.validatesSecureCertificate = VALIDAT_SECURE_CERT;
//    request.postFormat = ASIMultipartFormDataPostFormat;
//    request setpo
//    [request setPostValue:body forKey:@"body"];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:strUTF8]];
    [self setHeadersForRequest:request];
    request.validatesSecureCertificate = VALIDAT_SECURE_CERT;
    
    NSString *msgLength = [NSString stringWithFormat:@"%d", [body length]];
    NSLog(@"%@", body);
    
    [request setTimeOutSeconds:30];
    [request addRequestHeader: @"Content-Type" value:@"application/json; charset=utf-8"];
    [request addRequestHeader: @"Content-Length" value:msgLength];
    [request setRequestMethod: @"POST"];
    //    [request setDownloadProgressDelegate:[DejalActivityView currentActivityView].progressView];
    //    [request setShowAccurateProgress:YES];
    //    [request setShouldContinueWhenAppEntersBackground:YES];
    
    request.userInfo = [NSDictionary dictionaryWithObjects:@[action] forKeys:@[@"ACTION"]];
    
    [request appendPostData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    request.userInfo = urlData;
    [request setDelegate:self];
    [q addOperation:request];
}
- (void) sendGetMessage:(NSDictionary *)sendData action:(NSString*)action
{
    [self sendGetMessage:sendData action:action backgroud:NO];
}

-(void)setHeadersForRequest:(ASIHTTPRequest*)request
{
    id date = [Config getUpdateDate];

    [request addRequestHeader:@"PCHI-DEVICE-NAME" value:TRABANT_APP_DELEGATE.deviceName];
    [request addRequestHeader:@"PCHI-DEVICE-ID" value:[Config getUUID]];
    [request addRequestHeader:@"PCHI-DEVICE-VERSION" value:[NSString stringWithFormat:@"%d.%d.%d", [Config getGenerationVersion], [Config getMajorDBVersion], [Config getCommunicationVersion]]];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"basic %@", TRABANT_APP_DELEGATE.authorization]];
    [request addRequestHeader:@"accept-language" value:TRABANT_APP_DELEGATE.actualLanguage];

    NSString *action = [request.userInfo valueForKey:@"ACTION"];
    if(date != nil && ![action isEqualToString:@"GetBanners"] && ![action isEqualToString:@"GetFiles"] && ![action isEqualToString:@"GetStaticData"])//GetBanners
    {
//        NSDateFormatter *df = [[NSDateFormatter alloc] init];
//        [df setDateFormat:@"dd' 'MMM' 'yyyy' 'HH':'mm':'ss"];
        [request addRequestHeader:@"if-Unmodified-Since" value:(NSString*)date];
    }
    else
        [[request requestHeaders] removeObjectForKey:@"if-Unmodified-Since"];
}

- (void) sendGetMessage:(NSDictionary *)sendData action:(NSString*)action backgroud:(BOOL)backgroud
{
    NSLog(@"\n############# sendGetMessage SEND #############\n%@\n%@", action, sendData);
    
    NSString *valSeparator = @"?";
    NSMutableString *sUrl = [NSMutableString stringWithFormat:@"%@", TRABANT_APP_DELEGATE.dbPath];
    
    [sUrl appendFormat:@"%@/", [sendData valueForKey:@"ACTIONURL"] ];
    
    for(NSString *key in sendData.allKeys){
        if([key isEqualToString:@"ACTION"] || [key isEqualToString:@"ACTIONURL"])
            continue;
        [sUrl appendFormat:@"%@%@=%@", valSeparator, key, [sendData valueForKey:key]];
        valSeparator = @"&";
    }
    
    NSString *strUTF8 = [sUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@", strUTF8);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:strUTF8]];
    request.validatesSecureCertificate = VALIDAT_SECURE_CERT;
    request.userInfo = sendData;
    [request addRequestHeader:@"Content-Type" value:@"application/json; charset=utf-8"];
    [self setHeadersForRequest:request];
    
//    [request setDownloadProgressDelegate:[DejalActivityView currentActivityView].progressView];
//    [request setShowAccurateProgress:YES];
//    [request setShouldContinueWhenAppEntersBackground:YES];
    
    [request setTimeOutSeconds:60];
//    [request addRequestHeader: @"UUID" value:TRABANT_APP_DELEGATE.myUUID];
    [request setRequestMethod: @"GET"];
    
//    [request appendPostData:[sendData dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    ASINetworkQueue *q;
    
    if(backgroud)
    {
        q = [self backQueue];
        [q addOperation:request];
    }
    else
    {
        q = [self queue];
        [q addOperation:request];
    }
}


#pragma mark - delegate methods

- (void)requestDidStart:(ASIHTTPRequest *)_request
{
    NSString *s = [_request.requestHeaders valueForKey:@"PCHI-DEVICE-NAME"];
    NSData *data = [s dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"requestDidStart:%f, %@, %@", _request.timeOutSeconds, _request.requestHeaders, [data description]);
}

- (void)requestDidFinish:(ASIHTTPRequest *)_request
{
    [_request.userInfo objectForKey:@"ACTION"];
    NSLog(@"\n############# BASE MSG RESULT #############\n%@\n%@", [_request.userInfo objectForKey:@"ACTION"], _request.responseString);
}

- (void)requestDidReceiveResponseHeadersSelector:(ASIHTTPRequest *)_request //responseHeaders:(NSMutableDictionary *)responseHeaders
{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *writablePath = [documentsDirectory stringByAppendingPathComponent:@"data1"];
//    [_request.responseData writeToFile:writablePath atomically:YES];
}

- (void)requestDidFail:(ASIHTTPRequest *)_request
{
    NSMutableString *errorLog = [[NSMutableString alloc] init];
    [errorLog appendFormat:@"WS Action:%@\n", [_request.userInfo valueForKey:@"ACTION"]];
    [errorLog appendFormat:@"FailureReason: %@\n", _request.error.localizedFailureReason];
    [errorLog appendFormat:@"Description:%@\n", _request.error.localizedDescription];
    [errorLog appendFormat:@"UUID: %@\n", [Config getUUID]];
    [errorLog appendFormat:@"DeviceName:%@\n", [[UIDevice currentDevice] name]];
    [errorLog appendFormat:@"UserData:%@\n", _request.userInfo];
    [errorLog appendFormat:@"Response string:%@\n", _request.responseString];
    
    NSLog(@"%@", errorLog);
    
    if([[_request.userInfo valueForKey:@"ACTION"] isEqualToString:@"GetWPForCheckIn"])
        return;
    
    TFLog(@"%@",errorLog);
//    NSLog(@"request: %@  DidFail:%@, %@", [_request.userInfo valueForKey:@"ACTION"] ,_request.error.localizedFailureReason, _request.error.localizedDescription);
//    NSLog(@"UserData:%@", _request.userInfo);
//    NSLog(@"response string:%@", _request.responseString);
    [queue cancelAllOperations];
    [DejalBezelActivityView removeViewAnimated:YES];
    if(self.showErrorMessag ) {
        [self performSelectorOnMainThread:@selector(showError:) withObject:_request.error waitUntilDone:YES];
        self.showErrorMessag = NO;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"wsDidFail" object:_request.error];

}

-(void)showError:(NSError*)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"chyba title",@"chyba title") //Chyba
                                                    message:[NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Chyba komunikace", @"chyba msg"),
                                                             error.localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)queueDidFinish:(ASINetworkQueue *)_queue
{
    NSLog(@"### QF ### webBaseService.queueDidFinish:%@", _queue);
}

- (void)request:(ASIHTTPRequest *)theRequest didSendBytes:(long long)newLength
{
    NSLog(@"%lld", newLength);
/*
    if ([theRequest totalBytesSent] > 0) {
        float progressAmount = (float) ([theRequest totalBytesSent]/[theRequest postLength]);
        NSLog(@"%lld", [theRequest totalBytesSent]);
        NSLog(@"%@", [theRequest postBody]);
        NSLog(@"%@", [theRequest postBodyFilePath]);
    }
 */
}

- (void)request:(ASIHTTPRequest *)request incrementUploadSizeBy:(long long)newLength
{
//    const long long totalbytesSend = [request totalBytesSent];
    NSLog(@"%lld", newLength);
}
- (void)setProgress:(float)newProgress
{
    NSLog(@"%f", newProgress);
}



//- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
//    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
//    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
////        if ([trustedHosts containsObject:challenge.protectionSpace.host])
//            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
//    
//    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
//}
//
//-(void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
//{
//    NSLog(@"did");
//}
@end
