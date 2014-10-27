//
//  Rezident.m
//  DirectCheckin
//
//  Created by Jan Kubis on 01.10.14.
//
//

#import "Rezident.h"

@interface NAVLabel : UILabel

@end

@implementation NAVLabel

- (void) setFrame:(CGRect)frame
{
    [super setFrame:CGRectMake(212, 10, 600, 20)];
}

@end

@implementation Rezident

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UITableViewCell *) finTableViewCell:(id)obj
{
    while ([obj superview] != nil) {
        obj = [obj superview];
        if(![obj isKindOfClass:[UITableViewCell class]])
            continue;
        else
            return (UITableViewCell *) obj;
    }
    
    return nil;
}

+(UILabel *)setNavigationTitle:(CGRect)rect
{
    UILabel *lblNavBar = [[UILabel alloc] initWithFrame:rect];//CGRectMake(212, 10, 600, 20)];
    lblNavBar.lineBreakMode = NSLineBreakByTruncatingTail;
    lblNavBar.backgroundColor = [UIColor clearColor];
    lblNavBar.textColor = [UIColor whiteColor];
    lblNavBar.font = [UIFont fontWithName:@"Verdana" size:20 ];
    lblNavBar.textAlignment = NSTextAlignmentCenter;
    lblNavBar.clipsToBounds = NO;
    lblNavBar.numberOfLines = 0;
    lblNavBar.adjustsFontSizeToFitWidth = YES;
    return lblNavBar;
}

@end
