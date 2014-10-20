//
//  vcPDFImageViewver.m
//  DirectCheckin
//
//  Created by Jan Kubis on 24.09.14.
//
//

#import "vcPDFImageViewver.h"
#import "vcServerPrinters.h"
#import "DMSetting.h"
#import "TrabantAppDelegate.h"
#import "WSDCHIDataTransfer.h"
#import "DejalActivityView.h"
#import "vcEmail.h"
#import <QuartzCore/QuartzCore.h>
#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])
#define ROOTNAVIGATOR ([TRABANT_APP_DELEGATE rootNavController])

@interface vcPDFImageViewver ()<UIPrintInteractionControllerDelegate, UIPopoverControllerDelegate, UIDocumentInteractionControllerDelegate>
{
    __weak IBOutlet UIScrollView *svImage;
    UIPrintInteractionController *_pic;
    UIImageView *_vImageView;
    UIPopoverController *_popoverController;
    UIDocumentInteractionController *_documentInteractionController;
    UIBarButtonItem *_btnServerPrint;
    UIBarButtonItem *_btnAirPrint;
}
@end

@implementation vcPDFImageViewver

- (id)init
{
    self = [super initWithNibName:@"vcPDFImageViewver" bundle:[NSBundle mainBundle]];
    if (self) {
            self.view.frame = CGRectMake(0, 0, 1000, 700);
            [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage *img = [UIImage imageWithContentsOfFile:[DMSetting sharedDMSetting].pdfReportImageFilePath];
    _vImageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, img.size.width * 0.40, img.size.height * 0.40)];
    _vImageView.contentMode = UIViewContentModeScaleAspectFill;
    _vImageView.image = img;//[Rezident imageWithImage:img scaledToSize:_vImageView.frame.size];
    [svImage addSubview:_vImageView];
    svImage.clipsToBounds = NO;
    svImage.contentSize = _vImageView.bounds.size;
    svImage.zoomScale = 1.0;
    svImage.maximumZoomScale = 10.0;
    svImage.minimumZoomScale = 1.0;
    
}


- (void) setNavigationBar
{
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    
    CGRect nr = self.navigationController.navigationBar.frame;
    UIImage *img = [UIImage imageNamed:@"alu_texture_navigation.png"];
    
    UIGraphicsBeginImageContext(CGSizeMake(nr.size.width, nr.size.height));
    [img drawInRect:nr];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.navigationController.navigationBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
    
    CGRect r = self.navigationController.navigationBar.frame;
    UILabel *_lblNavBar = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, nr.size.width, r.size.height)];
    _lblNavBar.text = NSLocalizedString(@"Document", nil);
    _lblNavBar.lineBreakMode = NSLineBreakByTruncatingTail;
    _lblNavBar.backgroundColor = [UIColor clearColor];
    _lblNavBar.textColor = [UIColor whiteColor];
    _lblNavBar.font = [UIFont fontWithName:@"Verdana" size:25 ];
    _lblNavBar.textAlignment = NSTextAlignmentCenter;
    _lblNavBar.clipsToBounds = NO;
    _lblNavBar.numberOfLines = 0;
    _lblNavBar.adjustsFontSizeToFitWidth = NO;
    self.navigationItem.titleView = _lblNavBar;

    
    NSString *strBack = NSLocalizedString(@"Back", nil);
//    NSString *strAirPrint = NSLocalizedString(@"AirPrint", nil);
//    NSString *strServerPrint = NSLocalizedString(@"Server print", nil);
//    NSString *strSign = NSLocalizedString(@"Sign", "Sign");
//    NSString *strEmail = NSLocalizedString(@"Email", "Email");
    
//    UIImage *btnImg = [[UIImage imageNamed:@"tlacitko"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16)];
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:strBack style:UIBarButtonItemStyleBordered target:self action:@selector(loadBack:)];
    [back setTitleTextAttributes: @{NSFontAttributeName : [UIFont fontWithName:@"Verdana-Bold" size:12.0]
                                          , NSForegroundColorAttributeName:[UIColor whiteColor]}
                              forState:UIControlStateNormal];
    [back setTintColor:[UIColor whiteColor]];
    
    _btnAirPrint = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(airPrintContent:)];
    [_btnAirPrint setImage:[UIImage imageNamed:@"airprinter.png"]];
    [_btnAirPrint setTintColor:[UIColor whiteColor]];
    
    _btnServerPrint = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(serverPrintContent:)];
    [_btnServerPrint setImage:[UIImage imageNamed:@"printer.png"]];
    [_btnServerPrint setTintColor:[UIColor whiteColor]];
    
    UIBarButtonItem *btnSign = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(sign:)];
    [btnSign setImage:[UIImage imageNamed:@"sign.png"]];
    [btnSign setTintColor:[UIColor whiteColor]];
    
    UIBarButtonItem *btnOpenIn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(openIn:)];
    [btnOpenIn setTintColor:[UIColor whiteColor]];
    
    UIBarButtonItem *btnEmail = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(sendEmail:)];
    [btnEmail setImage:[UIImage imageNamed:@"mail.png"]];
    [btnEmail setTintColor:[UIColor whiteColor]];
    
    [self.navigationItem setLeftBarButtonItems:@[back, btnSign, btnEmail]];
    [self.navigationItem setRightBarButtonItems:@[_btnAirPrint, _btnServerPrint, btnOpenIn]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(printersRespond:) name:@"Printers" object: nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNavigationBar];
//    if([self navigationController])
//        [[TRABANT_APP_DELEGATE rootNavController] setNavigationBar:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    _vImageView = nil;
    svImage = nil;
    [super viewDidUnload];
}

- (void)loadBack:(id) Sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _vImageView;
}


#pragma mark - dokument methods

- (void)airPrintContent:(id)sender
{
    _btnAirPrint.enabled = NO;
    _btnServerPrint.enabled = NO;
    [self performSelector:@selector(showAirPrint:) withObject:sender afterDelay:0.1];
}

- (void)showAirPrint:(id)sender
{
    NSData *PDFData = [NSData dataWithContentsOfFile:[DMSetting sharedDMSetting].pdfReportFilePath];
    if(_pic == nil)
        _pic = [UIPrintInteractionController sharedPrintController];
    if  (_pic && [UIPrintInteractionController canPrintData: PDFData] ) {
        
        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
        printInfo.outputType = UIPrintInfoOutputGeneral;
        printInfo.jobName = @"DCHIProtokol";//[self.path lastPathComponent];
        printInfo.duplex = UIPrintInfoDuplexLongEdge;
        _pic.printInfo = printInfo;
        _pic.showsPageRange = YES;
        _pic.printingItem = PDFData;
        
        
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
            [_pic presentFromBarButtonItem:sender animated:YES
                        completionHandler:completionHandler];
        } else {
            [_pic presentAnimated:YES completionHandler:completionHandler];
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
    
    _popoverController = [[UIPopoverController alloc] initWithContentViewController:vcServerPrint];
    _popoverController.delegate = self;
    _popoverController.popoverContentSize = CGRectMake(0, 0, 300, heigth).size;
    CGRect f = ((UIView *)[_btnServerPrint valueForKey:@"view"]).frame;
    [_popoverController presentPopoverFromRect:f inView:self.navigationController.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    _btnAirPrint.enabled = YES; _btnServerPrint.enabled = YES;
}

- (void)openIn:(UIBarButtonItem *) Sender
{
    NSURL *URL = [[NSURL alloc] initFileURLWithPath:[DMSetting sharedDMSetting].pdfReportFilePath];
    
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

    UINavigationController *ncPicker = [[UINavigationController alloc] initWithRootViewController:emailView];
    ncPicker.modalPresentationStyle = UIModalPresentationPageSheet;
    ncPicker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController presentViewController:ncPicker animated:YES completion:nil];
    ncPicker.preferredContentSize = CGSizeMake(600, 380);
    ncPicker.view.superview.center = [ROOTNAVIGATOR.view convertPoint:self.view.center fromView:self.view.superview];
}

- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller {
    return self;
}

@end
