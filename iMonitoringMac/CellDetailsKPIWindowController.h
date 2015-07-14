//
//  CellDetailsKPIWindowController.h
//  iMonitoring
//
//  Created by sébastien brugalières on 16/01/2014.
//
//

#import <Cocoa/Cocoa.h>
#import "MonitoringPeriodUtility.h"
#import "KPIBarChart.h"

@class CellKPIsDataSource;

@interface CellDetailsKPIWindowController : NSWindowController<NSTableViewDataSource, NSTableViewDelegate, barChartNotification>

- (id)init:(CellKPIsDataSource*) cellDatasource initialIndex:(NSIndexPath*) index initialMonitoringPeriod:(DCMonitoringPeriodView) monitoringPeriod;

@end
