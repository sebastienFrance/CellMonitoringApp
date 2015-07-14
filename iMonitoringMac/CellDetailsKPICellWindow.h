//
//  CellDetailsKPICellWindow.h
//  iMonitoring
//
//  Created by sébastien brugalières on 16/01/2014.
//
//

#import <Cocoa/Cocoa.h>

@interface CellDetailsKPICellWindow : NSTableCellView


@property (weak) IBOutlet NSTextField* KPIValue;
@property (weak) IBOutlet NSTextField* dateInLocalTime;
@property (weak) IBOutlet NSTextField* dateInCellTimezone;

@property (weak) IBOutlet NSTextField* severity;
@end
