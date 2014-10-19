//
//  TrabantViewController.h
//  DMSTrabant
//
//  Created by Jan Kubis on 1/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "vcTrabantPictures.h"
#import "vcPicker.h"
#import "vcBase.h"

@class VcSplitView;
@class VcMaster;
@class VcDetail;

enum {
    eOJETYVUZ = 1 << 0,
    eNOVYVUZ = 1 << 1,
};

enum {
    eNEPLATICZAK = 1 << 0,
    ePRAVIDELNYZAK = 1 << 1,    
    eKUPECVOZUZAK = 1 << 2,
    eVIPZAK = 1 << 3,
    eFLEETZAK = 1 << 4
};

@interface vcTrabantInfo : vcBase <PickerDelegate, UITextFieldDelegate, UIPopoverControllerDelegate, UITextViewDelegate> {
//    __weak IBOutlet UITextField *txtPalivoDruh;
    NSString *txtPalivoDruh;
    __weak IBOutlet UITextField *txtRZV;
    __weak IBOutlet UITextField *txtKmStav;
    __weak IBOutlet UISegmentedControl *scStavNadrze;
    __weak IBOutlet UISegmentedControl *scStavInterieru;
    __weak IBOutlet UITextField *txtZakaznik;
    __weak IBOutlet UITextField *txtVozPristavil;
    __weak IBOutlet UISwitch *chkPoistPrip_prp;
    __weak IBOutlet UIButton *btnGetRZVPlanVoz;
    __weak IBOutlet UITextField *txtSTK;
    __weak IBOutlet UITextField *txtEmise;
    __weak IBOutlet UIButton *btnSTK;
    __weak IBOutlet UIButton *btnEmise;
    __weak IBOutlet UIButton *btnVyrobekVoz;
    __weak IBOutlet UITextField *txtProdej_dat;
    __weak IBOutlet UITextField *txtRokVyroby;
    __weak IBOutlet UIButton *btnVozTyp;
    __weak IBOutlet UITableViewCell *tvcRow;
    __weak IBOutlet UILabel *odoslaniStatus;
    __weak IBOutlet UITextField *txtScenar;
    __weak IBOutlet UIButton *btnScenar;
    __weak IBOutlet UISwitch *chkOTP_prp;
    __weak IBOutlet UISwitch *chkServisKniz_prp;
    __weak IBOutlet UILabel *lblUser;
    __weak IBOutlet UITextField *txtVIN;
    __weak IBOutlet UISegmentedControl *scStavOleje;
    IBOutletCollection(UILabel) NSArray *lblVozidlo;

//    vcTablePicker *vcPlanVoz;
    NSArray *planVozArrays, *planVozSeaking;
    NSMutableArray *loadedData;
    NSMutableDictionary *row;
    NSDictionary *vozIcons;
    UIPopoverController *myPopoverController;
    
    CGFloat tableViewsRowNum;
//    NSString *karoseria_nr, *vozidloPopis, *zakazkaDruh;
//    NSInteger oZakazka_id, vozidlo_id, vozidloKon_id, zakazkaNr, zakaznik_id, zakaznikkon_id;
    NSInteger insertResult, imgsCount;
    NSString *insertResultMessage;
    NSDateFormatter *dateFormatter;
//    NSInteger vozCount;

}

@property (assign, nonatomic)BOOL showPlanVoz;

- (NSString *) getScenarString;
- (void) clearAllData:(id)Sender;
- (void) setDefaultData;


@end
