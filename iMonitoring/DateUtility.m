//
//  DateUtility.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 03/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DateUtility.h"
#import <math.h>
#import "MonitoringPeriodUtility.h"
#import "Utility.h"
@implementation DateUtility


#pragma mark - Get date with different formats
+ (NSDate*) getDateNear15mn:(NSDate*) initialDate {

    if (initialDate == Nil) {
        return Nil;
    }

    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents* component = [gregorian components:NSCalendarUnitMinute fromDate:initialDate ];
    NSUInteger minute = component.minute;
    NSUInteger minutesToRemove;
    
    if (minute < 15) {
        minutesToRemove = minute;
    } else if (minute < 30) {
        minutesToRemove = minute - 15;
    } else if (minute < 45) { 
        minutesToRemove = minute - 30;
    } else if (minute < 59) {
        minutesToRemove = minute - 45;
    } else {
        minutesToRemove = minute;
    }
    
    // Warning need to substract still 15mn else the data are not yet available
    minutesToRemove += 15;
    
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setMinute:-(minutesToRemove)];
    NSDate *computedDate = [gregorian dateByAddingComponents:offsetComponents
                                                      toDate:initialDate options:0];
    return computedDate;
}

+ (NSString*) getDate:(NSDate*) date option:(DateDisplayOptions) theOption {
    if (date == Nil) {
        return Nil;
    }

    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    [DateUtility configureDateFormat:format withOption:theOption];
    return [format stringFromDate:date];
}

+ (NSString*) getDateWithRealTimeZone:(NSDate*) date timezone:(NSTimeZone*) timeZone option:(DateDisplayOptions) theOption {
    if (date == Nil) {
        return Nil;
    }

    NSDateFormatter* format = [[NSDateFormatter alloc] init];

     if (timeZone != Nil) {
        [format setTimeZone:timeZone];
        [DateUtility configureDateFormat:format withOption:theOption];
        return [format stringFromDate:date];
    } else {
        return @"Not Available";
    }
}


+(void) configureDateFormat:(NSDateFormatter*) format withOption:(DateDisplayOptions) theOption {
    switch (theOption) {
        case withHHmmss:
            [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            break;
        case withHH00: {
            [format setDateFormat:@"yyyy-MM-dd HH':00'"];
            break;
        }
        case withHHmm: {
            [format setDateFormat:@"yyyy-MM-dd HH:mm"];
            break;
        }
        default: {
            [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        }
    }
}

+(NSString*) getSimpleLocalizedDate:(NSDate *)date {
    return [NSDateFormatter localizedStringFromDate:date
                                   dateStyle:NSDateFormatterMediumStyle
                                   timeStyle:NSDateFormatterNoStyle];
}

// Return a string that contains the date in format YYYY.MM.DD hh.mm in GMT
+ (NSString*) getGMTDate:(NSDate*) date {
    if (date == Nil) {
        return Nil;
    }

    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorian setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSDateComponents *dateComponents = [gregorian components:(NSCalendarUnitHour  | NSCalendarUnitMinute | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                                    fromDate:date];
    
    return [NSString stringWithFormat:@"%ld.%02ld.%02ld %02ld.%02ld", (long)[dateComponents year],
            (long)[dateComponents month], (long)[dateComponents day], (long)[dateComponents hour], (long)[dateComponents minute]];
}

+(NSString*) getShortGMTDateFromString:(NSString*) dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSDate *date = [dateFormatter dateFromString:dateString];

    return [DateUtility getShortGMTDate:date];
}

+(NSDate*) getDateFromShortString:(NSString*) dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    
     NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSDate *date = [dateFormatter dateFromString:dateString];

    return date;
}

// Return a string that contains the date in format YYYY.MM.DD in GMT
+ (NSString*) getShortGMTDate:(NSDate*) date {
    if (date == Nil) {
        return Nil;
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorian setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSDateComponents *dateComponents = [gregorian components:(NSCalendarUnitHour  | NSCalendarUnitMinute | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                                    fromDate:date];
    
    return [NSString stringWithFormat:@"%ld.%02ld.%02ld",
            (long)[dateComponents year],
            (long)[dateComponents month],
            (long)[dateComponents day]];
}



#pragma mark - Compute day, week... based on a initial date

+ (NSString*) getDayMinusNumberOfDay:(NSDate*) baseDate minusDay:(NSUInteger) day shortFormat:(Boolean) isShortFormat {
    if (baseDate == Nil) {
        return @"Wrong date";
    }

    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:-(day)];
    NSDate *computedDate = [gregorian dateByAddingComponents:offsetComponents
                                                      toDate:baseDate options:0];
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    
    if (isShortFormat) {
        [format setDateFormat:@"EEE"];
    } else {
        [format setDateFormat:@"EEEE"];
    }
    return [format stringFromDate:computedDate];
    
}

+ (NSString*) getDayMonthMinusNumberOfDay:(NSDate*) baseDate minusDay:(NSUInteger) day shortFormat:(Boolean) isShortFormat {
    if (baseDate == Nil) {
        return @"Wrong date";
    }

    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:-(day)];
    NSDate *computedDate = [gregorian dateByAddingComponents:offsetComponents
                                                      toDate:baseDate options:0];
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    
    if (isShortFormat) {
        [format setDateFormat:@"d MMM"];
    } else {
        [format setDateFormat:@"d MMMM"];
    }
    return [format stringFromDate:computedDate];
}


+ (NSString*) getWeekMinusNumberOfWeek:(NSDate*) baseDate minusWeek:(NSUInteger) week shortFormat:(Boolean) isShortFormat {
    if (baseDate == Nil) {
        return @"Wrong date";
    }

    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setWeekOfYear:-(week)];
    NSDate *computedDate = [gregorian dateByAddingComponents:offsetComponents
                                                      toDate:baseDate options:0];
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"w"];
    NSString* weekResult;
    
    if (isShortFormat) {
        weekResult = [NSString stringWithFormat:@"w%@",[format stringFromDate:computedDate]];
    } else {
        weekResult = [NSString stringWithFormat:@"week %@",[format stringFromDate:computedDate]];
        
    }
    return weekResult;
    
}

+ (NSString*) getMonthMinusNumberOfMonth:(NSDate*) baseDate minusMonth:(NSUInteger) month shortFormat:(Boolean) isShortFormat {
    if (baseDate == Nil) {
        return @"Wrong date";
    }

    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setMonth:-(month)];
    NSDate *computedDate = [gregorian dateByAddingComponents:offsetComponents
                                                      toDate:baseDate options:0];
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    
    if (isShortFormat) {
        [format setDateFormat:@"MMM"];
    } else {
        [format setDateFormat:@"MMMM"];
    }
    return [format stringFromDate:computedDate];
    
}



+ (NSString*) getYearMinusNumberOfMonth:(NSDate*) baseDate minusMonth:(NSUInteger) month shortFormat:(Boolean) isShortFormat {
    if (baseDate == Nil) {
        return @"Wrong date";
    }

    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setMonth:-(month)];
    NSDate *computedDate = [gregorian dateByAddingComponents:offsetComponents
                                                      toDate:baseDate options:0];
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    
    if (isShortFormat) {
        [format setDateFormat:@"yy"];
    } else {
        [format setDateFormat:@"yyyy"];
        
    }
    return [format stringFromDate:computedDate];
    
}

#pragma mark - Get string with time to be displayed based on monitoring period

+ (NSString*) configureTimeDetailsCellWithTimezone:(NSDate*) theRequestedDate timezone:(NSTimeZone*) theTimezone row:(NSInteger) theRow monitoringPeriod:(DCMonitoringPeriodView) theMonitoringPeriod {
    
    double durationToRemove;
    double durationToRemoveForEnd;
    DateDisplayOptions displayMinute = withHH00;
    
    NSDate* sourceDate = theRequestedDate;
    
    
    if (theMonitoringPeriod == last6Hours15MnView) {
        durationToRemove = ((24 - theRow) * 15.0) * 60.0; // duration to substract in second from the orginal date
        durationToRemoveForEnd = 15*60; // Adding 15 minutes
        sourceDate = [DateUtility getDateNear15mn:theRequestedDate];
        displayMinute = withHHmm;
    } else {
        durationToRemove = ((24 - theRow) * 60.0) * 60.0; // duration to substract in second from the orginal date
        durationToRemoveForEnd = 3600; // adding 1 hour
        displayMinute = withHH00;
    }
    
    NSDate* from = [sourceDate dateByAddingTimeInterval:-durationToRemove];
    // adding duration of Monitoring Period
    NSDate* end = [sourceDate dateByAddingTimeInterval:(-durationToRemove + durationToRemoveForEnd)];
    
    NSString* endDate = [DateUtility getDate:end option:displayMinute];
    NSString* startDate = [DateUtility getDate:from option:displayMinute];
    
    NSString* dateAndTime;
    
    if (theTimezone != nil) {
        NSString* localEndDate = [DateUtility getDateWithRealTimeZone:end timezone:theTimezone option:displayMinute];
        NSString* localStartDate = [DateUtility getDateWithRealTimeZone:from timezone:theTimezone option:displayMinute];
        dateAndTime = [NSString stringWithFormat:@"%@ - %@ (%@)", localStartDate, localEndDate, [Utility extractShortTimezoneFrom:theTimezone] ];
    } else {
        dateAndTime = [NSString stringWithFormat:@"%@ - %@ (Local Time)", startDate, endDate ];
    }
    
    return dateAndTime;
}


+ (NSString*) configureTimeDetailsCell:(NSDate*) theRequestedDate row:(NSInteger) theRow monitoringPeriod:(DCMonitoringPeriodView) theMonitoringPeriod {
    
    return [DateUtility configureTimeDetailsCellWithTimezone:theRequestedDate timezone:Nil row:theRow monitoringPeriod:theMonitoringPeriod];
}

+ (NSString*) configureTimeDetailsCellPeriod:(NSDate*) theRequestedDate row:(NSUInteger) theRow monitoringPeriod:(DCMonitoringPeriodView) theMonitoringPeriod {
    
    NSString* endDate;
    NSString* startDate;
    
    NSString* dateAndTime;
    
    switch (theMonitoringPeriod) {
        case Last7DaysDailyView: {
            startDate = [DateUtility getDayMinusNumberOfDay:theRequestedDate minusDay:(7-theRow) shortFormat:FALSE];
            endDate = [DateUtility getDayMonthMinusNumberOfDay:theRequestedDate minusDay:(7-theRow) shortFormat:FALSE];
            dateAndTime = [NSString stringWithFormat:@"%@ %@", startDate, endDate];
            break;
        }
        case Last4WeeksWeeklyView: {
            startDate = [DateUtility getWeekMinusNumberOfWeek:theRequestedDate minusWeek:(4-theRow) shortFormat:FALSE];
            dateAndTime = [NSString stringWithFormat:@"%@", startDate];
            break;
        }
        case Last6MonthsMontlyView: {
            startDate = [DateUtility getMonthMinusNumberOfMonth:theRequestedDate minusMonth:(6-theRow) shortFormat:FALSE];
            endDate = [DateUtility getYearMinusNumberOfMonth:theRequestedDate minusMonth:(6-theRow) shortFormat:FALSE];
            dateAndTime = [NSString stringWithFormat:@"%@ %@", startDate, endDate];
            break;
        }
        default: {
            dateAndTime = @"unknown date format";
            NSLog(@"Error unplanned case");
        }
    }
    
    return dateAndTime;
    
}

#pragma mark - Get formated string to display a duration

+(NSString*) getDurationToString:(NSTimeInterval) duration withSeconds:(Boolean) isWithSeconds {
    NSUInteger elapsedSeconds = duration;
    NSUInteger hours = elapsedSeconds / 3600;
    NSUInteger minutes = (elapsedSeconds / 60) % 60;
    NSUInteger seconds = elapsedSeconds % 60;
    
    if (isWithSeconds) {
        return [NSString stringWithFormat:@"%02luh%02lumn%02lus", (unsigned long)hours, (unsigned long)minutes, (unsigned long)seconds];
    } else {
        return [NSString stringWithFormat:@"%02luh%02lumn", (unsigned long)hours, (unsigned long)minutes];
    }

}


@end
