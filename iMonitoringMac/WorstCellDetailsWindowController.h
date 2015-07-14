//
//  WorstCellDetailsWindowController.h
//  iMonitoring
//
//  Created by sébastien brugalières on 04/01/2014.
//
//

#import <Cocoa/Cocoa.h>
#import "WorstKPIChart.h"
@protocol WorstKPIItf;

@class WorstKPIDataSource;

@interface WorstCellDetailsWindowController : NSWindowController<NSTableViewDataSource, NSTableViewDelegate, pieChartNotification>


- (id)init:(WorstKPIDataSource*) worstKPIDatasource initialIndex:(NSUInteger) index isAverage:(Boolean) isAverageKPIs;
-(void) refresh:(NSUInteger) index;

@end
