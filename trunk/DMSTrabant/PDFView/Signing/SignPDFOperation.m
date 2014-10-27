//
//  SignPDF.m
//  DirectCheckin
//
//  Created by Jan Kubis on 08.10.14.
//
//

#import "SignPDFOperation.h"
#import "DejalActivityView.h"

@interface SignPDFOperation()
{
    
}

@end

@implementation SignPDFOperation

-(BOOL)XCASDK_Operations_ActivateLoggingFor:(XCAOperationLoggingType)pLoggingType
{
    return YES;//[DemoConfiguration sharedConfiguration].loggingEnabled;
}

-(BOOL) XCASDK_Operations_ShouldShowToolbarButton:(XCAOperationToolbarButton)pButton
{
    if (pButton == kXCACloseButton) {
        return YES;
    }
    
    // return NO here to remove toolbar buttons from the signature dialog
    if (pButton == kXCASignatureBarCancel) return YES;
    if (pButton == kXCASignatureBarRetry) return YES;
    if (pButton == kXCASignatureBarColor) return YES;
    if (pButton == kXCASignatureBarSlide) return YES;
    if (pButton == kXCASignatureBarPenSelect) return YES;
    if (pButton == kXCASignatureBarOk) return YES;
    
    return YES; // show all other buttons
}

-(BOOL) XCASDK_Operations_WillInvokeUserActivatedOperation:(XCAOperation)pOperation withControl:(UIControl *)pControl
{
    if (pOperation == kXCACloseDocument) {
//        UIAlertView *closeAlert = [[UIAlertView alloc] initWithTitle:@"Really close?" message:@"Do you really want to close the view?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK, Close!", nil];
//        
//        [closeAlert show];
        [self close];
        return YES;
    }
    return NO;
}

-(void)close
{
    [[[XCASDK_Manager sharedManager] getXCAViewController] dismissViewControllerAnimated:YES completion:nil];
    [DejalBezelActivityView removeViewAnimated:YES];
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:155.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1]];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // button OK clicked, close the document
    if (buttonIndex == 1) {
        [[[XCASDK_Manager sharedManager] getXCAViewController] dismissViewControllerAnimated:YES completion:nil];
        [DejalBezelActivityView removeViewAnimated:YES];
        [[UITabBar appearance] setTintColor:[UIColor colorWithRed:155.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1]];
    }
}

-(BOOL)XCASDK_Operations_IsDocumentOnlyMode {
    return YES;//[DemoConfiguration sharedConfiguration].singleDocumentMode;
}

-(BOOL)XCASDK_Operations_MayUsePenForSignature:(NSString *)pPenDriverName supportsPressure:(BOOL)pSupportsPressure {
//    if ([DemoConfiguration sharedConfiguration].onlyPenEnabled) {
//         only show pressure sensitive devices if configured
//        return pSupportsPressure;
//    }
    return YES;
}



@end
