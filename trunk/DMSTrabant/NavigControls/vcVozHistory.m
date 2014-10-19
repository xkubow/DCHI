//
//  vcVozHistory.m
//  Mobile checkin
//
//  Created by  on 13.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "vcVozHistory.h"
#import "DMSetting.h"
#import "TrabantAppDelegate.h"
#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])


@interface vcVozHistory()
{
    UIColor *actualColor;
    UIImage *zakImg, *neZakImg;
    NSArray *color, *rowColor;

    rowEnum lastRow;
}
   
@end;



@implementation vcVozHistory

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
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
    rowColor = [[NSArray alloc] init];
    
    lastRow = 0;
    color = [NSArray arrayWithObjects:[UIColor colorWithRed:0 green:0 blue:1 alpha:0.1], [UIColor colorWithRed:0 green:0 blue:1 alpha:0.02], nil];
    
    zakImg = [UIImage imageNamed:@"HistoriaUzivatela"];
    neZakImg = [UIImage imageNamed:@"HistoriaNeUzivatela"];

}


- (void)viewDidUnload
{
    actualColor = nil;
    color = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view updateConstraints];
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void) createGridFromColumsWithCell:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath
{
    NSInteger i=0;
    
    for(Column *c in [self columns])
    {
        UILabel *lblCap = [[UILabel alloc] initWithFrame:c.frame];
        lblCap.tag = i+1;
        lblCap.backgroundColor = c.backgroundColor;
        lblCap.textAlignment = c.textAlignment;
        [cell.contentView addSubview:lblCap];
        i++;
    }
}

- (void) loadColumnDataToCell:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath;
{
    NSInteger i=0;
//    NSArray *_columnsSort = [self columnsSort];
    id data = [self gridData][indexPath.row];
    
    if(rowColor.count > indexPath.row)
        actualColor = [color objectAtIndex:[rowColor[indexPath.row] integerValue]];
    else 
    {
        if(eZAKAZKAROW == [[data objectForKey:@"HISTORY_TYPE"] integerValue])
        {
            rowColor = [rowColor arrayByAddingObject: ([color indexOfObject:actualColor] == 0)?@1:@0];
            actualColor = [color objectAtIndex:[rowColor.lastObject integerValue]];
        } else if(!rowColor.count)
            rowColor = [NSArray arrayWithObject:@1];
        else
            rowColor = [rowColor arrayByAddingObject: rowColor.lastObject];
    }
    
    for(Column *c in [self columns])
    {
        UILabel *lblCap = (UILabel*)[cell viewWithTag:i+1];
        if([c.dictEnum isEqualToString:@"HISTORY_TYPE_TXT"] && lastRow == [[data objectForKey:@"HISTORY_TYPE"] integerValue])
        {
            lblCap.text = @"";
            i++;
            continue;
        }
        if(existInDic(data, c.dictEnum))
        {
            if([c.dictEnum isEqualToString:@"HISTORY_TYPE_TXT"])
                lblCap.textColor = [UIColor colorWithRed:81.0/255.0 green:102.0/255.0 blue:145.0/255.0 alpha:1.0];
            lblCap.text = [data objectForKey:c.dictEnum];
        }
        else
            lblCap.text = @"";
        i++;
    }
    
    lastRow = [[data objectForKey:@"HISTORY_TYPE"] integerValue];
    [cell.contentView setBackgroundColor:actualColor];

    if(existInDic(data, @"CUSTOMER_ID") && [[data objectForKey:@"CUSTOMER_ID"] integerValue] == [[[DMSetting sharedDMSetting].vozidlo valueForKey:@"CUSTOMER_ID"] integerValue])
        cell.imageView.image = zakImg;
    else
        cell.imageView.image = neZakImg;
}

@end
