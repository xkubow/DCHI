//
//  WSProtocolRequest.m
//  DirectCheckin
//
//  Created by Jan Kubis on 06.12.12.
//
//

#import "WSProtocolRequest.h"
#import "ASIHTTPRequest.h"
#import "DMSetting.h"
#import "WSCommunications.h"
#import "TrabantAppDelegate.h"
#import "tbcBarController.h"
#import "DejalActivityView.h"
#import "ZoomingPDFViewerViewController.h"


#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])
#define ROOTNAVIGATOR ([TRABANT_APP_DELEGATE rootNavController])

@interface WSProtocolRequest()
{
    id owner;
//    NSData *data;
//    NSOperationQueue *oqRequests;
//    ASIHTTPRequest *request;
}

@end

@implementation WSProtocolRequest

-(id)initWithOwner:(id)newSender
{
    self = [super init];
    if(self)
    {
//        owner = newSender;
//        [[WSCommunications sharedWSCommunications].wsLoadCarManufactureData startDCHIReport];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pdfRepordRequestDidEnd:) name:@"DCHIReport" object: nil];
    }

    return self;
}

/*
- (id) printRequest:(NSString*)printerName
{
    NSString *sUrl = [TRABANT_APP_DELEGATE.rootNavController retrieveFromUserDefaults:@"url_web_service"];
    
//    [request clearDelegatesAndCancel];
    request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:sUrl]];
//    [request  setRequestMethod:@"POST"];
//    [request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"];
//    [request addRequestHeader:@"Content-Type" value:@"application/json"];
//    NSString *sendData = [NSString stringWithFormat:@"{\"checkin_id\":\"2345234523\"}"];
    NSString *sendData = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                          "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">"
                          "<soap12:Body>"
                          "<PrintReport xmlns=\"http://www.t-systems.cz/DMSMobile/\">"
                          "<CHECKIN_ID>%d</CHECKIN_ID>"
                          "<PRINTER_NAME>%@</PRINTER_NAME>"
                          "</PrintReport>"
                          "</soap12:Body>"
                          "</soap12:Envelope>", TRABANT_APP_DELEGATE.checking_id, printerName];
    NSString *msgLength = [NSString stringWithFormat:@"%d", [sendData length]];
    
//    [request setTimeOutSeconds:60];
    [request addRequestHeader: @"Content-Type" value:@"text/xml; charset=utf-8"];
    [request addRequestHeader: @"SOAPAction" value:@"http://www.t-systems.cz/DMSMobile/PrintReport"];
    [request addRequestHeader: @"Content-Length" value:msgLength];
    [request setRequestMethod: @"POST"];
    
    [request appendPostData:[sendData dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    
    if(!oqRequests)
        oqRequests = [[NSOperationQueue alloc] init];
    [oqRequests addOperation:request];
    
    NSLog(@"%@\n%@", sUrl, sendData);
    
//    [request startAsynchronous];
    
    
    return self;
}
*/
- (void) dealloc
{
//    data = nil;
//    [request clearDelegatesAndCancel];
//    [oqRequests cancelAllOperations];
//    oqRequests = nil;
//    request = nil;
}

- (void) cancelAllComunication
{
//    [request clearDelegatesAndCancel];
//    [oqRequests cancelAllOperations];
}

- (void) showPDFDocument
{
    if(![owner isKindOfClass:[tbcBarController class]])
        return;
    tbcBarController *rootTBC = (tbcBarController*)owner;
    UINavigationController *nc = rootTBC.selectedViewController.navigationController;

    NSData *pdfData = [DMSetting sharedDMSetting].pdfReport;
    ZoomingPDFViewerViewController *vc = [[ZoomingPDFViewerViewController alloc] initWithNibName:@"ZoomingPDFViewerViewController" bundle:[NSBundle mainBundle] PDFData:pdfData];
    
    UINavigationController *ncPicker = [[UINavigationController alloc] initWithRootViewController:vc];
    ncPicker.modalPresentationStyle = UIModalPresentationPageSheet;
    [nc presentModalViewController:ncPicker animated:YES];
    ncPicker.view.superview.frame = CGRectMake(0, 0, 900, 700);
    ncPicker.view.superview.center = rootTBC.view.superview.center;
    [DejalBezelActivityView removeViewAnimated:YES];
}

- (void)pdfRepordRequestDidEnd:(NSNotification *)notification
{
    [self performSelectorOnMainThread:@selector(showPDFDocument) withObject:nil waitUntilDone:YES];
}

/*
#pragma - ASIHTTPRequest delegate methods
- (void)requestFinished:(ASIHTTPRequest *)Sender
{
    NSLog(@"respond : %d, %@", [Sender responseData].length, [Sender responseString]);
    if(![Sender responseData].length)
    {
        [DejalBezelActivityView removeViewAnimated:YES];
        return;
    }
    if([[Sender.responseString substringToIndex:4] isEqualToString:@"%PDF"])
    {
//        data = [Sender responseData];
        [self showPDFDocument];
    }
    else
        NSLog(@"Doesnt contain %%PDF prefix, %@", [Sender.responseString substringToIndex:4]);
}

- (void)requestFailed:(ASIHTTPRequest *)Sender
{
    NSLog(@"%@", [[Sender error] localizedDescription]);
    [DejalBezelActivityView removeViewAnimated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"chyba title",nil) message:Sender.error.localizedDescription
                                      delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alert setTag:1];
    [alert show];
}

- (void) printRequestDidReciveData:(ASIHTTPRequest *)respond
{
        NSLog(@"%@", [respond responseString]);
    
}
 */
@end
