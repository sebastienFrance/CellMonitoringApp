//
//  MonitoringPeriod.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 07/03/2015.
//
//

#import "MonitoringPeriod.h"
#import "DateUtility.h"

@interface MonitoringPeriod()

@property(nonatomic) DCMonitoringPeriodView thePeriodicity;
@property(nonatomic) NSString* fromDate;
@property(nonatomic) NSString* endDate;
@property(nonatomic) NSString* periodicity;

@end

@implementation MonitoringPeriod

-(instancetype) initWith:(DCMonitoringPeriodView) thePeriodicity {
    if (self = [super init] ) {
        self.thePeriodicity = thePeriodicity;
        [self buildPeriod];
    }
    
    return self;

}


-(void) buildPeriod {
    NSDate* now = [NSDate date];
    NSDate* end;
    NSDate* from;
    
    switch (self.thePeriodicity) {
        case last6Hours15MnView: {
            //
            end = [DateUtility getDateNear15mn:now];
            from = [end dateByAddingTimeInterval:-(60*60*6)];
            self.endDate = [DateUtility getGMTDate:end];
            self.fromDate = [DateUtility getGMTDate:from];
            self.periodicity = @"15mn";
            break;
        }
        case last24HoursHourlyView: {
            self.endDate = @"H-1";
            self.fromDate = @"H-24";
            self.periodicity = @"h";
            break;
        }
        case Last7DaysDailyView: {
            self.endDate = @"D-1";
            self.fromDate = @"D-7";
            self.periodicity = @"d";
            break;
        }
        case Last4WeeksWeeklyView: {
            self.endDate = @"W-1";
            self.fromDate = @"W-4";
            self.periodicity = @"w";
            break;
        }
        case Last6MonthsMontlyView: {
            self.endDate = @"M-1";
            self.fromDate = @"M-6";
            self.periodicity = @"m";
            break;
        }
        default: {
            self.endDate = @"H-1";
            self.fromDate = @"H-24";
            self.periodicity = @"h";
        }
    }
    
}


@end
