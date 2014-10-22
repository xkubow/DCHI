//
//  tvDetail.h
//  DirectCheckin
//
//  Created by Jan Kubis on 16.11.12.
//
//

#import <UIKit/UIKit.h>
#import "vcBase.h"

typedef enum {eVYBAVATEXT=1, eCELKYODLOZBTN, eCELKYSLUZBABTN, eCELKYPOZAD, eCELKYPC, eSLUZBAPC, eBTNCLEARROW, eOKBTN, eDETAILTEXT, eDETAIL} cellContentType;

@interface tvDetail : UITableView

@end

@interface DMDetail : NSObject <UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate, UISearchDisplayDelegate>

@property (nonatomic, retain) NSArray* detailData;
@property (nonatomic, retain) tvDetail *detailView;
@property (nonatomic, retain) vcBase *baseView;
@property (nonatomic, readwrite) NSString* unitName;

- (void) setDataType:(NSInteger) type;
- (id) initWithData:(UITableView*)detailView;

@end
