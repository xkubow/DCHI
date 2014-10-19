//
//  vcShowInfo.m
//  Mobile checkin
//
//  Created by  on 20.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "vcShowInfo.h"
#import "TrabantAppDelegate.h"
#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])


@implementation ShowInfoTableCell

- (void) layoutSubviews {
    [super layoutSubviews]; // layouts the cell as UITableViewCellStyleValue2 would normally look like
    
    // change frame of one or more labels
    self.textLabel.frame = CGRectMake( 10, 0, 150, 30);
    self.detailTextLabel.frame = CGRectMake(170, 0, 400, 30);
}

@end;


@implementation vcShowInfo

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


#pragma mark - View lifecycle

//- (id) initWithData:(NSArray*)_data capt:(NSArray*)_capt
//{
//    self = [super init];
//    if(self)
//    {
//        clmnCapt = _capt;
//        data = _data;
//    }
//    
//    return self;
//}

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *localizedStr = NSLocalizedString(@"Back", @"back");
    UIBarButtonItem *next = [[UIBarButtonItem alloc] initWithTitle:localizedStr style:UIBarButtonItemStyleBordered target:self action:@selector(loadBack:)];
    [self.navigationItem setLeftBarButtonItem:next];
    
//    [self.navigationItem setTitle:@"Info o vozidle"];//NSLocalizedString(@"HistorieVozu", @"UI strings")];
//    CGFloat h = self.navigationController.navigationBar.frame.size.height;
/*
    theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 600, 680-h) style:UITableViewStylePlain];
    theTableView.dataSource = self, theTableView.delegate = self;
    [self.view addSubview:theTableView];
    
    keys = [NSArray arrayWithObjects: @"TEXT", @"HODNOTA", nil];
    
    rect[0] = CGRectMake( 10, 0, 200, 30);
    rect[1] = CGRectMake(190, 0, 200, 30);
 */
}


- (void)viewDidUnload
{
    /*
    theTableView = nil;
    actualColor = nil;
    data = nil;
    keys = nil;
    color = nil;
    clmnCapt = nil;
     */
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //    keys = [[data objectAtIndex:0] allKeys];
}

- (void)loadNext:(id) Sender {
    
}

- (void)loadBack:(id) Sender {
    [[TRABANT_APP_DELEGATE rootNavController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight
            || interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}



#pragma mark -
#pragma mark Table controls


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    BOOL bCaption = (indexPath.row == 0);

	NSString *MyIdentifier = @"MyId";//[NSString stringWithFormat:@"MyIdentifier %i", indexPath.row];
    
	ShowInfoTableCell *cell = (ShowInfoTableCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[ShowInfoTableCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:MyIdentifier];
        
//        cell.textLabel.text = [data[indexPath.row] objectForKey:keys[0]];
//        cell.detailTextLabel.text = [data[indexPath.row] objectForKey:keys[1]];
	}
    
	return cell;
}


@end
