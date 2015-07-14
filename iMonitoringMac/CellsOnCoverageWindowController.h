//
//  CellsOnCoverageWindowController.h
//  iMonitoring
//
//  Created by sébastien brugalières on 27/12/2013.
//
//

#import <Cocoa/Cocoa.h>
#import "MapRefreshItf.h"


@interface CellsOnCoverageWindowController : NSWindowController

@property (nonatomic) id<MapRefreshItf> delegate;


-(void) refreshContent;

@end
