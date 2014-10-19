//
//  vcPhotoMenu.m
//  DirectCheckin
//
//  Created by Jan Kubis on 14.10.13.
//
//

#import "vcPhotoMenu.h"

@interface vcPhotoMenu () {
    
    __weak IBOutlet UIButton *btnDeleteImg;
    __weak IBOutlet UIButton *btnShowImg;
}

@end

@implementation vcPhotoMenu

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *localizedStr = NSLocalizedString(@"Smazat foto", @"foto menu");
    [btnDeleteImg setTitle:localizedStr forState:UIControlStateNormal];
    localizedStr = NSLocalizedString(@"Nahled", @"foto menu");
    [btnShowImg setTitle:localizedStr forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    btnDeleteImg = nil;
    btnShowImg = nil;
    [super viewDidUnload];
}
- (IBAction)btnShowImgDidTouch:(id)sender {
    if([self.delegate  respondsToSelector:@selector(showImg)])
        [self.delegate showImg];
}
- (IBAction)btnDeleteImgDidTouch:(id)sender {
    if([self.delegate  respondsToSelector:@selector(deleteImg)])
        [self.delegate deleteImg];
}
@end
