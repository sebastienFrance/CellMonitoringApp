//
//  MonitoringPeriodUtility.h
//  iMonitoring
//
//  Created by sébastien brugalières on 23/02/13.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DCMonitoringPeriodView) {
    last6Hours15MnView = 0,
    last24HoursHourlyView = 1,
    Last7DaysDailyView = 2,
    Last4WeeksWeeklyView = 3,
    Last6MonthsMontlyView = 4,
};


@interface MonitoringPeriodUtility : NSObject


+ (DCMonitoringPeriodView) getPreviousMonitoringPeriod:(DCMonitoringPeriodView) currentMonitoringPeriod;
+ (DCMonitoringPeriodView) getNextMonitoringPeriod:(DCMonitoringPeriodView) currentMonitoringPeriod;


+ (NSString*) getInternalStringForMonitoringPeriod:(DCMonitoringPeriodView) monitoringPeriod;
+ (NSString*) getStringForMonitoringPeriod:(DCMonitoringPeriodView) monitoringPeriod;
+ (NSString*) getStringForGranularityPeriodName:(DCMonitoringPeriodView) monitoringPeriod;
+ (NSString*) getStringForShortGranularityPeriodName:(DCMonitoringPeriodView) theMonitoringPeriod;
+ (NSString*) getStringForGranularityPeriodDuration:(DCMonitoringPeriodView) monitoringPeriod;

@property (nonatomic, assign) DCMonitoringPeriodView monitoringPeriod;
@property (nonatomic, readonly) NSString* monitoringPeriodString;

+ (MonitoringPeriodUtility*) sharedInstance;


@end
