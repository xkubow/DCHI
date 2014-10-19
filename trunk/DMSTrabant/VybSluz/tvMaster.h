//
//  tvMaster.h
//  DirectCheckin
//
//  Created by Jan Kubis on 16.11.12.
//
//

#import <UIKit/UIKit.h>
#import "tvDetail.h"

typedef enum  {ePAKETY=3, eCELKY = 2, eDTNABIDKY=1, eVYBAVY = 0}spDataType;

@interface tvMaster : UITableView

@property (nonatomic, readwrite)BOOL reloadingData;

@end

@interface DMMaster : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) vcBase *baseView;
@property (nonatomic, readwrite) spDataType dataType;
@property (nonatomic, retain) tvMaster *masterView;
@property (nonatomic, retain) NSArray *masterData;

+ (DMMaster *)dmMasterWithData:(NSArray*)data detailData:(NSArray *)detailData detailView:(DMDetail *)detail masterView:(tvMaster *)master;
-(void) selectRow:(NSIndexPath*)indexPath;
@end
