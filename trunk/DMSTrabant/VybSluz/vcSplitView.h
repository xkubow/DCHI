//
//  vcNewSplitView.h
//  DirectCheckin
//
//  Created by Jan Kubis on 16.11.12.
//
//

#import <UIKit/UIKit.h>
#import "vcBase.h"

@interface vcSplitView : vcBase
{
    
}
@property (strong,nonatomic) NSArray *filteredPacketArray;
@property (strong,nonatomic) NSString *filterPredicateString;


-(void) reloadData;
-(void) setPakety;
-(void) refreshWPData;

@end
