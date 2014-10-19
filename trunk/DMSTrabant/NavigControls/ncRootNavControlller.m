//
//  ncRootNavControlller.m
//  DMSTrabant
//
//  Created by Jan Kubis on 1/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ncRootNavControlller.h"
#import "vcLogin.h"
#import "vcTrabantInfo.h"
#import "DMSetting.h"
#import "TrabantAppDelegate.h"
#import "vcBase.h"
#import "DejalActivityView.h"
#import "vcNabidky.h"

#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])
#define KBHEIGHT 352

@implementation NavControllerDisKeyboard
- (BOOL)disablesAutomaticKeyboardDismissal
{
    return NO;
}
@end




@implementation ncRootNavControlller
@synthesize userCaption, tbvcActive, txtActive, vozCaption;

-(void)viewDidLoad {
    [super viewDidLoad];
    Login = nil;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:)     
                                                 name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wsDidFail:) name:@"wsDidFail" object:nil];

}

-(void) viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

-(void)moveView:(BOOL)movedUp to:(NSInteger)to
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    CGRect rect = [[[self topViewController] view] frame];
    if (movedUp)
    {
        rect.origin.y -= to;
//        rect.size.height += KBHEIGHT;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y = 0.0;
//        rect.size.height = 768.0;
    }
    [self topViewController].view.frame = rect;
    
    [UIView commitAnimations];
}


- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGRect aRect = self.view.frame;
    aRect.size.width -= kbSize.width; // tabbar;
    
    id sp = [[txtActive superview] superview];
    
    NSLog(@"%@, %@, %f, %f", self.view, [info objectForKey:UIKeyboardFrameBeginUserInfoKey], aRect.size.width, ([txtActive frame].origin.y + [txtActive frame].size.height + 64));
//    CGRect rr = [];
    
    if([sp isKindOfClass:[UITableViewCell class]])
    {
        UITableView *tv = (UITableView*)[[sp superview] superview];
        NSIndexPath *ip = [tv indexPathForCell:sp];
        CGRect r = [tv rectForRowAtIndexPath:ip];
        CGRect rr = [tv convertRect:r toView:self.view];
//        NSLog(@"{%f, %f, %f, %f}, {%f, %f, %f, %f}", r.origin.x, r.origin.y, r.size.width, r.size.height, rr.origin.x, rr.origin.y, rr.size.width, rr.size.height);
        if((aRect.size.width) < (rr.origin.y + r.size.height ))
        {
            rr.origin.y += r.size.height;
            CGFloat d = rr.origin.y+1 - aRect.size.width + tv.contentOffset.y;
            tbvcActive.contentInset = UIEdgeInsetsMake(tbvcActive.contentInset.top, 0, 0, 0);
//            tbvcActive.scrollIndicatorInsets = newContentInsets;
            CGPoint scrollPoint = CGPointMake(0.0, d );
            [tbvcActive setContentOffset:scrollPoint animated:YES];
        }
    }
    else if ([txtActive isKindOfClass:[UITextField class]]
             && (aRect.size.width) < ([txtActive frame].origin.y + [txtActive frame].size.height + [txtActive superview].frame.origin.y + 64))
    {
        [self moveView:YES to:([txtActive frame].origin.y + [txtActive frame].size.height + [txtActive superview].frame.origin.y + 64) - aRect.size.width ];
    }
    else if( [txtActive isKindOfClass:[UITextView class]]
            && (aRect.size.width) < ([txtActive frame].origin.y + [txtActive frame].size.height + [txtActive superview].superview.frame.origin.y +64))
    {
        CGPoint p = [self.view convertPoint:[txtActive frame].origin fromView:[txtActive superview]];
        [self moveView:YES to:p.y - [txtActive frame].size.height - aRect.size.width ];
//        [self moveView:YES to:([txtActive frame].origin.y + [txtActive frame].size.height + [txtActive superview].superview.frame.origin.y) - aRect.size.width ];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification

{
//    UIEdgeInsets contentInsets = UIEdgeInsetsZero;

    if([[[txtActive superview] superview] isKindOfClass:[UITableViewCell class]])
    {
//        tbvcActive.contentInset = UIEdgeInsetsMake(tbvcActive.contentInset.top, 0.0, 0.0, 0.0);;
//        tbvcActive.scrollIndicatorInsets = UIEdgeInsetsZero;
        
    }
    else if([txtActive isKindOfClass:[UITextField class]]
            || [txtActive isKindOfClass:[UITextView class]]){
        [self moveView:NO to:0];
        txtActive = nil;
    }
}

-(BOOL)isLoginShowed
{
    if(self.presentedViewController != nil && [[ncModalView viewControllers] containsObject:Login])
        return YES;
    else
        return NO;
}

- (void)showLogin {
    
    if([self isLoginShowed])
        return;
    
    if(Login == nil)
        Login = [self.storyboard instantiateViewControllerWithIdentifier:@"vcLogin"];
    
    Login.loginDelegate = self;
    ncModalView = [[NavControllerDisKeyboard alloc] initWithRootViewController:Login];
    [ncModalView setModalPresentationStyle:UIModalPresentationFormSheet];
    ncModalView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [ncModalView setNavigationBarHidden:YES animated:NO];
    [self presentViewController:ncModalView animated:YES completion:nil];
//    ncModalView.view.superview.frame = CGRectMake(0, 0, 400, 200);
    ncModalView.preferredContentSize = CGSizeMake(400, 200);
//    preferredContentSize
    ncModalView.view.superview.center = CGPointMake(self.view.center.y, self.view.center.x);
}

- (void)loginSuces:(vcLogin *)Sender{
    if([[[DMSetting sharedDMSetting].loggedUser objectForKey:@"PERSONAL_ID"] integerValue] == -1)
        return;

    [[DMSetting sharedDMSetting] loadVyrVoz];
    [[DMSetting sharedDMSetting] loadPalivo];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loginDidDisaper:(vcLogin *)Sender
{
    [Login removeFromParentViewController];
    [self isLoginShowed];
    if ([[self viewControllers] count] == 1)
        [[[self viewControllers] lastObject] performSegueWithIdentifier:@"sgTabBarContr" sender:self];
    if(self.viewControllers.count > 1)
    {
        NSInteger i = [self.viewControllers.lastObject selectedIndex];
        vcBase *vb = (vcBase*) [[[self.viewControllers.lastObject viewControllers] objectAtIndex:i] viewControllers].lastObject;
        [vb performSelector:@selector(refreshData) withObject:Sender];
    }

}


-(void) loadNext:(id)sender
{
    
}

-(void) loadBack:(id)sender
{
    
}

-(void)setNavigationBar:(UIViewController *)Sender{
    [[Sender navigationItem] setPrompt:userCaption];
    
    NSString *localizedStr = NSLocalizedString(@"Odeslat data", @"next");
    UIBarButtonItem *next = [[UIBarButtonItem alloc] initWithTitle:localizedStr style:UIBarButtonItemStyleBordered target:Sender action:@selector(loadNext:)];
    
    [next setTitlePositionAdjustment:UIOffsetMake(-5.0, 0.0) forBarMetrics:UIBarMetricsDefault];
    [[Sender navigationItem] setRightBarButtonItem:next animated:YES];
    
    localizedStr = NSLocalizedString(@"Back", @"back");
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:localizedStr style:UIBarButtonItemStyleBordered target:Sender action:@selector(loadBack:)];

    [[Sender navigationItem] setLeftBarButtonItem:left animated:YES];

}

/*
- (void) setSwipeGesture:(UIViewController *) Sender{
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] 
                                           initWithTarget:Sender
                                           action:@selector(handleSwipeLeft: )];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [[Sender view] addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] 
                                            initWithTarget:Sender 
                                            action:@selector(handleSwipeRight:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [[Sender view] addGestureRecognizer:swipeRight];
}
 */

- (void)enableForm
{
/*    UIViewController *vc = self.viewControllers.lastObject;
    if(vc.modalViewController)
        vc = vc.modalViewController;
    if([vc isKindOfClass:[UITabBarController class]])
    {
        vc = ((UITabBarController*)vc).selectedViewController;
        
    }
    
    if([vc isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *nc = (UINavigationController*)vc;
        vc = nc.viewControllers[0];
        [vc performSelector:@selector(EnabledAllComponentsForSelector:) withObject:self];
    }
 */
}

- (void)wsDidFail:(NSNotification *)notification
{
    [self performSelectorOnMainThread:@selector(enableForm) withObject:self waitUntilDone:YES];
}

- (void) releaseData
{
    vcTrabantInfo *vcTbi = nil;
    UITabBarController *rootTBC = self.viewControllers.lastObject;
    rootTBC.selectedIndex  = 0;
    vcTbi = (vcTrabantInfo *)[((UINavigationController*)rootTBC.selectedViewController) viewControllers].lastObject;
    [vcTbi clearAllData:vcTbi.view];
    [vcTbi setDefaultData];
    [vcTbi refreshData];
    vcNabidky *vcNab = (vcNabidky *)[((UINavigationController*)rootTBC.viewControllers.lastObject) viewControllers].lastObject;
    [vcNab refresTableData];
}


@end
