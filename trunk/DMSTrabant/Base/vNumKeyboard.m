//
//  vNumKeyboard.m
//  DirectCheckin
//
//  Created by Jan Kubis on 04.01.13.
//
//

#import "vNumKeyboard.h"
#import <QuartzCore/QuartzCore.h>
#import "TrabantAppDelegate.h"

#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])
#define ROOTNAVIGATOR ([TRABANT_APP_DELEGATE rootNavController])


@interface vNumKeyboard()
{
    UILabel *lblField;
    __weak IBOutlet UIButton *btnFloatPointSep;
    IBOutletCollection(UIButton) NSArray *buttons;
    __weak IBOutlet UIView *vPC;

    BOOL decimal;
}

@end

@implementation vNumKeyboard
@synthesize value=_value;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil label:(UILabel*)label
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        lblField = label;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLocale *loc = [NSLocale currentLocale];
    _value = @"";
    decimal = NO;
//    NSNumberFormatter* numFormat = [[NSNumberFormatter alloc] init];
//    btnFloatPointSep.titleLabel.text = [loc objectForKey:NSLocaleDecimalSeparator];
    [btnFloatPointSep setTitle:[loc objectForKey:NSLocaleDecimalSeparator] forState:UIControlStateNormal];
    // Do any additional setup after loading the view from its nib.

//    for(UIButton *btn in self.view.subviews)
//    {
//        btn.layer.cornerRadius = 10;
//        btn.clipsToBounds = YES;
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonPresed:(UIButton*)sender
{
    
    if(sender.tag == 1)
    {
        lblField.text = @"";
        _value = @"";
        decimal = NO;
        return;
    }
    else if(sender.tag == 2)
    {
        if(!decimal)
            decimal = YES;
        else
            return;
    }
    
    _value = [_value stringByAppendingString:sender.titleLabel.text];
    
    double pc;
    NSScanner *s = [NSScanner localizedScannerWithString:_value];
    if([s scanDouble:&pc])
    {
        NSNumber *numValue = [NSNumber numberWithDouble:pc];
        lblField.text = [NSString stringWithFormat:@"%@", [TRABANT_APP_DELEGATE.numFormat stringFromNumber:numValue]];
    }
}

- (void)viewDidUnload {
    btnFloatPointSep = nil;
    buttons = nil;
    [super viewDidUnload];
}
@end
