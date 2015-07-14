//
//  HTMLMailUtility.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 16/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HTMLMailUtility.h"

#import "DateUtility.h"


@implementation HTMLMailUtility
+ (NSString*) getDateForHourlyAnd15mn:(NSUInteger) row requestDate:(NSDate*) theRequestDate timezone:(NSString*) theTimezone {
    double durationToRemove;
    DateDisplayOptions displayMinute = withHH00;
    
    NSDate* sourceDate = theRequestDate;
    if ([MonitoringPeriodUtility sharedInstance].monitoringPeriod == last6Hours15MnView) {
        durationToRemove = ((24 - row) * 15.0) * 60.0; // duration to substract in second from the orginal date
        sourceDate = [DateUtility getDateNear15mn:theRequestDate];
        displayMinute = withHHmm;
        
    } else {
        durationToRemove = ((24 - row) * 60.0) * 60.0; // duration to substract in second from the orginal date
        displayMinute = withHH00;
    }
    
    
    NSDate* from = [sourceDate dateByAddingTimeInterval:-durationToRemove];
    if (theTimezone != Nil) {
        NSString* localDate = [DateUtility getDateWithTimeZone:from timezone:theTimezone option:displayMinute];
        return [NSString stringWithFormat:@"%@ (%@)", localDate, theTimezone];
    } else {
        NSString* localDate =  [DateUtility getDate:from option:displayMinute];
        return [NSString stringWithFormat:@"%@ (localTime)", localDate];
    }
}

+ (NSString*) convertKPIsTableHeader:(NSDate*) theRequestDate timezone:(NSString*) theTimezone  {
    return [HTMLMailUtility convertKPIsTableHeader:theRequestDate timezone:theTimezone monitoringPeriod:[MonitoringPeriodUtility sharedInstance].monitoringPeriod];
}


+ (NSString*) convertKPIsTableHeader:(NSDate*) theRequestDate timezone:(NSString*) theTimezone monitoringPeriod:(DCMonitoringPeriodView) theMonitoringPeriod {
    NSMutableString* HTMLKPIDomain = [[NSMutableString alloc] init];
    
    switch (theMonitoringPeriod) {
        case last6Hours15MnView:             
        case last24HoursHourlyView: {
            for (int i=0 ; i <24 ; i++) {
                [HTMLKPIDomain appendFormat:@"<th> %@ </th>", [HTMLMailUtility getDateForHourlyAnd15mn:i requestDate:theRequestDate timezone:theTimezone]];       
            }
            break;
        }
        case Last7DaysDailyView: {
            for (int i = 0; i < 7; i++) {
                [HTMLKPIDomain appendFormat:@"<th>%@ %@</th>", 
                 [DateUtility getDayMinusNumberOfDay:theRequestDate minusDay:7-i shortFormat:FALSE],
                 [DateUtility getDayMonthMinusNumberOfDay:theRequestDate minusDay:7-i shortFormat:FALSE]];
            }
            break;
        }
        case Last4WeeksWeeklyView: {
            NSUInteger numEntries = 4;
            for (int i = 0; i < numEntries; i++) {
                [HTMLKPIDomain appendFormat:@"<th>%@</th>", [DateUtility getWeekMinusNumberOfWeek:theRequestDate minusWeek:numEntries-i shortFormat:FALSE]];
            }
            break;
        }
        case Last6MonthsMontlyView: {
            NSUInteger numEntries = 6;
            for (int i = 0; i < numEntries; i++) {
                [HTMLKPIDomain appendFormat:@"<th>%@ %@</th>", 
                 [DateUtility getMonthMinusNumberOfMonth:theRequestDate minusMonth:numEntries-i shortFormat:FALSE], 
                 [DateUtility getYearMinusNumberOfMonth:theRequestDate minusMonth:numEntries-i shortFormat:FALSE]];
            }
            break;
        }
        default: {
            for (int i=0 ; i <24 ; i++) {
                [HTMLKPIDomain appendFormat:@"<th> - %d H </th>", 24-i];       
            }
            break;
        }
    }   
    
    return HTMLKPIDomain;
}

+ (NSString*) getGreenColorCode {
    return @"green";
}

+ (NSString*) getYellowColorCode {
    return @"yellow";
}

+ (NSString*) getOrangeColorCode {
    return @"orange";
}
+ (NSString*) getRedColorCode {
    return @"red";
}

+ (NSString*) getNoValueColorCode {
    return @"white";
}

+ (NSString*) getBlueColorCode {
    return @"blue";
}





@end
