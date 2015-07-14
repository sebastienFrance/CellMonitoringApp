//
//  CellKPIDatasource.h
//  iMonitoring
//
//  Created by sébastien brugalières on 16/01/2014.
//
//

#import <Foundation/Foundation.h>

#import "KPIDataSource.h"

@class CellKPIsDataSource;


@interface CellKPIDatasource : NSObject<KPIDataSource>

- (id)init:(CellKPIsDataSource*) cellDatasource
            initialMonitoringPeriod:(DCMonitoringPeriodView)
            monitoringPeriod initialIndex:(NSIndexPath*) index;

@end
