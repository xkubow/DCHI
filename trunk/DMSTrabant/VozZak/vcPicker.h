//
//  vcPicker.h
//  DMSTrabant
//
//  Created by Jan Kubis on 1/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol PickerDelegate;
@interface vcPicker : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>{
    IBOutlet UIPickerView *pickerView;
}

@property (retain, nonatomic) NSArray *pickerArray;
@property (retain, nonatomic) NSArray *setPos;

@property(nonatomic,assign) id<PickerDelegate> PickerDelegate;

- (id)initWithArray:(NSMutableArray *)newPickerArray;
- (NSString *) selectedValueInComponent:(NSInteger)i;
- (NSInteger)selectedRowInComponent:(NSInteger)i;


@end

@protocol PickerDelegate <NSObject>

-(void)pickerDidSelected:(vcPicker*)Sender;

@end