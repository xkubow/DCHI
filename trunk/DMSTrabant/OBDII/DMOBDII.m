//
//  DMOBDII.m
//  DirectCheckin
//
//  Created by Jan Kubis on 5/9/13.
//
//

#import "DMOBDII.h"
@interface NSString (NSStringHexToBytes)
-(NSData*) hexToBytes ;
@end



@implementation NSString (NSStringHexToBytes)
-(NSData*) hexToBytes {
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= self.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [self substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}
@end



@implementation DMOBDII



+ (NSString *) decodeMultyFrameInData:(NSMutableDictionary *)data
{
    NSString *theVinData = //@"7E8 10 14 49 02 01 54 4D 42 \n7E8 21 42 4D 36 31 5A 35 42 \n7E8 22 32 30 38 36 31 36 36";
                            [data objectForKey:@"RESPONSE"];
    NSMutableString *theResult = [[NSMutableString alloc] init];
    NSUInteger len = theVinData.length;
    NSUInteger paraStart = 0, paraEnd =0, contentsEnd =0;
    NSRange curentRange;
    
    while (paraEnd < len) {
        [theVinData getParagraphStart:&paraStart end:&paraEnd contentsEnd:&contentsEnd forRange:NSMakeRange(paraEnd, 0)];
        curentRange = NSMakeRange(paraStart, contentsEnd-paraStart);
        NSString *str = [theVinData substringWithRange:curentRange];
        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSMutableArray *frameData = [str componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].mutableCopy;
        [frameData removeObjectAtIndex:0];
        
        if([frameData[0] hasPrefix:@"1"])
            [frameData removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 5)]];
        else if ([frameData[0] hasPrefix:@"2"])
            [frameData removeObjectAtIndex:0];
        else if ([frameData[0] hasPrefix:@"0"])
            [frameData removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]];
        
        if([[data valueForKey:@"DECODE"] integerValue] == 2)
            for(NSString *hexStr in frameData)
            {
                int value = 0;
                sscanf([hexStr cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
                [theResult appendFormat:@"%c", (char)value];
            }
        else if([[data valueForKey:@"DECODE"] integerValue] == 1 && frameData.count)
        {
            NSString *hexStr = [frameData componentsJoinedByString:@""];
            [theResult appendFormat:@"%@, ", [self decodeOBDIIErrorInCode:hexStr] ];
        }
    }
    
    if(data != nil)
       [data setValue:theResult forKey:@"RESPONSE"];
    return theResult;
}

+ (NSString *) decodeOBDIIErrorInCode:(NSString *)hexStr
{
    NSMutableString *errorCode = [[NSMutableString alloc] init];
    union cosi chybCode;
    NSString *strCorrected = [hexStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    strCorrected = [strCorrected stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSData *data = [strCorrected hexToBytes];//[@"5448" hexToBytes];
    chybCode.hodnota = *(UInt16 *)[data bytes]; //18516
    
    char *system = "PCBU";
    char typOne[2];
    typOne[0] = *(system+chybCode.system);
    typOne[1] = 0;
    [errorCode appendString:[NSString stringWithUTF8String:typOne]];
    [errorCode appendString:[NSString stringWithFormat:@"%d", chybCode.type]];
    [errorCode appendString:[NSString stringWithFormat:@"%d", chybCode.subsystem]];
    [errorCode appendString:[NSString stringWithFormat:@"%d", chybCode.subsystem1]];
    [errorCode appendString:[NSString stringWithFormat:@"%d", chybCode.subsystem2]];
    
    return errorCode;
}


@end
