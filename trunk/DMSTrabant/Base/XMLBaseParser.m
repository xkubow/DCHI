//
//  XMLBaseParser.m
//  DirectCheckin
//
//  Created by Jan Kubis on 19.02.13.
//
//

#import "XMLBaseParser.h"

@interface MyParser()


@end

@implementation MyParser
@synthesize action=_action;
@synthesize listArray=_listArray;
@synthesize item=_item;
@synthesize itemArray=_itemArray;
@synthesize parsListElement=_parsListElement;
@synthesize elementChars=_elementChars;

- (MyParser*)initWithData:(NSData*) data
{
    self = [super initWithData:data];
    if(self)
    {
        _listArray = [[NSMutableDictionary alloc] init];
        _itemArray = [[NSMutableArray alloc] init];
        _item = [[NSMutableDictionary alloc] init];
        _parsListElement = [[NSMutableArray alloc] init];
        _elementChars = [[NSMutableString alloc] init];
    }
    return self;
}

@end

@interface XMLBaseParser()<NSXMLParserDelegate>
{
//    NSMutableString *elementCharacters;
//    NSMutableArray *xmlBeginElement;
//    NSMutableDictionary *dataList;
    NSOperationQueue *queue;
    BOOL didEnd;
}

@end

@implementation XMLBaseParser


- (XMLBaseParser *)init
{
    self = [super init];
    
    if(self)
    {
//        elementCharacters = [[NSMutableString alloc] init];
        queue = [[NSOperationQueue new] init];
//        xmlBeginElement = [[NSMutableArray alloc] init];
//        dataList = [[NSMutableDictionary alloc] init];
//        [queue addObserver:self forKeyPath:@"operations" options:0 context:NULL];
    }
    return self;
}

- (void) addParsingToQueueWithXml:(NSString*)XMLString action:(NSString*)action
{
    NSInvocationOperation *operation= [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(doParsing:)
                                                                             object:@[action, XMLString]];
    [queue addOperation:operation];
}

- (void) doParsing:(NSArray*)parsingData
{
    NSData *data = [parsingData[1] dataUsingEncoding:NSUTF8StringEncoding];
    MyParser *xmlParser = [[MyParser alloc] initWithData: data];
    xmlParser.action = parsingData[0];
    xmlParser.shouldProcessNamespaces = YES;
    xmlParser.shouldResolveExternalEntities = YES;
    [xmlParser setDelegate: self];
    [xmlParser setShouldResolveExternalEntities: NO];
    [xmlParser parse];
    
    if(xmlParser.parserError)
        NSLog(@"xml parser error :%@, %@", xmlParser.parserError.localizedFailureReason, xmlParser.parserError.localizedDescription);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == queue && [keyPath isEqualToString:@"operations"]) {
        if ([queue.operations count] == 0) {
            NSLog(@"queue has completed");
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object
                               change:change context:context];
    }
}

#pragma mark -
#pragma mark parser methods
-(void)parser:(MyParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *)qName
   attributes: (NSDictionary *)attributeDict
{
    [parser.elementChars setString:@""];
    if([elementName.uppercaseString rangeOfString:@"LIST"].location != NSNotFound)
    {
        if(!parser.parsListElement.count)
            [parser.listArray setValue:[[NSMutableArray alloc] init] forKey:elementName];
        else
        {
            NSMutableDictionary *dataArray = [parser.listArray valueForKeyPath:[parser.parsListElement componentsJoinedByString:@"."]];
            [dataArray setValue:[[NSMutableArray alloc] init] forKey:elementName];
        }
       [parser.parsListElement addObject:elementName];
    }
    else if([elementName.uppercaseString rangeOfString:@"ITEM"].location != NSNotFound)
    {
        NSMutableArray *dataArray = [parser.listArray valueForKeyPath:[parser.parsListElement componentsJoinedByString:@"."]];
        [dataArray addObject:[[NSMutableDictionary alloc] init]];
    }
}

-(void)parser:(MyParser *)parser foundCharacters:(NSString *)string
{
    [parser.elementChars appendString:string];
}

-(void)parser:(MyParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSMutableDictionary *dataArray;
    if(parser.parsListElement.count)
        dataArray = [[parser.listArray valueForKeyPath:[parser.parsListElement componentsJoinedByString:@"."]] lastObject];
    else
        dataArray = parser.listArray;

    if([elementName.uppercaseString rangeOfString:@"LIST"].location != NSNotFound)
        [parser.parsListElement removeLastObject];
    else if(parser.elementChars.length)
        [dataArray setValue:parser.elementChars.copy forKey:elementName];
    [parser.elementChars setString:@""];
}

- (void)parserDidEndDocument:(MyParser *)parser
{
    NSLog(@"### PED ### XMLBaseParser.parserDidEndDocument");
}

- (void)parser:(MyParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"parser:parseErrorOccurred:%@, %@", parseError.localizedFailureReason, parseError.localizedDescription);
}

- (void)parser:(MyParser *)parser validationErrorOccurred:(NSError *)validError
{
    NSLog(@"parser:validationErrorOccurred:%@, %@", validError.localizedFailureReason, validError.localizedDescription);
}

@end
