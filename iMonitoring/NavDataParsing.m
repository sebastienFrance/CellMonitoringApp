//
//  NavDataParsing.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 02/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NavDataParsing.h"

@interface NavDataParsing ()

@property (nonatomic) NSMutableArray* navCells;

@end


@implementation NavDataParsing

#pragma mark - Interface
+ (NSArray*)  parseNavigationData:(NSURL*) url {
    NSXMLParser *XMLParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    if (XMLParser == Nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Navigation data" message:@"Initialization error" delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
        return Nil;
    }
    
    
    NavDataParsing *xmlDelegate = [NavDataParsing alloc];
    [XMLParser setDelegate:xmlDelegate];
    [XMLParser setShouldResolveExternalEntities:NO];
    Boolean success = [XMLParser parse];
    if (success == FALSE) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Navigation data" message:@"Parsing error" delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
        return Nil;
    }
    
    return xmlDelegate.navCells;
}



#pragma mark - Parser implementation

- (void)parserDidStartDocument:(NSXMLParser *)parser {
}
// sent when the parser begins parsing of the document.
- (void)parserDidEndDocument:(NSXMLParser *)parser {
}

// <?xml version=\"1.0\"?>
// <NavData>
// <Cell id="123346_3"/>
// <Cell id="123346_3"/>
// </NavData>


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    const static NSString* navDataLabel = @"NavData";
    const static NSString* cellLabel = @"Cell";
    const static NSString* idLabel = @"id";
    const static NSString* latitudeLabel = @"latitude";
    const static NSString* longitudeLabel = @"longitude";
    
    if ( [navDataLabel isEqualToString:elementName]) {
        self.navCells = [[NSMutableArray alloc] init];
        return;
    }
    
    if ( [cellLabel isEqualToString:elementName]) {
        NavCell* theNewCell = [[NavCell alloc] init:attributeDict[idLabel] latitude:attributeDict[latitudeLabel] longitude:attributeDict[longitudeLabel]];
        [self.navCells addObject:theNewCell];
    } 
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
}

@end
