//
//  CellGroupPopoverViewController.h
//  iMonitoring
//
//  Created by sébastien brugalières on 21/12/2013.
//
//

#import <Cocoa/Cocoa.h>
#import "MainMapWindowController.h"

@class CellMonitoringGroup;

@interface CellGroupPopoverViewController : NSViewController<NSTableViewDataSource, NSTableViewDelegate>

//-(void) initialize:(CellMonitoringGroup*) cellGroup ;
-(id) initWithCellGroup:(CellMonitoringGroup*) cellGroup;

@end
