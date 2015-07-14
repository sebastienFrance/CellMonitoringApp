//
//  MonitoringPeriodUtility.m
//  iMonitoring
//
//  Created by sébastien brugalières on 23/02/13.
//
//

#import "MonitoringPeriodUtility.h"
#import "UserPreferences.h"

@implementation MonitoringPeriodUtility

+ (DCMonitoringPeriodView) getPreviousMonitoringPeriod:(DCMonitoringPeriodView) currentMonitoringPeriod {
    switch (currentMonitoringPeriod) {
        case last6Hours15MnView: {
            return Last6MonthsMontlyView;
            break;
        }
        case last24HoursHourlyView: {
            return last6Hours15MnView;
            break;
        }
        case Last7DaysDailyView: {
            return last24HoursHourlyView;
            break;
        }
        case Last4WeeksWeeklyView: {
            return Last7DaysDailyView;
            break;
        }
        case Last6MonthsMontlyView: {
            return Last4WeeksWeeklyView;
            break;
        }
        default: {
            return currentMonitoringPeriod;
        }
    }
}

+ (DCMonitoringPeriodView) getNextMonitoringPeriod:(DCMonitoringPeriodView) currentMonitoringPeriod {
    switch (currentMonitoringPeriod) {
        case last6Hours15MnView: {
            return last24HoursHourlyView;
            break;
        }
        case last24HoursHourlyView: {
            return Last7DaysDailyView;
            break;
        }
        case Last7DaysDailyView: {
            return Last4WeeksWeeklyView;
            break;
        }
        case Last4WeeksWeeklyView: {
            return Last6MonthsMontlyView;
            break;
        }
        case Last6MonthsMontlyView: {
            return last6Hours15MnView;
            break;
        }
        default: {
            return currentMonitoringPeriod;
        }
    }
}



// -------- Methods used to return info about the default GP ----------

static NSString* rowNames[] = {
    @"Last 6 hours (15mn view)",
    @"Last 24 hours (Hourly view)",
    @"Last 7 days (Daily view)",
    @"Last 5 weeks (Weekly view)",
    @"Last 6 months (Monthly view)"};


static NSString* gpNames[] = {
    @"Last 15mn",
    @"Last Hour",
    @"Last Day",
    @"Last Week",
    @"Last Month"};

static NSString* shortGPNames[] = {
    @"15 minutes",
    @"1 Hour",
    @"day",
    @"week",
    @"month"};

static NSString* periodDuration[] = {
    @"Last 6 hours",
    @"Last 24 hours",
    @"Last 7 days",
    @"Last 5 weeks",
    @"Last 6 months"};



+ (NSString*) getInternalStringForMonitoringPeriod:(DCMonitoringPeriodView) theMonitoringPeriod {
    
    switch (theMonitoringPeriod) {
        case last6Hours15MnView: {
            return @"last6Hours15MnView";
        }
        case last24HoursHourlyView: {
            return @"last24HoursHourlyView";
        }
        case Last7DaysDailyView: {
            return @"Last7DaysDailyView";
        }
        case Last4WeeksWeeklyView: {
            return @"Last4WeeksWeeklyView";
        }
        case Last6MonthsMontlyView: {
            return @"Last6MonthsMontlyView";
        }
        default: {
            return Nil;
        }
    }
}



+ (NSString*) getStringForMonitoringPeriod:(DCMonitoringPeriodView) theMonitoringPeriod {
    return rowNames[theMonitoringPeriod];
}
+ (NSString*) getStringForGranularityPeriodName:(DCMonitoringPeriodView) theMonitoringPeriod {
    return gpNames[theMonitoringPeriod];
}
+ (NSString*) getStringForShortGranularityPeriodName:(DCMonitoringPeriodView) theMonitoringPeriod {
    return shortGPNames[theMonitoringPeriod];
}
+ (NSString*) getStringForGranularityPeriodDuration:(DCMonitoringPeriodView) theMonitoringPeriod {
    return periodDuration[theMonitoringPeriod];
}


+(MonitoringPeriodUtility*)sharedInstance
{
    static dispatch_once_t pred;
    static MonitoringPeriodUtility *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[MonitoringPeriodUtility alloc] init];
    });
    return sharedInstance;
}

- (id)init{
    if (self = [super init] ) {
        _monitoringPeriod = [UserPreferences sharedInstance].KPIDefaultMonitoringPeriod;
    }
    
    return self;
}


- (void) dealloc {
    // implement -dealloc & remove abort() when refactoring for
    // non-singleton use.
    abort();
}

- (void) setMonitoringPeriod:(DCMonitoringPeriodView)theMonitoringPeriod {
    _monitoringPeriod = theMonitoringPeriod;
    [UserPreferences sharedInstance].KPIDefaultMonitoringPeriod = _monitoringPeriod;
}


-(NSString*) monitoringPeriodString {
    
    return [MonitoringPeriodUtility getStringForMonitoringPeriod:_monitoringPeriod];
}



@end
