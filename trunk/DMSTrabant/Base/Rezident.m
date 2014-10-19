//
//  Rezident.m
//  DirectCheckin
//
//  Created by Jan Kubis on 01.10.14.
//
//

#import "Rezident.h"

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

@end
