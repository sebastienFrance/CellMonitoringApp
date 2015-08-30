//
//  DisplayKPICell.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 21/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MonitoringPeriodUtility.h"

@class KPI;


@interface DisplayKPICell : UITableViewCell


-(void) initWith:(KPI*) cellKPI monitoringPeriod:(DCMonitoringPeriodView) monitoringPeriod KPIValues:(NSArray<NSNumber*>*) kpiValues date:(NSDate*) requestDate;
-(void) isStillLoading;
@end
