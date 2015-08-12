//
//  NavDataParsing.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 02/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NavCell.h"

@interface NavDataParsing : NSObject <NSXMLParserDelegate>

typedef NS_ENUM(NSInteger, NavDataParsingStatus) {
    Success,
    InitializationError,
    ParseError
};

@property(nonatomic, readonly) NSArray<NavCell*> *navigationCells;

//- (NSArray<NavCell*>*) parseNavigationData:(NSURL*) url;
- (NavDataParsingStatus) parseNavigationData:(NSURL*) url;


@end
