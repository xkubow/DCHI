//
//  tvcNDPacketInfo.h
//  DirectCheckin
//
//  Created by Jan Kubis on 06.08.14.
//
//

#import <UIKit/UIKit.h>

@interface tvcNDPacketInfo : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *Nazev;
@property (weak, nonatomic) IBOutlet UILabel *ItemNumber;
@property (weak, nonatomic) IBOutlet UILabel *CisloND;
@property (weak, nonatomic) IBOutlet UILabel *Mnozstvi;
@property (weak, nonatomic) IBOutlet UILabel *Cena;
@property (weak, nonatomic) IBOutlet UILabel *Stav;
@property (weak, nonatomic) IBOutlet UIImageView *Image;

@end
