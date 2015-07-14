//
//  CellSearchPopoverViewController.h
//  iMonitoring
//
//  Created by sébastien brugalières on 19/01/2014.
//
//

#import <Cocoa/Cocoa.h>

@interface CellSearchPopoverViewController : NSViewController<NSTableViewDataSource, NSTableViewDelegate>

-(void) updateWith:(NSString*) address cells:(NSArray*)cells;

@end
