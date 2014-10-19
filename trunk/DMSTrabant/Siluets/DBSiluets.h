//
//  Siluets.h
//  DirectCheckin
//
//  Created by Jan Kubis on 07.03.13.
//
//

#import <Foundation/Foundation.h>
#import "BaseDBManager.h"


@interface DBSiluets : NSObject
{
    
}

-(NSArray *)loadSiluetsWithVyrVoz:(NSString*)vyrobekVoz typKod:(NSString*)typKod;
-(NSArray *)loadSiluetsWithVyrVoz:(NSString*)vyrobekVoz;
-(void)reloadImgaes;
-(void)insertImgWithSiluetaId:(NSInteger)siluetaId siluetsTypId:(NSInteger)siluetsTypId image:(NSData*)image;
-(void)parseSiluets;
-(NSArray *)loadImagesWithSiluetaId:(NSString*)SiluetaId;
@end
