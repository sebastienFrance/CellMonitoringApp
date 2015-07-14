//
//  ZoneAverageDetailsCellWindow.h
//  iMonitoring
//
//  Created by sébastien brugalières on 11/01/2014.
//
//

#import <Cocoa/Cocoa.h>

@interface ZoneAverageDetailsCellWindow : NSTableCellView

@property (nonatomic, weak) IBOutlet NSTextField* dateLocalTime;
@property (nonatomic, weak) IBOutlet NSTextField* dateCellLocalTime;

@end
