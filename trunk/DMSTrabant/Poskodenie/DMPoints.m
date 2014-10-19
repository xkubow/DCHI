//
//  DMPoint.m
//  DMSTrabant
//
//  Created by Jan Kubis on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DMPoints.h"
#import "DMSetting.h"

@implementation mPoint
@synthesize pointButton, imageView, popis, pozicia, index;

-(mPoint*)init
{
    self = [super init];
    if(self)
    {
        popis = @"";
    }
    
    return self;
}

@end

@interface DMPoints()
{
    UIImage *imgBodDefault, *imgBodClicked, *imgBodSelected, *imgBodCrash, *imgBodCrash_s;
//    BOOL recomputePositions;
}

@end

@implementation DMPoints
@synthesize showedPoints, pravaStrana, lavaStrana, predok, zadok, strecha, imgSpona;
@synthesize pomerHeigth=_pomerHeigth;
@synthesize pomerWidth=_pomerWidth;
@synthesize imgCorpSize=_imgCorpSize;
@synthesize imgRect=_imgRect;
@synthesize recomputePositions=_recomputePositions;


+ (DMPoints *) sharedDMPoints { 
    static DMPoints * shared = nil; 
    if ( !shared ) {
        shared = [[self alloc] init];
        shared.pravaStrana = [[NSMutableArray alloc] init];
        shared.lavaStrana = [[NSMutableArray alloc] init];
        shared.predok = [[NSMutableArray alloc] init];
        shared.zadok = [[NSMutableArray alloc] init];
        shared.strecha = [[NSMutableArray alloc] init];
        shared.showedPoints = shared.lavaStrana;
    }
    return shared; 
} 

- (id) init{
    if ((self = [super init])) {
        imgBodDefault = [UIImage imageNamed:@"bod.png"];
        imgBodClicked = [UIImage imageNamed:@"bod_s.png"];
        imgBodSelected = [UIImage imageNamed:@"bod_s.png"];
        imgBodCrash = [UIImage imageNamed:@"stop.png"];
        imgBodCrash_s = [UIImage imageNamed:@"stop_s.png"];
        _recomputePositions = NO;
    }
    return self;
}

- (void) setSelectedPoint:(mPoint *)newPoint {
    [[selectedPoint pointButton] setSelected:NO];
    [[selectedPoint pointButton] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[selectedPoint pointButton] setTitle:[NSString stringWithFormat:@"%d",[selectedPoint index]+1] forState:UIControlStateNormal];
//    [[selectedPoint imageView] setAlpha:0.5];
    selectedPoint = newPoint;
    [[selectedPoint pointButton] setSelected:YES];
    [[selectedPoint pointButton] setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [[selectedPoint pointButton] setTitle:[NSString stringWithFormat:@"%d",[selectedPoint index]+1] forState:UIControlStateSelected];
//    [[selectedPoint imageView] setAlpha:1.0];
}
- (mPoint *) selectedPoint {
    return selectedPoint;
}

- (NSMutableArray *) getPointsByIndex:(NSInteger)picIndex{
    switch (picIndex) {
        case ePRAVASTRANA:
            return pravaStrana;
        case eLAVASTRANA:
            return lavaStrana;
        case ePREDOK:
            return predok;
        case eZADOK:
            return zadok;
        case eSTRECHA:
            return strecha;
        default:
            return nil;
            break;
    }
}

- (void) changeIndexes:(NSInteger)picIndex {
    NSMutableArray *points = [self getPointsByIndex:picIndex];
    for (NSInteger i=0; i < [points count]; i++) {
        mPoint *p = [points objectAtIndex:i];
        p.index = i;
        [p.pointButton setTitle:[NSString stringWithFormat:@"%d",i+1] forState:UIControlStateNormal];
        [p.pointButton setTitle:[NSString stringWithFormat:@"%d",i+1] forState:UIControlStateHighlighted];
        [p.pointButton setTitle:[NSString stringWithFormat:@"%d",i+1] forState:UIControlStateSelected];
    }
}

- (void) removePointsFromPic {
    for(NSInteger i=0; i<[showedPoints count]; i++){
        [[[showedPoints objectAtIndex:i] pointButton] removeFromSuperview];
//        [[[showedPoints objectAtIndex:i] imageView] removeFromSuperview];
    }
}

- (void) addPointsToPic:(NSInteger)picIndex view:(UIView *)view{
    showedPoints = [self getPointsByIndex:picIndex];

    for(NSInteger i=0; i<[showedPoints count]; i++){
        UIButton *mb = [[showedPoints objectAtIndex:i] pointButton];
        [view insertSubview:mb belowSubview:imgSpona];
//        [viewControler.view addSubview:mb];
    }
}

- (NSMutableArray *)setShowedPointsByPicIndex:(NSInteger)picIndex{
    [self setShowedPoints:[self getPointsByIndex:picIndex]];
    return [self showedPoints];
}

- (NSInteger) getIndexForPic:(NSInteger) picIndex{
    return ([[self getPointsByIndex:picIndex] count]);
    
}
- (NSString *) getStringIndexForPic:(NSInteger) picIndex{
    return ([NSString stringWithFormat:@"%d",[[self getPointsByIndex:picIndex] count] +1]);
    
}
- (void) insertPoint:(id)object picIndex:(NSInteger)picIndex{
    NSInteger index = [self getIndexForPic:picIndex];
    [object setIndex:index];
    NSString *titl = [NSString stringWithFormat:@"%d", [object index]+1];
    [[object pointButton] setTitle:titl forState:UIControlStateNormal];
    [[object pointButton] setTitle:titl forState:UIControlStateSelected];
    [[object pointButton] setTitle:titl forState:UIControlStateHighlighted];
    [[self getPointsByIndex:picIndex] addObject:object];
}
- (mPoint *) getPoint:(NSInteger)objectIndex picIndex:(NSInteger)picIndex{
    if(objectIndex >= [[self getPointsByIndex:picIndex] count])
        return nil;
    return [[self getPointsByIndex:picIndex] objectAtIndex:objectIndex];
}
- (UIButton *) getPointButton:(NSInteger)objectIndex picIndex:(NSInteger)picIndex{
    return [[[self getPointsByIndex:picIndex] objectAtIndex:objectIndex] pointButton];
}
- (NSInteger) getIndexForPoint:(mPoint *)object picIndex:(NSInteger)picIndex{
    return [[self getPointsByIndex:picIndex] indexOfObject:object];
}
- (void) removePoint:(NSInteger)objectIndex picIndex:(NSInteger)picIndex{
    [[self getPointsByIndex:picIndex] removeObjectAtIndex:objectIndex];
    [self changeIndexes:picIndex];
}
- (void)removeAllData {
    showedPoints = nil;
  
    for (mPoint *p in pravaStrana)
        [p.pointButton removeFromSuperview];
    for (mPoint *p in lavaStrana)
        [p.pointButton removeFromSuperview];
    for (mPoint *p in predok)
        [p.pointButton removeFromSuperview];
    for (mPoint *p in zadok)
        [p.pointButton removeFromSuperview];
    for (mPoint *p in strecha)
        [p.pointButton removeFromSuperview];
        
    [pravaStrana removeAllObjects]; 
    [lavaStrana removeAllObjects];
    [predok removeAllObjects];
    [zadok removeAllObjects];
    [strecha removeAllObjects];
}

- (void) dragged: (UIControl *) c withEvent: (UIEvent *) ev {
}
- (void)pointTapHandler:(id)Sender {
}

-(void)recomputePositionsWithOwner:(id)Sender
{
    // bude prepocitanie az po otvoreni listu pre obrazenie trabantu
    if(!_recomputePositions)
        return;
    
    for(NSInteger i=0; i<5; i++){
        NSMutableArray *ma = [self getPointsByIndex:i];
        for(mPoint *p in ma)
        {
            CGFloat x = p.pozicia.x / _pomerWidth;
            CGFloat y = p.pozicia.y / _pomerHeigth;
            x = x / _imgCorpSize.width;
            y = y / _imgCorpSize.height;
            x += _imgRect.origin.x;
            y += _imgRect.origin.y;
            p.pointButton.frame = CGRectMake(x-20, y-20, 40, 40);
            [p.pointButton addTarget:Sender action:@selector(dragged:withEvent: ) forControlEvents: UIControlEventTouchDragOutside | UIControlEventTouchDragInside];
            [p.pointButton addTarget:Sender action:@selector(pointTapHandler: ) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    _recomputePositions = NO;
}

-(void)loadPoints:(NSArray*)newPoints
{
    _recomputePositions = YES;
    for(NSInteger i=1; i<6; i++){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"IMAGE_ENUM.intValue = %d", i];
        NSArray *f = [newPoints filteredArrayUsingPredicate:predicate];
        NSMutableArray *ma = [self getPointsByIndex:i];
        [ma removeAllObjects];
        for(NSDictionary *d in f)
        {
            mPoint *p = [[mPoint alloc] init];
            p.pozicia = CGPointMake([[d objectForKey:@"COORD_X"] floatValue], [[d objectForKey:@"COORD_Y"] floatValue]);
            p.index = [[d objectForKey:@"ORDER"] integerValue]-1;
            UIButton *newPButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [newPButton setTag:([[d valueForKey:@"DAMAGE_ENUM"] integerValue] == 2)?2:1];
            [newPButton setTitle:@"" forState:UIControlStateNormal];
            [newPButton setTitle:@"" forState:UIControlStateSelected];

            if([[d valueForKey:@"DAMAGE_ENUM"] integerValue] == 2) {
                [newPButton setBackgroundImage:imgBodDefault forState:UIControlStateNormal];
                [newPButton setBackgroundImage:imgBodClicked forState:UIControlStateHighlighted];
                [newPButton setBackgroundImage:imgBodSelected forState:UIControlStateSelected];
            } else
            {
                [newPButton setBackgroundImage:imgBodCrash forState:UIControlStateNormal];
                [newPButton setBackgroundImage:imgBodCrash_s forState:UIControlStateHighlighted];
                [newPButton setBackgroundImage:imgBodCrash_s forState:UIControlStateSelected];
            }
            [newPButton setBackgroundColor: [UIColor clearColor]];
            p.pointButton = newPButton;
            [self insertPoint:p picIndex:i-1];
        }
    }
}

@end
