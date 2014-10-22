//
//  tbcBarController.m
//  Mobile checkin
//
//  Created by  on 16.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "tbcBarController.h"
//#import "webServices.h"
#import "vcTrabantInfo.h"
#import "vcNabidky.h"
#import "DMSetting.h"
#import "vcSplitView.h"



@interface tbcBarController()
{
    vcSplitView *vc;
}

- (void) nastavSplitView;

@end

@implementation tbcBarController
@synthesize reloadData=_reloadData;
@synthesize reloadPackets=_reloadPackets;

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUInteger i=0;
    self.delegate = self;
    
    vcTrabantInfo *ti = [[vcTrabantInfo alloc] initWithNibName:@"vcTrabantinfo" bundle:[NSBundle mainBundle]];
    ti.showPlanVoz = YES;
    
    vcTrabantPictures *tp = [[vcTrabantPictures alloc] initWithNibName:@"vcTrabantPictures" bundle:[NSBundle mainBundle]];//[self.storyboard instantiateViewControllerWithIdentifier:@"vcTrabantPictures"];
    
    vcNabidky *nab = [[vcNabidky alloc] initWithNibName:@"vcNabidky" bundle:[NSBundle mainBundle]];
    
    vc = [[vcSplitView alloc] initWithNibName:@"vcSplitView" bundle:[NSBundle mainBundle]];
    
    self.viewControllers = [NSArray arrayWithObjects:
                            [[UINavigationController alloc] initWithRootViewController:
                             ti], 
                            [[UINavigationController alloc] initWithRootViewController:
                             tp],
                            [[UINavigationController alloc] initWithRootViewController:
                             vc],
                            [[UINavigationController alloc] initWithRootViewController:
                             nab], nil];
    titles = [NSArray arrayWithObjects:NSLocalizedString(@"Vozidlo", nil),
              NSLocalizedString(@"Poškození", nil),
              NSLocalizedString(@"Prohlídka", nil),
              NSLocalizedString(@"Nabídka služeb", nil), nil];
    for(id obj in self.viewControllers) 
        [obj setTitle:[titles objectAtIndex:i++]];
    
    [[[self.viewControllers objectAtIndex:0] tabBarItem] setImage:[UIImage imageNamed:@"Car-icon-riadky2"]];
    [[[self.viewControllers objectAtIndex:1] tabBarItem] setImage:[UIImage imageNamed:@"Car-icon-body2"]];
    [[[self.viewControllers objectAtIndex:2] tabBarItem] setImage:[UIImage imageNamed:@"Car-icon-sipka2"]];
    [[[self.viewControllers objectAtIndex:3] tabBarItem] setImage:[UIImage imageNamed:@"nabidka-icon2"]];
    
    ti.enableSave = NO;
    tp.enableSave = YES;
    nab.enableSave = NO;
    
    self.tabBar.tintColor = [UIColor colorWithRed:(76.0/255.0) green:(161.0/255.0) blue:(255.0/255.0) alpha:1.0];
      
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIImage *img = [Rezident imageWithImage:[UIImage imageNamed:@"alu_texture_tapbar.png"] scaledToSize:self.tabBar.frame.size];
    [self.tabBar setBackgroundImage:img];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    BOOL rotate = NO;
    
    rotate = (interfaceOrientation == UIInterfaceOrientationLandscapeRight
              || interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
    
    return rotate;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    return YES;
}
// User tapped on an item...
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{

    if(tabBarController.selectedIndex == 2)
        [self nastavSplitView];

}

- (void) nastavSplitView
{

    if(_reloadData){
        [vc reloadData];
        _reloadData = NO;
    }
    else if(_reloadPackets) {
        _reloadPackets = NO;
    }

}


@end
