//
//  vcWelcome.m
//  DMSTrabant
//
//  Created by Jan Kubis on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "vcWelcome.h"
#import "vcTrabantInfo.h"
#import "DMSetting.h"
#import "TrabantAppDelegate.h"

#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])

@interface vcWelcome()
{
    
}

@end

@implementation vcWelcome

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

//- (void)loadTrabantInfo {
//    NSInteger showPlanVoz = [[[TRABANT_APP_DELEGATE setting] valueForKey:@"MChIPZListOnStartPrp"] integerValue];
//    vcTrabantInfo *nextView = [self.storyboard instantiateViewControllerWithIdentifier:@"vcTrabantInfo"];
//    [nextView setShowPlanVoz:showPlanVoz];
//    [[self navigationController] pushViewController:nextView animated:YES];
//}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    
    [TRABANT_APP_DELEGATE setRootNavController:(ncRootNavControlller *)[self navigationController]];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    [super viewDidLoad];
}


- (void)viewDidUnload
{
    lblVersion = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *buildVer = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *appVer = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    if(buildVer)
        appVer = [appVer stringByAppendingFormat:@" (%@)", buildVer];
    
    [lblVersion setText:appVer];
    
    [DMSetting sharedDMSetting].loggedUser = nil;
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
//    NSString *url = [[TRABANT_APP_DELEGATE rootNavController] retrieveFromUserDefaults:@"url_web_service"];
//    [[webServices sharedwebServices] setUrl:[NSURL URLWithString:url]];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [[TRABANT_APP_DELEGATE rootNavController] showLogin];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight
            || interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

@end
