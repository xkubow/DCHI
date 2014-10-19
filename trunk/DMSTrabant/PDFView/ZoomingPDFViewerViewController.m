//
//  ZoomingPDFViewerViewController.m
//  DirectCheckin
//
//  Created by Jan Kubis on 04.12.12.
//
//

#import "ZoomingPDFViewerViewController.h"
#import "PDFScrollView.h"
#import "TrabantAppDelegate.h"
#import "ASIHTTPRequest.h"
#import "DMSetting.h"
#import "vcServerPrinters.h"
#import "WSDCHIDataTransfer.h"
#import "DejalActivityView.h"
#import "vcEmail.h"


#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])
#define ROOTNAVIGATOR ([TRABANT_APP_DELEGATE rootNavController])

@interface ZoomingPDFViewerViewController ()<UIPrintInteractionControllerDelegate, UIPopoverControllerDelegate, UIDocumentInteractionControllerDelegate>
{
    CGPDFDocumentRef PDFDocument;
    NSData *PDFData;
    UIPrintInteractionController *pic;
    UIPopoverController *myPopoverController;
    NSInteger pageNr;
    UIBarButtonItem *_btnServerPrint;
    UIBarButtonItem *_btnAirPrint;
    UIDocumentInteractionController *_documentInteractionController;
    NSString *_PDFFilePath;
}

@end

@implementation ZoomingPDFViewerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil PDFData:(NSString*)PDFFilePath
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _PDFFilePath = PDFFilePath;
        PDFData = [[NSFileManager defaultManager] contentsAtPath:_PDFFilePath];
        CFDataRef myPDFData = (__bridge CFDataRef)PDFData;
        CGDataProviderRef provider = CGDataProviderCreateWithCFData(myPDFData);
        PDFDocument = CGPDFDocumentCreateWithProvider(provider);
        pageNr = 1;
        CGDataProviderRelease(provider);
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *strBack = NSLocalizedString(@"Back", nil);
    NSString *strAirPrint = NSLocalizedString(@"AirPrint", nil);
    NSString *strServerPrint = NSLocalizedString(@"Server print", nil);
    NSString *strSign = NSLocalizedString(@"Sign", "Sign");
    NSString *strEmail = NSLocalizedString(@"Email", "Email");
    UIBarButtonItem *next = [[UIBarButtonItem alloc] initWithTitle:strBack style:UIBarButtonItemStyleBordered target:self action:@selector(loadBack:)];
    _btnAirPrint = [[UIBarButtonItem alloc] initWithTitle:strAirPrint style:UIBarButtonItemStyleBordered target:self action:@selector(airPrintContent:)];
    _btnServerPrint = [[UIBarButtonItem alloc] initWithTitle:strServerPrint style:UIBarButtonItemStyleBordered target:self action:@selector(serverPrintContent:)];
    UIBarButtonItem *btnNextPage = [[UIBarButtonItem alloc] initWithTitle:@">" style:UIBarButtonItemStyleBordered target:self action:@selector(nextPage:)];
    UIBarButtonItem *btnPreviosPage = [[UIBarButtonItem alloc] initWithTitle:@"<" style:UIBarButtonItemStyleBordered target:self action:@selector(previosPage:)];
    
    UIBarButtonItem *btnSign = [[UIBarButtonItem alloc] initWithTitle:strSign style:UIBarButtonItemStyleBordered target:self action:@selector(sign:)];
    UIBarButtonItem *btnOpenIn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(openIn:)];
    UIBarButtonItem *btnEmail = [[UIBarButtonItem alloc] initWithTitle:strEmail style:UIBarButtonItemStyleBordered target:self action:@selector(sendEmail:)];
    
    [self.navigationItem setLeftBarButtonItems:@[next, btnPreviosPage, btnNextPage]];
    [self.navigationItem setRightBarButtonItems:@[_btnAirPrint, _btnServerPrint, btnOpenIn, btnSign, btnEmail]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(printersRespond:) name:@"Printers" object: nil];
    
    [self.navigationItem setTitle:NSLocalizedString(@"Document", nil)];
    
    CGPDFPageRef PDFPage = CGPDFDocumentGetPage(PDFDocument, 1);
    pic = [UIPrintInteractionController sharedPrintController];
    
    [(PDFScrollView *)self.view setPDFPage:PDFPage];
//    CGPDFDocumentRelease(PDFDocument);

    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillDisappear:(BOOL)animated
{
    [pic dismissAnimated:YES];
    [myPopoverController dismissPopoverAnimated:YES];
    [super viewWillDisappear:animated];
}

- (void) viewDidUnload
{
    PDFData = nil;
    pic = nil;
    myPopoverController = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight
            || interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)loadBack:(id) Sender {
    [[TRABANT_APP_DELEGATE rootNavController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)nextPage:(id) Sender {
    if(pageNr < CGPDFDocumentGetNumberOfPages(PDFDocument))
        pageNr++;
    CGPDFPageRef PDFPage = CGPDFDocumentGetPage(PDFDocument, pageNr);
    [(PDFScrollView *)self.view setPDFPage:PDFPage];
}
- (void)previosPage:(id) Sender {
    if(pageNr > 1)
        pageNr--;
    CGPDFPageRef PDFPage = CGPDFDocumentGetPage(PDFDocument, pageNr);
    [(PDFScrollView *)self.view setPDFPage:PDFPage];
}

- (void)airPrintContent:(id)sender
{
    _btnAirPrint.enabled = NO;
    _btnServerPrint.enabled = NO;
    [self performSelector:@selector(showAirPrint:) withObject:sender afterDelay:0.1];
}

- (void)showAirPrint:(id)sender
{
    if  (pic && [UIPrintInteractionController canPrintData: PDFData] ) {
        
        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
        printInfo.outputType = UIPrintInfoOutputGeneral;
        printInfo.jobName = @"DCHIProtokol";//[self.path lastPathComponent];
        printInfo.duplex = UIPrintInfoDuplexLongEdge;
        pic.printInfo = printInfo;
        pic.showsPageRange = YES;
        pic.printingItem = PDFData;
        
        
        void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
        ^(UIPrintInteractionController *pic, BOOL completed, NSError *error) {
            //            self.content = nil;
            _btnAirPrint.enabled = YES; _btnServerPrint.enabled = YES;
            if (!completed && error)
            {
                NSLog(@"FAILED! due to error in domain %@ with error code %u", error.domain, error.code);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"chyba title" message:error.localizedDescription
                                                               delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                [alert setTag:1];
                [alert show];
            }
            
        };
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [pic presentFromBarButtonItem:sender animated:YES
                        completionHandler:completionHandler];
        } else {
            [pic presentAnimated:YES completionHandler:completionHandler];
        }
    }
    else
    {
        _btnAirPrint.enabled = YES; _btnServerPrint.enabled = YES;
    }
}

- (void)serverPrintContent:(id)sender
{
    _btnAirPrint.enabled = NO; _btnServerPrint.enabled = NO;
    [[WSDCHIDataTransfer sharedWSDCHIDataTransfer] startGetPrinters];
}

- (void)printersRespond:(NSNotification *)notification
{
    NSInteger heigth = [DMSetting sharedDMSetting].printers.count * 44 +100;
    vcServerPrinters *vcServerPrint = [[vcServerPrinters alloc] initWithNibName:@"vcServerPrinters" bundle:nil];
    
    myPopoverController = [[UIPopoverController alloc] initWithContentViewController:vcServerPrint];
    myPopoverController.delegate = self;
    myPopoverController.popoverContentSize = CGRectMake(0, 0, 300, heigth).size;
    CGRect f = ((UIView *)[_btnServerPrint valueForKey:@"view"]).frame;
    [myPopoverController presentPopoverFromRect:f inView:self.navigationController.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    _btnAirPrint.enabled = YES; _btnServerPrint.enabled = YES;
}

- (void)openIn:(UIBarButtonItem *) Sender
{
    NSURL *URL = [[NSURL alloc] initFileURLWithPath:_PDFFilePath];
    
    if (URL) {
        // Initialize Document Interaction Controller
        _documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:URL];
        
        // Configure Document Interaction Controller
        [_documentInteractionController setDelegate:self];
        
        // Preview PDF
//        [_documentInteractionController presentPreviewAnimated:YES];
        [_documentInteractionController presentOptionsMenuFromBarButtonItem:Sender animated:YES];
    }

}

- (void)sign:(UIBarButtonItem *) Sender
{
//    [ROOTNAVIGATOR dismissModalViewControllerAnimated:YES];
    [ROOTNAVIGATOR dismissViewControllerAnimated:YES completion:^{
        [DejalBezelActivityView activityViewForView:ROOTNAVIGATOR.view withLabel:NSLocalizedString(@"Signing", nil) width:100 progressView:YES];
        [[WSDCHIDataTransfer sharedWSDCHIDataTransfer] signProtocol];
    }];
    
    return;
}

- (void)sendEmail:(UIBarButtonItem *) Sender
{
    vcEmail *emailView = [[vcEmail alloc] initWithNibName:@"vcEmail" bundle:[NSBundle mainBundle]];
    
    [emailView setModalPresentationStyle:UIModalPresentationFormSheet];
    UINavigationController *ncPicker = [[UINavigationController alloc] initWithRootViewController:emailView];
    [ncPicker setModalPresentationStyle:UIModalPresentationFormSheet];
    [self.navigationController presentViewController:ncPicker animated:YES completion:nil];
//    ncPicker.view.superview.frame = CGRectMake(0, 0, 600, 680);
//    ncPicker.view.superview.center = self.view.center;
}

- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller {
    return self;
}

@end
