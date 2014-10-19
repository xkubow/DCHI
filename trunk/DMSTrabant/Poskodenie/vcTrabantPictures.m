//
//  vcTrabantPictures.m
//  DMSTrabant
//
//  Created by Jan Kubis on 1/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <MobileCoreServices/UTCoreTypes.h>
#import <QuartzCore/QuartzCore.h>
#import "vcTrabantPictures.h"
#import "DMPoints.h"
#import "VCSiluetyGrid.h"
#import "DMSetting.h"
#import "TrabantAppDelegate.h"
#import "vcPhotoMenu.h"
#import "Config.h"

#import <AssetsLibrary/AssetsLibrary.h>


#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])
#define ROOTNAVIGATOR ([TRABANT_APP_DELEGATE rootNavController])

@implementation UIImage (fixOrientation)

- (UIImage *)fixOrientation
{
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
@end


@interface vcTrabantPictures()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate, BaseGridDelegate/*PhotoMenuDelegate*/> {
    __weak IBOutlet UILabel *lblPohledy;
    __weak IBOutlet UILabel *lblExterier;
    __weak IBOutlet UILabel *lblOderky;
    __weak IBOutlet UIImageView *mainImgView;
    __weak IBOutlet UIImageView *imgSpona;
    __weak IBOutlet UISegmentedControl *scPicSelector;
    __weak IBOutlet UIScrollView *svImages;
    __weak IBOutlet UISwitch *chbOderky;
    __weak IBOutlet UISegmentedControl *scStavExterieru;
    __weak IBOutlet UILabel *lblUser;
    __weak IBOutlet UIButton *btnSiluety;
    NSString *albumName;
//    ALAssetsLibrary* _library;
    __block ALAssetsGroup* groupToAddTo;
    UIImage *imgBodDefault, *imgBodClicked, *imgBodSelected, *imgBodCrash, *imgBodCrash_s;
    UIImageView *ivPhotos;
    NSMutableArray *showedPoints;//, *pictures;
    UIButton *selectedPicture;
    DMPoints *points;
    CGFloat pomerHeigth, pomerWidth;
    CGFloat imgCrop;
    UISwipeGestureRecognizer *swipeLeft, *swipeRight;
    UILongPressGestureRecognizer *lpgr;
    CGPoint tapedPos;
    UIImagePickerController *cameraUI;
    UIPopoverController *myPopoverController;
    BOOL dragingPoint;
}

@property (strong, atomic) ALAssetsLibrary* library;

- (void) refreshData;
- (void)changePicture:(enum picEnum)picIndex;
- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate;
@end

@implementation vcTrabantPictures
@synthesize scStavExterieru;

//---------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
//---------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

//---------------------------------------------------------------------------------------------------
- (void) setSelectedPicture:(id)Sender {
    if(selectedPicture)
        [selectedPicture setAlpha:0.5];
    selectedPicture = Sender;
    [selectedPicture setAlpha:1.0];
}
//---------------------------------------------------------------------------------------------------
- (IBAction)valueChanged:(id)sender {

    NSNumber *n = [NSNumber numberWithInt:scStavExterieru.selectedSegmentIndex+1];
    [[DMSetting sharedDMSetting].vozidlo setValue:n forKey:@"EXTERIOR_STATE"];
    
    [self setStatusOdeslani:NO];
}
//---------------------------------------------------------------------------------------------------
- (void) refreshData
{
    NSString *userName = [NSString stringWithFormat:@"%@ %@", [[DMSetting sharedDMSetting].loggedUser valueForKey:@"NAME"], [[DMSetting sharedDMSetting].loggedUser valueForKey:@"SURNAME"] ];
    lblUser.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Poradce", nil), userName];
    [self changePicture:scPicSelector.selectedSegmentIndex];
}
//---------------------------------------------------------------------------------------------------
- (UIButton *)generateBTNPoint:(CGRect)newRect{
    NSString *PointButtonKey = @"";
    UIButton *newInsert = [UIButton buttonWithType:UIButtonTypeCustom];
    [newInsert setTag:(chbOderky.isOn)?2:1];
    [newInsert setTitle:PointButtonKey forState:UIControlStateNormal];
    [newInsert setTitle:PointButtonKey forState:UIControlStateSelected];
    [newInsert setFrame:(!CGRectIsEmpty(newRect))?newRect:CGRectMake(920, 520, 40, 40)];
    newInsert.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    newInsert.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    if(chbOderky.isOn) {
        [newInsert setBackgroundImage:imgBodDefault forState:UIControlStateNormal];
        [newInsert setBackgroundImage:imgBodClicked forState:UIControlStateHighlighted];
        [newInsert setBackgroundImage:imgBodSelected forState:UIControlStateSelected];
    } else
    {
        [newInsert setBackgroundImage:imgBodCrash forState:UIControlStateNormal];
        [newInsert setBackgroundImage:imgBodCrash_s forState:UIControlStateHighlighted];
        [newInsert setBackgroundImage:imgBodCrash_s forState:UIControlStateSelected];        
    }
    
    [newInsert setBackgroundColor: [UIColor clearColor]];
    [newInsert addTarget:self action:@selector(dragged:withEvent: ) forControlEvents: UIControlEventTouchDragOutside | UIControlEventTouchDragInside];
    [newInsert addTarget:self action:@selector(pointTapHandler: ) forControlEvents:UIControlEventTouchUpInside];
    return newInsert;
    
}
//---------------------------------------------------------------------------------------------------
- (CGRect)getFrame{
    NSInteger newPos = 0;
    CGRect f;
    NSInteger lastIndex= ([[svImages subviews] count]-1);
    
    if(lastIndex >0){
        f = [[[svImages subviews] objectAtIndex:--lastIndex] frame];
        newPos = f.origin.x + f.size.width + 10;
    }
    f = CGRectMake(newPos, 0.0, 200, 130);
    [svImages setContentSize:CGSizeMake(newPos+f.size.width, f.size.height)];    
    return f;
}
//---------------------------------------------------------------------------------------------------
- (IBAction)siluetsDidTutchUpInside:(id)sender
{
    [self EnabledAllComponents:NO];
    
    NSString *vyrobekVoz = [[DMSetting sharedDMSetting].vozidlo valueForKey:@"BRAND_ID"];
    NSArray *siluets = [[DMSetting sharedDMSetting].siluets loadSiluetsWithVyrVoz:vyrobekVoz];
    
    VCSiluetyGrid *silGrid = [[VCSiluetyGrid alloc] initWithFrame:CGRectMake(0, 0, 1000, 564)];
    Column *c = [silGrid addColumnWithSize:CGSizeMake(333, 130) textAlign:NSTextAlignmentRight];
    c.dictEnum = @"0";
    
    c = [silGrid addColumnWithSize:CGSizeMake(333, 130) textAlign:NSTextAlignmentLeft];
    c.dictEnum = @"1";
    
    c = [silGrid addColumnWithSize:CGSizeMake(333, 130) textAlign:NSTextAlignmentLeft];
    c.dictEnum = @"3";
    
    silGrid.viewTitle = NSLocalizedString(@"Siluety", @"grid zaznamov");
    
    [silGrid setSiluetaGridData:siluets];
    silGrid.columnsCaptionsHeight = 0;
    silGrid.gridRowHeight = 130;
    silGrid.baseGridDelegate = self;
    silGrid.gridType = eGRDSILUETY;
    
    [silGrid setModalPresentationStyle:UIModalPresentationFormSheet];
    UINavigationController *ncPicker = [[UINavigationController alloc] initWithRootViewController:silGrid];
    ncPicker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [ncPicker setModalPresentationStyle:UIModalPresentationFormSheet];
    [self.navigationController presentViewController:ncPicker animated:YES completion:nil];
    ncPicker.preferredContentSize = CGSizeMake(1000, 564);
    ncPicker.view.superview.center = self.view.center;
 
    [self EnabledAllComponents:YES];
}

- (void)baseGridSelected:(VCBaseGrid *)Sender data:(id)data
{
    if(data == nil)
    {
        [Sender setSelectRow:nil];
        return;
    }

    NSMutableArray *a = [[NSMutableArray alloc] init];

    for(int i = 0; i < 5; i++)
    {
        NSDictionary *d = [data filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SILHOUETTE_TYPE_ID.intValue == %d", i+1]].lastObject;
        [a addObject: [UIImage imageWithData:[d objectForKey:@"IMAGE"]]];
    }
    [[DMSetting sharedDMSetting].vozidlo setValue:[data[0] objectForKey:@"SILHOUETTE_ID"] forKey:@"SILHOUETTE_ID"];
    [DMSetting sharedDMSetting].loadetSiluets = a;
    [mainImgView setImage:[DMSetting sharedDMSetting].loadetSiluets[scPicSelector.selectedSegmentIndex]];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self setStatusOdeslani:NO];
}
- (void)baseGridDisaper:(VCBaseGrid *)Sender
{
    
}

- (void) showMenu:(id)Sender{
   
	UIMenuController *menuController = [UIMenuController sharedMenuController];
    NSString *localizedStr = NSLocalizedString(@"Smazat foto", @"foto menu");
	UIMenuItem *deletePictureMenuItem = [[UIMenuItem alloc] initWithTitle:localizedStr action:@selector(deletePicture:)];
    localizedStr = NSLocalizedString(@"Nahled", @"foto menu");
    UIMenuItem *showPictureMenuItem = [[UIMenuItem alloc] initWithTitle:localizedStr action:@selector(showPicture:)];
    CGRect pos = [Sender frame];

	NSAssert([self becomeFirstResponder], @"Sorry, UIMenuController will not work with %@ since it cannot become first responder", self);
    
    CGPoint p = [self.view convertPoint:svImages.frame.origin fromView:svImages.superview];

	[menuController setMenuItems:[NSArray arrayWithObjects:showPictureMenuItem, deletePictureMenuItem, nil]];
    CGRect selectionRect = CGRectMake(pos.origin.x + (pos.size.width/2) , p.y, 0, 0);
    [menuController setTargetRect:selectionRect inView:self.view];
    [menuController setMenuVisible:YES animated:YES];
}
//---------------------------------------------------------------------------------------------------
- (void) showImg
{
    [myPopoverController dismissPopoverAnimated:YES];
    [self showPicture:self];
}
//---------------------------------------------------------------------------------------------------
-(void) deleteImg
{
    [myPopoverController dismissPopoverAnimated:YES];
    [self deletePicture:self];
}
//---------------------------------------------------------------------------------------------------
- (BOOL) canPerformAction:(SEL)selector withSender:(id) sender {
    if (selector == @selector(deletePicture:)
        || selector == @selector(showPicture:)) {
        return YES;
    }
    return NO;
}
//---------------------------------------------------------------------------------------------------
- (BOOL) canBecomeFirstResponder {
    return YES;
}
//---------------------------------------------------------------------------------------------------
- (void) SelectPicture:(id) Sender {
    [selectedPicture setSelected:NO];
    [self setSelectedPicture:Sender];
    [self showMenu:Sender];
}
//---------------------------------------------------------------------------------------------------
- (void)generateBTNPicture:(NSString *)newImgPath tag:(NSInteger)newtag{
    if(newImgPath.length == 0)
        return;
    NSString *PointButtonKey = @"";
    UIButton *newBtnImg = [UIButton buttonWithType:UIButtonTypeCustom];
    [newBtnImg setTag:newtag];
    [newBtnImg setTitle:PointButtonKey forState:UIControlStateNormal];
    [newBtnImg setTitle:PointButtonKey forState:UIControlStateSelected];
    [newBtnImg setFrame:[self getFrame]];
    newBtnImg.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    newBtnImg.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    UIImage *originalImage = [UIImage imageWithContentsOfFile:newImgPath];
    CGSize destinationSize = newBtnImg.frame.size;
    UIGraphicsBeginImageContext(destinationSize);
    [originalImage drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [newBtnImg setBackgroundColor:[UIColor colorWithPatternImage:newImage]];
    [newBtnImg addTarget:self action:@selector(SelectPicture: ) forControlEvents:UIControlEventTouchUpInside];
    
    [svImages insertSubview:newBtnImg atIndex:([[svImages subviews] count]-1)];
    if(selectedPicture != nil)
        [selectedPicture setSelected:NO];
    [self setSelectedPicture:newBtnImg];
    
//    [self setStatusOdeslani:NO];
    
}
//---------------------------------------------------------------------------------------------------
- (void) dragged: (UIControl *) c withEvent: (UIEvent *) ev {
//    [swipeLeft setEnabled:NO];
//    [swipeRight setEnabled:NO];
    CGFloat pointX, pointY;
    dragingPoint = YES;

    pointX = mainImgView.frame.origin.x + [ev.allTouches.anyObject locationInView:mainImgView].x;
    pointY = mainImgView.frame.origin.y + [ev.allTouches.anyObject locationInView:mainImgView].y;

    NSInteger rightBorder = mainImgView.frame.origin.x + mainImgView.frame.size.width;
    NSInteger downBorder = mainImgView.frame.origin.y + mainImgView.frame.size.height;
    pointX = (pointX > rightBorder)?rightBorder:pointX;
    pointX = (pointX < mainImgView.frame.origin.x)?mainImgView.frame.origin.x:pointX;
    pointY = (pointY < mainImgView.frame.origin.y)?mainImgView.frame.origin.y:pointY;
    pointY = (pointY > downBorder)?downBorder:pointY;
    c.center = CGPointMake(pointX, pointY);
    [self setStatusOdeslani:NO];
}
//---------------------------------------------------------------------------------------------------
- (void) reloadImages {
    CGRect f = CGRectMake(0.0, 0.0, 0.0, 0.0);
    NSInteger lastPos =0;
    NSPredicate *predicator = [NSPredicate predicateWithFormat:@"TRABANTINDEX.intValue == %d", scPicSelector.selectedSegmentIndex];
    NSArray *pics = [[DMSetting sharedDMSetting].takenImages filteredArrayUsingPredicate:predicator];
    
    for(NSInteger i=0; i < [pics count]; i++) {
        f = [[[svImages subviews] objectAtIndex:i] frame];
        if(i>0)
            lastPos = lastPos + (f.size.width + 10);
        f.origin.x = lastPos;
        [[[svImages subviews] objectAtIndex:i] setFrame:f];
        [[[svImages subviews] objectAtIndex:i] setTag:i];
        [pics[i] setValue:[NSNumber numberWithInt:i] forKey:@"IMGINDEX"];
    }
    [svImages setContentSize:CGSizeMake((lastPos + (f.size.width + 10)), f.size.height)];
}
//---------------------------------------------------------------------------------------------------
#pragma mark - photo menu methods
-(void)deletePicture:(id) Sender {
    NSPredicate *predicator = [NSPredicate predicateWithFormat:@"TRABANTINDEX.intValue == %d AND IMGINDEX.intValue == %d", scPicSelector.selectedSegmentIndex, selectedPicture.tag];
    NSArray *pics = [[DMSetting sharedDMSetting].takenImages filteredArrayUsingPredicate:predicator];
    [[DMSetting sharedDMSetting].takenImages removeObject:pics.lastObject];
    
    [selectedPicture removeFromSuperview];
    [self reloadImages];
    [self setStatusOdeslani:NO];
}
//---------------------------------------------------------------------------------------------------
-(void)showPicture:(id) Sender {
    UIViewController *photoPreview = [[UIViewController alloc] init];
    [photoPreview.view setFrame:CGRectMake(0.0, 0.0, 960.0, 720.0)];
    NSPredicate *predicator = [NSPredicate predicateWithFormat:@"TRABANTINDEX.intValue == %d AND IMGINDEX.intValue == %d", scPicSelector.selectedSegmentIndex, selectedPicture.tag];
    NSArray *pics = [[DMSetting sharedDMSetting].takenImages filteredArrayUsingPredicate:predicator];

    ivPhotos = [[UIImageView alloc] initWithFrame:photoPreview.view.frame];
    ivPhotos.contentMode = UIViewContentModeScaleAspectFill;
    ivPhotos.tag = selectedPicture.tag;
    [ivPhotos setImage:[UIImage imageWithContentsOfFile:[pics.lastObject valueForKey:@"FILEPATH"]]];

    [photoPreview.view addSubview:ivPhotos];
    
    UISwipeGestureRecognizer *photoSwipeLeft = [[UISwipeGestureRecognizer alloc] 
                                                initWithTarget:self
                                                action:@selector(handlePhotoSwipeLeft:)];
    photoSwipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [[photoPreview view] addGestureRecognizer:photoSwipeLeft];
    
    UISwipeGestureRecognizer *photoSwipeRight = [[UISwipeGestureRecognizer alloc] 
                                                 initWithTarget:self 
                                                 action:@selector(handlePhotoSwipeRight:)];
    photoSwipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [[photoPreview view] addGestureRecognizer:photoSwipeRight];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(handlePhotoSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    [[photoPreview view] addGestureRecognizer:singleTap];
    
    
    myPopoverController = [[UIPopoverController alloc] initWithContentViewController:photoPreview];
    myPopoverController.delegate = self;
    myPopoverController.popoverContentSize = CGRectMake(0, 0, 960.0, 720.0).size;
    [myPopoverController presentPopoverFromRect:CGRectMake(0, 0, 0.0, 0.0) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];    
}
//---------------------------------------------------------------------------------------------------
- (void)handlePhotoSwipeLeft:(id)Sender
{
    NSPredicate *predicator = [NSPredicate predicateWithFormat:@"TRABANTINDEX.intValue == %d AND IMGINDEX.intValue == %d", scPicSelector.selectedSegmentIndex, ++ivPhotos.tag];
    NSArray *pics = [[DMSetting sharedDMSetting].takenImages filteredArrayUsingPredicate:predicator];

    if(pics.count)
    {
        [ivPhotos setImage:[UIImage imageWithContentsOfFile:[pics.lastObject valueForKey:@"FILEPATH"]]];
        CATransition *transition = [CATransition animation];
        transition.duration = 0.5f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;        
        [ivPhotos.layer addAnimation:transition forKey:nil];

    }
    else
        [myPopoverController dismissPopoverAnimated:YES];
}
//---------------------------------------------------------------------------------------------------
- (void)handlePhotoSwipeRight:(id)Sender
{
    NSPredicate *predicator = [NSPredicate predicateWithFormat:@"TRABANTINDEX.intValue == %d AND IMGINDEX.intValue == %d", scPicSelector.selectedSegmentIndex, --ivPhotos.tag];
    NSArray *pics = [[DMSetting sharedDMSetting].takenImages filteredArrayUsingPredicate:predicator];
    
    if(pics.count)
    {
        [ivPhotos setImage:[UIImage imageWithContentsOfFile:[pics.lastObject valueForKey:@"FILEPATH"]]];
        CATransition *transition = [CATransition animation];
        transition.duration = 0.5f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;        
        [ivPhotos.layer addAnimation:transition forKey:nil];
    }
    else
        [myPopoverController dismissPopoverAnimated:YES];
}
//---------------------------------------------------------------------------------------------------
- (void)handlePhotoSingleTap:(id)Sender
{
    [myPopoverController dismissPopoverAnimated:YES];
}
#pragma mark -
//---------------------------------------------------------------------------------------------------
- (void)pointTapHandler:(id)Sender {
    CGRect btnRect = [Sender frame];
    CGRect imgRect = [mainImgView frame];
    CGPoint hit = [Sender center];
    NSString *title = [Sender titleLabel].text;
    NSInteger index;
    NSScanner *theScanner = [NSScanner scannerWithString:title];
    BOOL isNum = [theScanner scanInteger:&index];
    index--; //title cislujeme od 1
    
    if(CGRectContainsPoint(imgRect, hit))
    {
        if(title == nil) {
            NSString *PointButtonKey = @"I";
            [Sender setTitle:PointButtonKey forState:UIControlStateNormal];
            [Sender setTitle:PointButtonKey forState:UIControlStateSelected];
            mPoint *p = [[mPoint alloc] init];
            [p setPointButton:Sender];
            [points insertPoint:p picIndex:[scPicSelector selectedSegmentIndex]];

        } else if(!dragingPoint)/*if([swipeLeft isEnabled])*/ {
            [Sender removeFromSuperview];
            [points removePoint:index picIndex:[scPicSelector selectedSegmentIndex]];
        }
    } else {
        if(isNum && [points getPoint:index picIndex:[scPicSelector selectedSegmentIndex]] != nil) {
            [Sender removeFromSuperview];
            if(Sender == [[points selectedPoint] pointButton])
                [points setSelectedPoint:nil];
            [[[points getPoint:index picIndex:[scPicSelector selectedSegmentIndex]]imageView] removeFromSuperview];
            [points removePoint:index picIndex:[scPicSelector selectedSegmentIndex]];
        } else {
            btnRect.origin = CGPointMake(([Sender tag] == 1)?920:900, 520);
            [Sender setFrame:btnRect];
            [points setSelectedPoint:nil];
        }
    }
    dragingPoint = NO;
    [self setStatusOdeslani:NO];
//    [swipeLeft setEnabled:YES];
//    [swipeRight setEnabled:YES];
}
//---------------------------------------------------------------------------------------------------
- (IBAction)imgChange:(id)sender{
    [self changePicture:[sender selectedSegmentIndex]];
}
//---------------------------------------------------------------------------------------------------
- (void)generateNewBTNPicture:(NSDictionary *)ImgData
{

}
//---------------------------------------------------------------------------------------------------
- (void)changePicture:(enum picEnum)picIndex{
    [points removePointsFromPic];
    [points setSelectedPoint:nil];
    chbOderky.on = YES;
    NSArray *siluets = [DMSetting sharedDMSetting].loadetSiluets;
    for(NSInteger i=([[svImages subviews] count]-2); i >=0 ; i--)
        [svImages.subviews[i] removeFromSuperview];
    
    switch (picIndex) {
        case ePRAVASTRANA:
            [mainImgView setImage:siluets[ePRAVASTRANA]];
            break;
        case eLAVASTRANA:
            [mainImgView setImage:siluets[eLAVASTRANA]];
            break;
        case ePREDOK:
            [mainImgView setImage:siluets[ePREDOK]];
            break;
        case eZADOK:
            [mainImgView setImage:siluets[eZADOK]];
            break;
        case eSTRECHA:
            [mainImgView setImage:siluets[eSTRECHA]];
            break;
            
        default:
            break;
    }
    [scPicSelector setSelectedSegmentIndex:picIndex];
    
    [points addPointsToPic:picIndex view:[self.view viewWithTag:eBASEVIEW]];
    NSPredicate *predicator = [NSPredicate predicateWithFormat:@"TRABANTINDEX.intValue == %d", scPicSelector.selectedSegmentIndex];
    NSArray *pics = [[DMSetting sharedDMSetting].takenImages filteredArrayUsingPredicate:predicator];
    for(NSInteger i=0; i < pics.count; i++) {
        [self generateBTNPicture:[pics[i] valueForKey:@"FILEPATH"] tag:i];
    }
}
//---------------------------------------------------------------------------------------------------

#pragma mark - View lifecycle

//---------------------------------------------------------------------------------------------------
-(void)setPhotoAlbum
{
    if(_library == nil)
    {
        _library = [[ALAssetsLibrary alloc] init];
        [_library addAssetsGroupAlbumWithName:albumName
                                  resultBlock:^(ALAssetsGroup *group) {
                                  }
                                 failureBlock:^(NSError *error) {
                                     NSLog(@"error adding album");
                                 }];
        
        [_library enumerateGroupsWithTypes:ALAssetsGroupAlbum
                                usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                    if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:albumName]) {
                                        groupToAddTo = group;
                                    }
                                }
                              failureBlock:^(NSError* error) {
                                  NSLog(@"failed to enumerate albums:\nError: %@", [error localizedDescription]);
                              }];
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    albumName = @"PCHI";
    [self setPhotoAlbum];
    lblPohledy.text = NSLocalizedString(@"Pohledy", nil);
    lblExterier.text = NSLocalizedString(@"Exterier", nil);
    lblOderky.text = NSLocalizedString(@"Oderky", nil);
    [scPicSelector setTitle:NSLocalizedString(@"Levy bok", nil) forSegmentAtIndex:0];
    [scPicSelector setTitle:NSLocalizedString(@"Zadni cast", nil) forSegmentAtIndex:1];
    [scPicSelector setTitle:NSLocalizedString(@"Pravy bok", nil) forSegmentAtIndex:2];
    [scPicSelector setTitle:NSLocalizedString(@"Predni cast", nil) forSegmentAtIndex:3];
    [scPicSelector setTitle:NSLocalizedString(@"Strecha", nil) forSegmentAtIndex:4];
//    [btnSiluety setTitle:NSLocalizedString(@"Siluety", nil) forState:UIControlStateNormal];
    
    [btnSiluety setBackgroundImage:[UIImage imageNamed:@"SiluetaButton"] forState:UIControlStateNormal];
    [btnSiluety setBackgroundImage:[UIImage imageNamed:@"SiluetaButton"] forState:UIControlStateDisabled];
    [btnSiluety setBackgroundImage:[UIImage imageNamed:@"SiluetaButton_down"] forState:UIControlStateHighlighted];
    
    self.enableSave = YES;
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"alu_grid_texture_view.png"]]];
    cameraUI = [[UIImagePickerController alloc] init];
    imgBodDefault = [UIImage imageNamed:@"bod.png"];
    imgBodClicked = [UIImage imageNamed:@"bod_s.png"];
    imgBodSelected = [UIImage imageNamed:@"bod_s.png"];
    imgBodCrash = [UIImage imageNamed:@"stop.png"];
    imgBodCrash_s = [UIImage imageNamed:@"stop_s.png"];
    points = [DMSetting sharedDMSetting].points;//[DMPoints sharedDMPoints];
    points.imgSpona = imgSpona;
    [points setShowedPointsByPicIndex:eLAVASTRANA];


//    swipeLeft = [[UISwipeGestureRecognizer alloc] 
//                                           initWithTarget:self
//                                           action:@selector(handleSwipeLeft:)];
//    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
//    [[self view] addGestureRecognizer:swipeLeft];
    
//    swipeRight = [[UISwipeGestureRecognizer alloc] 
//                                            initWithTarget:self 
//                                            action:@selector(handleSwipeRight:)];
//    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
//    [[self view] addGestureRecognizer:swipeRight];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    [mainImgView setContentMode:UIViewContentModeScaleAspectFit];
    [mainImgView addGestureRecognizer:singleTap];
}
//---------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated{

//    [swipeLeft setEnabled:YES];
//    [swipeRight setEnabled:YES];
    [super viewWillAppear:animated];
    [self refreshData];
//    lblNavBar.text = ROOTNAVIGATOR.vozCaption;
}
//---------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated{

    scStavExterieru.selectedSegmentIndex = [[[DMSetting sharedDMSetting].vozidlo valueForKey:@"EXTERIOR_STATE"] integerValue]-1;
    UIImage *imgTrabant = [DMSetting sharedDMSetting].loadetSiluets[0];
    CGFloat imgCropWidth = imgTrabant.size.width / mainImgView.frame.size.width;
    CGFloat imgCropHeight = imgTrabant.size.height / mainImgView.frame.size.height;
    
    pomerHeigth = 1024.0/imgTrabant.size.height;
    pomerWidth = 1024.0/imgTrabant.size.width;
    points.pomerHeigth = pomerHeigth;
    points.pomerWidth = pomerWidth;
    points.imgCorpSize = CGSizeMake(imgCropWidth, imgCropHeight);
    points.imgRect = mainImgView.frame;

    [[DMSetting sharedDMSetting].points recomputePositionsWithOwner:self];

    [super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

}
//---------------------------------------------------------------------------------------------------
- (void)viewDidUnload
{
    mainImgView = nil;
    scPicSelector = nil;
    svImages = nil;
    chbOderky = nil;
    imgBodDefault = nil;
    imgBodClicked = nil;
    imgBodSelected = nil;
    imgBodCrash = nil;
    imgBodCrash_s = nil;
    ivPhotos = nil;
    showedPoints = nil;
    selectedPicture = nil;
    points = nil;

    swipeLeft = nil;
    swipeRight = nil;
    lpgr = nil;
    cameraUI = nil;
    myPopoverController = nil;
    lblPohledy = nil;
    lblExterier = nil;
    lblOderky = nil;
    lblUser = nil;
    btnSiluety = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
//---------------------------------------------------------------------------------------------------
- (void)deallocData {
//    [points removeAllData];
    [[DMSetting sharedDMSetting].takenImages removeAllObjects];
    for(NSInteger i=([[svImages subviews] count]-2); i >=0 ; i--)
        [[[svImages subviews] objectAtIndex:i] removeFromSuperview];
    selectedPicture = nil;
    [points setShowedPointsByPicIndex:scPicSelector.selectedSegmentIndex];
}
//---------------------------------------------------------------------------------------------------
- (void)loadBack:(id)Sender{
    switch (scPicSelector.selectedSegmentIndex) {
        case eLAVASTRANA:
            [self changePicture:eSTRECHA];
            break;
        case eZADOK:
            [self changePicture:eLAVASTRANA];
            break;
        case ePRAVASTRANA:
            [self changePicture:eZADOK];
            break;
        case ePREDOK:
            [self changePicture:ePRAVASTRANA];
            break;
        case eSTRECHA:
            [self changePicture:ePREDOK];
            break;
        default:
            break;
    }    
}
//---------------------------------------------------------------------------------------------------
-(void)sendPointsMessage
{
    
}
//---------------------------------------------------------------------------------------------------
- (void)sendData:(id)Sender{
    [self performSelector:@selector(sendPointsMessage) withObject:self];
}
//---------------------------------------------------------------------------------------------------
- (void)loadNext:(id)Sender{
    switch (scPicSelector.selectedSegmentIndex) {
        case eLAVASTRANA:
            [self changePicture:eZADOK];
            break;
        case eZADOK:
            [self changePicture:ePRAVASTRANA];
            break;
        case ePRAVASTRANA:
            [self changePicture:ePREDOK];
            break;
        case ePREDOK:
            [self changePicture:eSTRECHA];
            break;
        case eSTRECHA:
            [self changePicture:eLAVASTRANA];
            break;
        default:
            break;
    }
}
//---------------------------------------------------------------------------------------------------
- (void)handleSwipeLeft:(UISwipeGestureRecognizer *)recognizer{
    [self loadNext:self];
}
//---------------------------------------------------------------------------------------------------
- (void)handleSwipeRight:(UISwipeGestureRecognizer *)recognizer{
    [self loadBack:self];
}
//---------------------------------------------------------------------------------------------------
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer{
     UIButton *btn = [self generateBTNPoint:CGRectMake(tapedPos.x-20, tapedPos.y-20, 40, 40)];
    NSString *PointButtonKey = @"I";
    [btn setTitle:PointButtonKey forState:UIControlStateNormal];
    [btn setTitle:PointButtonKey forState:UIControlStateSelected];
    mPoint *p = [[mPoint alloc] init];
    [p setPointButton:btn];
    [points insertPoint:p picIndex:[scPicSelector selectedSegmentIndex]];
    [[self.view viewWithTag:eBASEVIEW] insertSubview:btn belowSubview:imgSpona];
    [self setStatusOdeslani:NO];
}
//---------------------------------------------------------------------------------------------------
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    tapedPos = [touch locationInView:[self.view viewWithTag:eBASEVIEW]];
}
//---------------------------------------------------------------------------------------------------
#pragma mark - camera methods

- (IBAction)showCameraUI:(id)Sender{
    [self EnabledAllComponents:NO];
    [self startCameraControllerFromViewController:self usingDelegate:self];
}
//---------------------------------------------------------------------------------------------------
- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,                                                   
                                                   UINavigationControllerDelegate>) delegate {
            
    if (([UIImagePickerController isSourceTypeAvailable:          
          UIImagePickerControllerSourceTypeCamera] == NO)        
        || (delegate == nil)        
        || (controller == nil))        
        return NO;
                    
//    cameraUI = [[UIImagePickerController alloc] init];    
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
            
    // Displays a control that allows the user to choose picture or    
    // movie capture, if both are available:    
    cameraUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
//    [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
            
    // Hides the controls for moving & scaling pictures, or for    
    // trimming movies. To instead show the controls, use YES.    
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = delegate;
    
    [controller presentViewController:cameraUI animated:YES completion:nil];
    return YES;
    
}
//---------------------------------------------------------------------------------------------------

//@implementation CameraViewController (CameraDelegateMethods)
// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self EnabledAllComponents:YES];
}
//---------------------------------------------------------------------------------------------------

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
            
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];    
    UIImage *originalImage, *editedImage, *imageToSave;
    
        
    // Handle a still image capture    
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
                        
        editedImage = (UIImage *) [info objectForKey:                                   
                                   UIImagePickerControllerEditedImage];        
        originalImage = (UIImage *) [info objectForKey:                                     
                                     UIImagePickerControllerOriginalImage];                        
        
        if (editedImage) {            
            imageToSave = editedImage;            
        } else {            
            imageToSave = originalImage;            
        }
                        
        // Save the new image (original or edited) to the Camera Roll        
//        UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
/*        if([points selectedPoint] != nil){
            [[[points selectedPoint] imageView] setImage:imageToSave];
            [[[points selectedPoint] imageView] setTag:1];
        }*/

        imageToSave = [imageToSave fixOrientation];
        CGImageRef img = [imageToSave CGImage];
        [[self library] writeImageToSavedPhotosAlbum:img
                                     metadata:[info objectForKey:UIImagePickerControllerMediaMetadata]
                              completionBlock:^(NSURL* assetURL, NSError* error) {
                                  if (error.code == 0) {
//                                      NSLog(@"saved image completed:\nurl: %@", assetURL);
                                      
                                      // try to get the asset
                                      [[self library] assetForURL:assetURL
                                                    resultBlock:^(ALAsset *asset) {
                                                        // assign the photo to the album
                                                        [groupToAddTo addAsset:asset];
//                                                        NSLog(@"Added %@ to %@", [[asset defaultRepresentation] filename], albumName);
                                                    }
                                                   failureBlock:^(NSError* error) {
                                                       NSLog(@"failed to retrieve image asset:\nError: %@ ", [error localizedDescription]);
                                                   }];
                                  }
                                  else {
                                      NSLog(@"saved image failed.\nerror code %i\n%@", error.code, [error localizedDescription]);
                                  }
                              }];

//        [[webServices sharedwebServices] setSendStatusForMessage:eSENDPICTURE status:NO];
//        UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
        
        NSPredicate *predicator = [NSPredicate predicateWithFormat:@"TRABANTINDEX.intValue == %d", scPicSelector.selectedSegmentIndex];
        NSArray *pics = [[DMSetting sharedDMSetting].takenImages filteredArrayUsingPredicate:predicator];
        NSNumber *trabantIndex = [NSNumber numberWithInteger:scPicSelector.selectedSegmentIndex];
        NSNumber *imgIndex = [NSNumber numberWithInteger:pics.count];
        
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *imageSubdirectory = [documentsDirectory stringByAppendingPathComponent:@"CheckinImages"];
        NSString *imageName = [NSString stringWithFormat:@"%d_%d.jpg", trabantIndex.integerValue, imgIndex.integerValue];
        
        NSFileManager *fileMgr = [[NSFileManager alloc] init];
        if (![fileMgr fileExistsAtPath:imageSubdirectory]) {
            NSError *error = nil;
            [fileMgr createDirectoryAtPath:imageSubdirectory withIntermediateDirectories:YES attributes:nil error:&error];
            if(error != nil)
                NSLog(@"%@", [error description]);
        }
        
        NSString *filePath = [imageSubdirectory stringByAppendingPathComponent:imageName];
        
        // Convert UIImage object into NSData (a wrapper for a stream of bytes) formatted according to PNG spec
        CGFloat resolution = [Config getImageResolution];
        NSData *imageData = UIImageJPEGRepresentation(imageToSave, resolution);
        BOOL done = [imageData writeToFile:filePath atomically:YES];
        if(done == 0)
            NSLog(@"Nepodarilo sa ulozit obrazok %@", filePath);
    
        
        NSDictionary *imgData = [NSMutableDictionary dictionaryWithObjects:@[trabantIndex, imgIndex, filePath] forKeys:@[@"TRABANTINDEX",@"IMGINDEX",@"FILEPATH"]];
        [[DMSetting sharedDMSetting].takenImages addObject:imgData];
        
//        [self generateBTNPicture:imageToSave tag:pics.count];
//        CGImageRelease(img);
        
    }
            
    // Handle a movie capture
/*
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo) {
                        
        NSString *moviePath = [[info objectForKey:                                
                                UIImagePickerControllerMediaURL] path];
                        
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {            
            UISaveVideoAtPathToSavedPhotosAlbum (                                                 
                                                 moviePath, nil, nil, nil);            
        }        
    }
  */  
    [self setStatusOdeslani:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self EnabledAllComponents:YES];
}
//---------------------------------------------------------------------------------------------------

@end
