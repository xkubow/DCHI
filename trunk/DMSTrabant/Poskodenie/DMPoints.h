//
//  DMPoint.h
//  DMSTrabant
//
//  Created by Jan Kubis on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface mPoint : NSObject

@property (retain, nonatomic) UIImageView* imageView;
@property (retain, nonatomic) UIButton* pointButton;
@property (assign, nonatomic) CGPoint pozicia;
@property (retain, nonatomic) NSString* popis;
@property (assign, nonatomic) NSInteger index;

@end

enum picEnum {
    ePRAVASTRANA = 2,
    eLAVASTRANA = 0,
    ePREDOK = 3,
    eZADOK =1,
    eSTRECHA =4
    };

@interface DMPoints : NSObject {
    mPoint *selectedPoint;
}

@property (retain, nonatomic) NSMutableArray *showedPoints, *pravaStrana, *lavaStrana, *predok, *zadok, *strecha;
@property (retain, nonatomic) UIImageView* imgSpona;
@property (nonatomic, readwrite) CGFloat pomerHeigth, pomerWidth;
@property (nonatomic, readwrite) CGSize imgCorpSize;
@property (nonatomic, readwrite) CGRect imgRect;
@property (nonatomic, readwrite) BOOL recomputePositions;

+ (DMPoints *) sharedDMPoints;
- (void) insertPoint:(id)object picIndex:(NSInteger)picIndex;
- (NSMutableArray *) getPointsByIndex:(NSInteger)picIndex;
- (NSInteger) getIndexForPic:(NSInteger) picIndex;
- (NSString *) getStringIndexForPic:(NSInteger) picIndex;
- (void) removePoint:(NSInteger)objectIndex picIndex:(NSInteger)picIndex;
- (mPoint *) getPoint:(NSInteger)objectIndex picIndex:(NSInteger)picIndex;
- (void) removePointsFromPic;
- (void) addPointsToPic:(NSInteger)picIndex view:(UIView *)view;

- (NSMutableArray *)setShowedPointsByPicIndex:(NSInteger)picIndex;
//- (void)checkPointsAtPic:(NSInteger)picIndex;
- (UIButton *) getPointButton:(NSInteger)objectIndex picIndex:(NSInteger)picIndex;
- (void)removeAllData;


- (void) setSelectedPoint:(mPoint *)newPoint;
- (mPoint *) selectedPoint;

-(void)loadPoints:(NSArray*)newPoints;
-(void)recomputePositionsWithOwner:(id)Sender;
@end
