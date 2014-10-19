//
//  vcSluzbyPicker.h
//  DirectCheckin
//
//  Created by Jan Kubis on 04.01.13.
//
//

#import <UIKit/UIKit.h>

@interface vcSluzbyPicker : UIViewController

@property (nonatomic, readonly) NSString* serviceID;
@property (nonatomic, readonly) NSString* serviceText;
@property (nonatomic, readonly) NSString* pc;

- (NSDictionary *)selectedPacked;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil data:(NSArray*)data selectedRow:(NSInteger)selctedRow;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil data:(NSArray*)data;

@end
