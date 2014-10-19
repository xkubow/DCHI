//
//  OBDIICom.m
//  DirectCheckin
//
//  Created by Jan Kubis on 09.05.13.
//
//

#import "OBDIICom.h"
#import "DMOBDII.h"
#import "DMSetting.h"
#import "DejalActivityView.h"
#import "TrabantAppDelegate.h"
#import "Config.h"

#define TRABANT_APP_DELEGATE ((TrabantAppDelegate*)[[UIApplication sharedApplication] delegate])

@interface OBDIICom()
{
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    NSInteger sendingDataIndex;
    NSMutableData *_recivedData;
    BOOL readyToSend, recivedResponse;
}

@end

@implementation OBDIICom
@synthesize data=_data;

+ (OBDIICom *)sharedOBDIICom
{
    static OBDIICom *me = nil;
    if(!me)
        me = [[OBDIICom alloc] init];
    return me;
}

- (OBDIICom*)init
{
    if(self)
    {
        readyToSend = NO;
        recivedResponse = NO;
    }
    return self;
}

- (NSMutableArray *)data
{
    if(!_data)
        _data = [[NSMutableArray alloc] init];
    return _data;
}

- (BOOL) createConnection
{
    BOOL connected = NO;
    recivedResponse = YES;
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    NSString *strUrl = [[Config retrieveFromUserDefaults:@"OBDII_url"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *urlData = [strUrl componentsSeparatedByString:@":"];
//    NSURL *url = [NSURL URLWithString:strUrl];
//    NSLog(@"%@, %@", urlData[0], urlData[1]);
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)urlData[0], [urlData[1] integerValue], &readStream, &writeStream);
    
    inputStream = (__bridge_transfer NSInputStream *)readStream;
    outputStream = (__bridge_transfer NSOutputStream *)writeStream;
    
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    sendingDataIndex = 0;
    [self.data removeAllObjects];
    [self.data insertObject:[@{@"TYPE":@"WARMSTART", @"MESSAGE":@"ATWS"} mutableCopy] atIndex:0];
    [self.data insertObject:[@{@"TYPE":@"RESET", @"MESSAGE":@"ATZ"} mutableCopy] atIndex:1];
    [self.data insertObject:[@{@"TYPE":@"ECHOOFF", @"MESSAGE":@"ATE0"} mutableCopy] atIndex:2];
    [self.data insertObject:[@{@"TYPE":@"HEADERSON", @"MESSAGE":@"ATH1"} mutableCopy] atIndex:3];
    [self.data insertObject:[@{@"TYPE":@"VERSION", @"MESSAGE":@"ATI", @"SHOW":@1} mutableCopy] atIndex:4];
    [self.data insertObject:[@{@"TYPE":@"DESCRIPTION", @"MESSAGE":@"AT@1", @"SHOW":@1} mutableCopy] atIndex:5];
    [self.data insertObject:[@{@"TYPE":@"IDENTIFIER", @"MESSAGE":@"AT@2", @"SHOW":@1} mutableCopy] atIndex:6];
    [self.data insertObject:[@{@"TYPE":@"VOLTAGE", @"MESSAGE":@"ATRV", @"SHOW":@1} mutableCopy] atIndex:7];
    [self.data insertObject:[@{@"TYPE":@"SETPROTOCOL", @"MESSAGE":@"ATSP0"} mutableCopy] atIndex:8];
    [self.data insertObject:[@{@"TYPE":@"SUPORTEDPIDS0", @"MESSAGE":@"0100"} mutableCopy] atIndex:9];
    [self.data insertObject:[@{@"TYPE":@"PROTOCOL", @"MESSAGE":@"ATDP", @"SHOW":@1} mutableCopy] atIndex:10];
    [self.data insertObject:[@{@"TYPE":@"SUPORTEDPIDS1", @"MESSAGE":@"0120"} mutableCopy] atIndex:11];
    [self.data insertObject:[@{@"TYPE":@"SUPORTEDPIDS2", @"MESSAGE":@"0140"} mutableCopy] atIndex:12];
    [self.data insertObject:[@{@"TYPE":@"MONITORDTC", @"MESSAGE":@"0101", @"SHOW":@1} mutableCopy] atIndex:13];
    [self.data insertObject:[@{@"TYPE":@"VIN", @"MESSAGE":@"0902", @"DECODE":@2, @"SHOW":@1} mutableCopy] atIndex:14];
    [self.data insertObject:[@{@"TYPE":@"FUELTYP", @"MESSAGE":@"0151", @"SHOW":@1} mutableCopy] atIndex:15];
    [self.data insertObject:[@{@"TYPE":@"FREEZDTC", @"MESSAGE":@"0102", @"SHOW":@1} mutableCopy] atIndex:16];
    [self.data insertObject:[@{@"TYPE":@"STOREDDTC", @"MESSAGE":@"03", @"DECODE":@1, @"SHOW":@1} mutableCopy] atIndex:17];
    [self.data insertObject:[@{@"TYPE":@"PENDINGDTC", @"MESSAGE":@"07", @"DECODE":@1, @"SHOW":@1} mutableCopy] atIndex:18];
    [self.data insertObject:[@{@"TYPE":@"VEHICLEINFO", @"MESSAGE":@"09", @"SHOW":@1} mutableCopy] atIndex:19];
    [self.data insertObject:[@{@"TYPE":@"PERMANENTDTC", @"MESSAGE":@"0A", @"DECODE":@1, @"SHOW":@1} mutableCopy] atIndex:20];
    
    [inputStream open];
    [outputStream open];
    
    [self performSelector:@selector(connectionDidntSuces) withObject:nil afterDelay:2];
    
    if ([inputStream streamStatus] == NSStreamStatusError || [outputStream streamStatus] == NSStreamStatusError)
    {
        NSLog(@"%@, %@", [inputStream streamError].localizedFailureReason, [outputStream streamError].localizedFailureReason);
        connected = NO;
    }
    else
        connected = YES;
    
    return connected;
}

- (void)connectionDidntSuces
{
    [[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"Nenalezena OBDII hlava", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil] show ];
    [self disconnect];
}

- (void) disconnect
{
    [outputStream close];
    [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    outputStream = nil;
    [inputStream close];
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    inputStream = nil;
    [DejalBezelActivityView removeViewAnimated:YES];
}

- (void) sendMessage
{
    if(!readyToSend || !recivedResponse)
        return;
    
    recivedResponse = NO;
    readyToSend = NO;
    if(_data.count == sendingDataIndex)
    {
        [self disconnect];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dataRespondNotification" object:@"LoadedOBDIIData"];
        return;
    }
    NSString *msg = [[_data[sendingDataIndex] objectForKey:@"MESSAGE"] stringByAppendingString:@"\r"];
    NSData *msgData = [msg dataUsingEncoding:NSUTF8StringEncoding];
    NSInteger len = msgData.length;
    
    NSLog(@">>> sending <<< \n%d, %@", sendingDataIndex, [_data[sendingDataIndex] objectForKey:@"MESSAGE"]);
    
    sendingDataIndex++;
    [outputStream write:[msgData bytes] maxLength:len];
}

- (void) stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    NSError *error = nil;
    switch (eventCode) {
        case NSStreamEventNone:
            NSLog(@"Connection to OBDII couldn't be established");
            [self disconnect];
            break;
        case NSStreamEventOpenCompleted:
            NSLog(@"Connection to OBDII created");
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            break;
        case NSStreamEventHasBytesAvailable:
            if (aStream == inputStream)
			{
                //read data
				uint8_t buffer[1024];
				int len;
				while ([inputStream hasBytesAvailable])
				{
					len = [inputStream read:buffer maxLength:sizeof(buffer)];
					if (len > 0)
					{
                        if(_recivedData == nil)
                            _recivedData = [[NSMutableData alloc] init];
                        [_recivedData appendBytes:buffer length:len];
					}
				}
                NSMutableString *output = [[NSMutableString alloc] initWithData:_recivedData encoding:NSUTF8StringEncoding];
                if([output rangeOfString:@">"].location != NSNotFound)
                {
                    NSMutableDictionary *md = _data[sendingDataIndex-1];
                    [output deleteCharactersInRange:NSMakeRange(output.length-1, 1)];
                    [output setString:[output stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                    if([output hasPrefix:@"SEARCHING..."])
                        [output replaceOccurrencesOfString:@"SEARCHING...\n" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, 13)];
                    recivedResponse = YES;
                    [md setObject:output forKey:@"RESPONSE"];
                    if(existInDic(md, @"DECODE") && ![output isEqualToString:@"NO DATA"])
                    {
                        NSLog(@"decoding :%@", output);
                        [DMOBDII decodeMultyFrameInData:md];
                    }
                    
                    output = [md valueForKey:@"RESPONSE"];
                    NSLog(@"<<< decodet : >>>\n%@\n", output);
                    [_recivedData setLength:0];
                    [self sendMessage];
                }
			}
            break;
        case NSStreamEventHasSpaceAvailable:
            readyToSend = YES;
            [self sendMessage];
            break;
        case NSStreamEventErrorOccurred:
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            error = [aStream streamError];
            NSLog(@"stream error: %@, %@,\n%@,\n%@", aStream.description, aStream.debugDescription, error.localizedDescription, error.localizedFailureReason );
            [[[UIAlertView alloc] initWithTitle:@"" message:error.localizedFailureReason delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil] show ];
            [self disconnect];
            break;
        case NSStreamEventEndEncountered:
            NSLog(@"Connection to OBDII closed");
            [self disconnect];
            break;
            
        default:
            break;
    }
}

@end
