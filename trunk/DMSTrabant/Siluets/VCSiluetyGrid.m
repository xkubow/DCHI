//
//  VCSiluetyGrid.m
//  DirectCheckin
//
//  Created by Jan Kubis on 30.01.13.
//
//

#import "VCSiluetyGrid.h"
#import "DMSetting.h"

@interface VCSiluetyGrid ()
{
    NSArray *siluetaGridData;
}

@end

@implementation VCSiluetyGrid

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
	// Do any additional setup after loading the view.
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage*) scaleImage:(UIImage*)image toSize:(CGSize)newSize {
    CGSize scaledSize = newSize;
    double scaleFactor = 1.0;
    if( image.size.width > image.size.height ) {
        scaleFactor = image.size.width / newSize.width;
        scaledSize.width = newSize.width;
        scaledSize.height = image.size.height / scaleFactor;
    }
    else {
        scaleFactor = image.size.height / newSize.height;
        scaledSize.height = newSize.height;
        scaledSize.width = image.size.width / scaleFactor;
    }
    
    UIGraphicsBeginImageContextWithOptions( scaledSize, NO, 0.0 );
    CGRect scaledImageRect = CGRectMake( 0.0, 0.0, scaledSize.width, scaledSize.height );
    [image drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

- (void) setSiluetaGridData:(NSArray *)newGridData
{

    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
//    NSInteger i=0;
    UIImage *img;
    Column *c;
    CGSize imgSize = ((Column*)self.columns[0]).frame.size;
    
    for(NSArray *a in newGridData)
    {
//        i = 0;
        for(c in self.columns)
        {
            NSInteger i = c.dictEnum.integerValue;
            NSDictionary *data = a[i];
            if([data valueForKey:@"IMAGE"] != [NSNull null])
                img = [UIImage imageWithData:[data valueForKey:@"IMAGE"]];
            else
                img = [[UIImage alloc] init];
            
            NSString *key = [NSString stringWithFormat:@"IMG%d", c.dictEnum.integerValue];
            [d setValue:img.copy forKey:key];
            key = [NSString stringWithFormat:@"THUMBNAIL%d", c.dictEnum.integerValue];
            img = [self scaleImage:img toSize:imgSize];
            [d setValue:img.copy forKey:key];
//            i++;
        }
        
        [resultArray addObject:d.copy];
    }
    self.gridData = newGridData;
    siluetaGridData = resultArray;

}

#pragma mark -
#pragma mark grid creatin methods
- (void) createGridFromColumsWithCell:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath;
{
    NSInteger i=0;
    
    for(Column *c in self.columns)
    {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:c.frame];
        imgView.tag = i+1;
        imgView.backgroundColor = c.backgroundColor;
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:imgView];
        i++;
    }

}

- (void) loadColumnDataToCell:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath
{
    NSInteger i=0;
    NSString *key;
    NSDictionary *d = siluetaGridData[indexPath.row];//self.gridData[indexPath.row];
    
    for(Column *c in self.columns)
    {
        UIImageView *imgView = (UIImageView*)[cell viewWithTag:i+1];
        key = [NSString stringWithFormat:@"THUMBNAIL%d", c.dictEnum.integerValue];
        [imgView setImage:[d objectForKey:key]];
        i++;
    }
}

@end
