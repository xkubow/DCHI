//
//  tvcPPPacketInfo.h
//  DirectCheckin
//
//  Created by Jan Kubis on 05.08.14.
//
//

#import <UIKit/UIKit.h>

@interface tvcPPPacketInfo : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *Nazev;
@property (weak, nonatomic) IBOutlet UILabel *CisloPP;
@property (weak, nonatomic) IBOutlet UILabel *CJ;
@property (weak, nonatomic) IBOutlet UILabel *LJ;
@property (weak, nonatomic) IBOutlet UILabel *PC;
@property (weak, nonatomic) IBOutlet UILabel *PCDPH;
@property (weak, nonatomic) IBOutlet UILabel *ZM;
@property (weak, nonatomic) IBOutlet UIImageView *Image;
@end
