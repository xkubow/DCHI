//
//  vcLogin.h
//  DMSTrabant
//
//  Created by Jan Kubis on 1/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "webServices.h"


@protocol LoginDelegate;

@interface vcLogin : UIViewController {
    __weak IBOutlet UITextField *txtMeno;
    __weak IBOutlet UITextField *txtHeslo;
    __weak IBOutlet UIButton *btnLogin;
    __weak IBOutlet UITextField *txtURL;
    __weak IBOutlet UITextField *txtCertHost;
    __weak IBOutlet UITextField *txtUUID;
    __weak IBOutlet UILabel *lblMeno;
    __weak IBOutlet UIButton *btnDeleteCert;
    __weak IBOutlet UIButton *btnOK;
}

@property(nonatomic,assign)    id<LoginDelegate>    loginDelegate;

- (void)showSetWebServiceURL;
- (void)setTxtUrl:(NSString *)newUrl;

@end

@protocol LoginDelegate <NSObject>

- (void)loginSuces:(vcLogin *)Sender;
@optional
- (void)loginDidDisaper:(vcLogin *)Sender;

@end