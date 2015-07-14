//
//  MonitoringPeriod.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 07/03/2015.
//
//

#import <Foundation/Foundation.h>
#import "MonitoringPeriodUtility.h"

@interface MonitoringPeriod : NSObject

-(instancetype) initWith:(DCMonitoringPeriodView) thePeriodicity;

@property(nonatomic, readonly) NSString* fromDate;
@property(nonatomic, readonly) NSString* endDate;
@property(nonatomic, readonly) NSString* periodicity;

@end
