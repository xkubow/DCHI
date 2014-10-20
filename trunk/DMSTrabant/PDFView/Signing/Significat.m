//
//  vcSignificat.m
//  DirectCheckin
//
//  Created by Jan Kubis on 08.10.14.
//
//

#import "Significat.h"
#import "SignPDFOperation.h"
#import "SignPDFInit.h"
#import "DMSetting.h"
#import "XCASDK/XCASDK.h"
#import "Config.h"
#import "TrabantAppDelegate.h"
#import "tbcBarController.h"
#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])
#define ROOTNAVIGATOR ([TRABANT_APP_DELEGATE rootNavController])

@interface Significat ()
{
    BOOL openSignific;
    SignPDFOperation *operationsDelegate;
    SignPDFInit *initializationDelegate;
}
@end

@implementation Significat

- (Significat *)init {
    self = [super init];
    if(self)
    {
        operationsDelegate = [[SignPDFOperation alloc] init];
        initializationDelegate = [[SignPDFInit alloc] init];
    }
    return self;
}
/*
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(openSignific)
        [self openSignificantViewer:nil];
    openSignific = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
*/

// open the standalone app
- (void)openSignificantViewer {
    [[XCASDK_Manager sharedManager].sdkOperations clearOfflineDocuments];
    [XCASDK_Manager sharedManager].sdkInitialize.delegate = initializationDelegate;
    [XCASDK_Manager sharedManager].sdkOperations.delegate = operationsDelegate;
    
//    NSURL *filreUrl = [[NSURL alloc] initFileURLWithPath:[DMSetting sharedDMSetting].pdfReportFilePath];
    NSURL *workstepUrl = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://%@/WorkstepController.Process.asmx?workstepId=%@", [Config retrieveFromUserDefaults:@"SignificantServerUrl"], [DMSetting sharedDMSetting].workStepId]];
//    [[XCASDK_Manager sharedManager].sdkOperations createAdHocWorkstep:filreUrl];
    [[XCASDK_Manager sharedManager].sdkOperations openWorkstep: workstepUrl];
//        [[XCASDK_Manager sharedManager].sdkOperations syncWorkstep:[DMSetting sharedDMSetting].workStepId];
    
//    UIViewController *vc = [[XCASDK_Manager sharedManager] getXCAViewController];
//    UINavigationController *nc = (UINavigationController*)ROOTNAVIGATOR;
    tbcBarController *tbc = (tbcBarController *)ROOTNAVIGATOR.viewControllers.lastObject;
    
//    [nc presentViewController:vc animated:YES completion:nil];
    
    
    [tbc.selectedViewController.navigationController presentViewController:[[XCASDK_Manager sharedManager] getXCAViewController] animated:YES completion:nil];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
