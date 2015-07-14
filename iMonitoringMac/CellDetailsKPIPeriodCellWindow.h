//
//  CellDetailsKPIPeriodCellWindow.h
//  iMonitoring
//
//  Created by sébastien brugalières on 17/01/2014.
//
//

#import <Cocoa/Cocoa.h>

@interface CellDetailsKPIPeriodCellWindow : NSTableCellView
@property (weak) IBOutlet NSTextField* KPIValue;
@property (weak) IBOutlet NSTextField* dateInLocalTime;

@property (weak) IBOutlet NSTextField* severity;
@end
