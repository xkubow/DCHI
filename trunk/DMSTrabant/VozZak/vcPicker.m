//
//  vcPicker.m
//  DMSTrabant
//
//  Created by Jan Kubis on 1/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "vcPicker.h"
#import "TrabantAppDelegate.h"
#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])




@implementation vcPicker
@synthesize pickerArray, setPos, PickerDelegate;

- (NSInteger)selectedRowInComponent:(NSInteger)i
{
    return [pickerView selectedRowInComponent:i];
}

- (NSString *) selectedValueInComponent:(NSInteger)i
{
    return [[pickerArray objectAtIndex:i] objectAtIndex:[pickerView selectedRowInComponent:i]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithArray:(NSMutableArray *)newPickerArray{
    self = [super init];
    if(self)
        pickerArray = [NSMutableArray arrayWithArray:newPickerArray];
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    if([[pickerArray objectAtIndex:0] isKindOfClass:[NSArray class]])
        return [pickerArray count];
    else
        return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
//    mlabel.text=    [arrayNo objectAtIndex:row];
    if(![self navigationController] && [[self PickerDelegate] respondsToSelector:@selector(pickerDidSelected:)])
        [[self PickerDelegate] pickerDidSelected:self];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    if([[pickerArray objectAtIndex:component] isKindOfClass:[NSArray class]])
        return [[pickerArray objectAtIndex:component] count];
    else
        return [pickerArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    if([[pickerArray objectAtIndex:component] isKindOfClass:[NSArray class]])
        return [[pickerArray objectAtIndex:component] objectAtIndex:row];
    else
        return [pickerArray objectAtIndex:row];
}



#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 // Bacha maze content zo interface builderu - pokial sa dany onbjekt tvory programovo
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];  
    [pickerView selectRow:1 inComponent:0 animated:NO];
}

- (void)loadNext:(id) Sender {
    if([[self PickerDelegate] respondsToSelector:@selector(pickerDidSelected:)])
        [[self PickerDelegate] pickerDidSelected:self];
}

- (void)loadBack:(id) Sender {
    [[self parentViewController] dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewDidUnload
{
    pickerView = nil;
    pickerArray = nil;
    setPos = nil;
    PickerDelegate = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([self navigationController])
    {
        [[TRABANT_APP_DELEGATE rootNavController] setNavigationBar:self];
        [[self navigationItem] setPrompt:nil];
    }
    else
        [pickerView setFrame:[[self view] frame]];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSInteger i=0;
    for(id obj in setPos)
        [pickerView selectRow:[obj integerValue] inComponent:i++ animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight
            || interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

@end
