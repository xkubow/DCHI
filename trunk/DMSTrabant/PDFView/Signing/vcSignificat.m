//
//  vcSignificat.m
//  DirectCheckin
//
//  Created by Jan Kubis on 08.10.14.
//
//

#import "vcSignificat.h"
#import "SignPDFOperation.h"
#import "SignPDFInit.h"
#import "DMSetting.h"
#import "XCASDK/XCASDK.h"
#import "Config.h"

@interface vcSignificat ()
{
    BOOL openSignific;
    SignPDFOperation *operationsDelegate;
    SignPDFInit *initializationDelegate;
}
@end

@implementation vcSignificat

- (void)viewDidLoad {
    [super viewDidLoad];
    operationsDelegate = [[SignPDFOperation alloc] init];
    initializationDelegate = [[SignPDFInit alloc] init];
    openSignific = YES;
    // Do any additional setup after loading the view.
}

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

// open the standalone app
-(IBAction)openSignificantViewer:(id)sender {
    [[XCASDK_Manager sharedManager].sdkOperations clearOfflineDocuments];
    [XCASDK_Manager sharedManager].sdkInitialize.delegate = initializationDelegate;
    [XCASDK_Manager sharedManager].sdkOperations.delegate = operationsDelegate;
    
//    NSURL *filreUrl = [[NSURL alloc] initFileURLWithPath:[DMSetting sharedDMSetting].pdfReportFilePath];
    NSURL *workstepUrl = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://%@/WorkstepController.Process.asmx?workstepId=%@", [Config retrieveFromUserDefaults:@"SignificantServerUrl"], [DMSetting sharedDMSetting].workStepId]];
//    [[XCASDK_Manager sharedManager].sdkOperations createAdHocWorkstep:filreUrl];
    [[XCASDK_Manager sharedManager].sdkOperations openWorkstep: workstepUrl];
//        [[XCASDK_Manager sharedManager].sdkOperations syncWorkstep:[DMSetting sharedDMSetting].workStepId];
    
    [self presentViewController:[[XCASDK_Manager sharedManager] getXCAViewController] animated:YES completion:^(){
//        [openButton setHidden:NO];
    }];
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
