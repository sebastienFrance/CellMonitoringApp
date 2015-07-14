//
//  KPIDataSource.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 29/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MonitoringPeriodUtility.h"

@class KPI;

@protocol KPIDataSource 
- (KPI*) getKPI;
- (NSArray*) getKPIValues;
- (NSArray*) getKPIValuesOf:(KPI*) theKPI;
- (void) moveToNextKPI;
- (void) moveToPreviousKPI;
- (void) moveToNextMonitoringPeriod;
- (void) moveToPreviousMonitoringPeriod;
- (DCMonitoringPeriodView) getMonitoringPeriod;




@end
