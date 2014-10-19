//
//  vcPoznamka.m
//  DirectCheckin
//
//  Created by Jan Kubis on 26.11.12.
//
//

#import "vcPoznamka.h"
#import "DMSetting.h"
#import "TrabantAppDelegate.h"

#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])
#define ROOTNAVIGATOR ([TRABANT_APP_DELEGATE rootNavController])

@interface vcPoznamka ()<UITextViewDelegate>
{
    __weak IBOutlet UILabel *lblCheckPoz;
    __weak IBOutlet UILabel *lblZakListPoz;
    __weak IBOutlet UITextView *txtCheckPoz;
    __weak IBOutlet UITextView *txtZakListPoz;
    __weak IBOutlet UILabel *lblUser;
    __weak IBOutlet UILabel *lblCaption;
}
- (void) refreshData;
@end

@implementation vcPoznamka

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
    lblCheckPoz.text = NSLocalizedString(@"Protokol", nil);
    lblZakListPoz.text = NSLocalizedString(@"Zakazkovy list", nil);
    lblCaption.text = NSLocalizedString(@"Poznamka", nil);
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"poznamkaOkno"]];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSDictionary *d = [DMSetting sharedDMSetting].vozidlo;
    if(existInDic(d, @"NOTE_PROTOCOL"))
        txtCheckPoz.text = [d valueForKey:@"NOTE_PROTOCOL"];
    if(existInDic(d, @"NOTE_ORDER_LIST")) {
        txtZakListPoz.text = [d valueForKey:@"NOTE_ORDER_LIST"];
    }
    [self refreshData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    txtCheckPoz = nil;
    txtZakListPoz = nil;
    lblUser = nil;
    [super viewDidUnload];
}

- (void) refreshData
{
    NSString *userName = [NSString stringWithFormat:@"%@ %@", [[DMSetting sharedDMSetting].loggedUser valueForKey:@"NAME"], [[DMSetting sharedDMSetting].loggedUser valueForKey:@"SURNAME"] ];
    lblUser.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Poradce", nil), userName];
}

#pragma mark - UITextViewDelegate methods
- (void)textViewDidEndEditing:(UITextView *)textView
{
    if(textView == txtCheckPoz)
        [ [DMSetting sharedDMSetting].vozidlo setValue:txtCheckPoz.text forKey:@"NOTE_PROTOCOL"];
    else if(textView == txtZakListPoz)
        [ [DMSetting sharedDMSetting].vozidlo setValue:txtZakListPoz.text forKey:@"NOTE_ORDER_LIST"];
    
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [ROOTNAVIGATOR setTxtActive:textView];
    [ROOTNAVIGATOR setTbvcActive:nil];
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    UITabBarController *tbc = ((UITabBarController*)TRABANT_APP_DELEGATE.rootNavController.viewControllers.lastObject);    
    for(UINavigationController *nc in tbc.viewControllers)
    {
        vcBase *vcb = nc.viewControllers.lastObject;
        vcb.btnSaveInfo.selected = NO;
    }
}
@end
