//
//  XMLBaseParser.h
//  DirectCheckin
//
//  Created by Jan Kubis on 19.02.13.
//
//

#import <Foundation/Foundation.h>

@interface MyParser : NSXMLParser

@property (nonatomic, retain) NSString *action;
@property (nonatomic, retain) NSMutableString *elementChars;
@property (nonatomic, retain) NSMutableArray *itemArray;
@property (nonatomic, retain) NSMutableArray *parsListElement;
@property (nonatomic, retain) NSMutableDictionary*listArray;
@property (nonatomic, retain) NSMutableDictionary *item;

@end

@interface XMLBaseParser : NSObject

- (void) addParsingToQueueWithXml:(NSString*)XMLString action:(NSString*)action;
@end


