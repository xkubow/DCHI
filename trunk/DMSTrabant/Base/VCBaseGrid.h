//
//  VCBaseGrid.h
//  DirectCheckin
//
//  Created by Jan Kubis on 21.01.13.
//
//

#import <UIKit/UIKit.h>

@protocol BaseGridDelegate;

@interface Column : NSObject

@property (nonatomic, readwrite) CGRect frame;
@property (nonatomic, readwrite) NSTextAlignment textAlignment;
@property (nonatomic, readwrite) UIColor *backgroundColor;
@property (nonatomic, readwrite) UIColor *textColor;
@property (nonatomic, readwrite) UIFont *font;
@property (nonatomic, readwrite) NSString *caption;
@property (nonatomic, readwrite) NSString *dictEnum;

-(id)initWithFrame:(CGRect)newFrame;

@end

@interface VCBaseGrid : UIViewController
enum GridType{  eGRDSDA, eGRDPZ, eGRDODLPOLZ, eGRDPLANZAK, eGRDZOZNAMRZV, eGRDVYRVOZ, eGRDPALIVODRUH, eGRDSCENARE, eGRDVOZHISTORY, eGRDVOZINFO, eGRDZAKINFO, eGRDSILUETY, eGRDODBII};


@property (nonatomic, retain) NSArray *columnsWidth;
@property (nonatomic, retain) NSArray *columnsCaptions;
@property (nonatomic, retain) NSArray *gridData;
@property (nonatomic, retain) NSArray *columnsSort;
@property (nonatomic, retain) NSArray *columnsTextAligment;
@property (nonatomic, retain) NSArray *columnsFont;
@property (nonatomic, retain) NSArray *columns;

@property (nonatomic, readwrite) NSInteger columnsCaptionsHeight;
@property (nonatomic, readwrite) enum GridType gridType;
@property (nonatomic, readwrite) NSInteger gridRowHeight;
@property (nonatomic, readwrite) NSString *viewTitle;
@property (nonatomic, readwrite) BOOL showNavBar;
@property (nonatomic, readwrite) UITableViewCellSelectionStyle cellSelectionStyle;

- (id)initWithFrame:(CGRect)r;
- (UITableView *)gridTableView;
- (void) setSelectRow:(NSIndexPath*)indexPath;
- (Column*) addColumnWithSize:(CGSize)cellSize textAlign:(NSTextAlignment)textAlign;
- (void)addExtraViewsToCell:(UITableViewCell*)cell rowAtIndexPath:(NSIndexPath *)indexPath;
- (void) loadNavBar;


@property(nonatomic,assign)    id<BaseGridDelegate>    baseGridDelegate;

@end


@protocol BaseGridDelegate <NSObject>

- (void)baseGridSelected:(VCBaseGrid *)Sender data:(id)data;
- (void)baseGridDisaper:(VCBaseGrid *)Sender;

@end
