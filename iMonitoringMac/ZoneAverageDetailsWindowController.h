//
//  ZoneAverageDetailsWindowController.h
//  iMonitoring
//
//  Created by sébastien brugalières on 09/01/2014.
//
//

#import <Foundation/Foundation.h>
#import "KPIBarChart.h"

@protocol ZoneKPIDataSource;
@class WorstKPIDataSource;

@interface ZoneAverageDetailsWindowController : NSWindowController<NSTableViewDataSource, NSTableViewDelegate, barChartNotification>

- (id)init:(WorstKPIDataSource*) dataSource initialIndex:(NSUInteger) index;
- (void) refresh:(NSUInteger) index;

@end
