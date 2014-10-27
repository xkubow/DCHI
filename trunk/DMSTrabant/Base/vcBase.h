//
//  vcBase.h
//  Direct checkin
//
//  Created by Jan Kubis on 09.10.12.
//  Copyright (c) 2012 jan.kubis@t-systems.cz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "vcMenu.h"
#import "vcPoznamka.h"
//#import "Rezident.h"

typedef enum {eBASEVIEW=111, eSPONA=112} viewEnums;


@interface vcBase : UIViewController {
    __strong IBOutlet UIBarButtonItem *btnNavleft;
    __strong IBOutlet UIBarButtonItem *btnNavright;
    __strong IBOutlet UIBarButtonItem *btnNavBarSave;
    
    UIView *vMain;
    UIButton *btnPoz;
    UIButton *btnHlav;
    vcMenu *menu;
    vcPoznamka *vPoznamka;
    NSCharacterSet *intSetting;
}

@property (nonatomic, assign) BOOL enableSave;
@property (nonatomic, retain)UIButton *btnSaveInfo;
@property (nonatomic, retain)UILabel *lblNavBar;

- (void) EnabledAllComponents:(BOOL)newEnable;
- (NSString *)parseXML;
- (void) setStatusOdeslani:(BOOL)odeslani;
- (BOOL) statusOdeslani;
- (void) refreshData;
-(void)showProtocol;
@end
