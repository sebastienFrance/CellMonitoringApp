//
//  ZoneKPIDataSource.h
//  iMonitoring
//
//  Created by sébastien brugalières on 06/10/12.
//
//

#import <Foundation/Foundation.h>

#import "KPI.h"
#import "MonitoringPeriodUtility.h"
#import "ZoneKPI.h"

@class WorstKPIDataSource;

@protocol ZoneKPIDataSource
- (KPI*) getZoneKPI;
- (NSArray*) getZoneKPIValues;
- (void) moveToNextZoneKPI;
- (void) moveToPreviousZoneKPI;
- (void) goToIndex:(NSUInteger) index;
- (DCMonitoringPeriodView) getZoneMonitoringPeriod;
- (WorstKPIDataSource*) getDetailedDataSource;
- (ZoneKPI*) getFullZoneKPI;

@end

