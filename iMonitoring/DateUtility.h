//
//  DateUtility.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 03/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MonitoringPeriodUtility.h"

typedef NS_ENUM(NSUInteger, DateDisplayOptions) {
    withHHmmss = 0,
    withHHmm = 1,
    withHH00 = 2,
};

@interface DateUtility : NSObject

#pragma mark - Compute day, week... based on a initial date
+ (NSString*) getDayMinusNumberOfDay:(NSDate*) baseDate
                            minusDay:(NSUInteger) day
                         shortFormat:(Boolean) format;

+ (NSString*) getDayMonthMinusNumberOfDay:(NSDate*) baseDate
                                 minusDay:(NSUInteger) day
                              shortFormat:(Boolean) format;

+ (NSString*) getWeekMinusNumberOfWeek:(NSDate*) baseDate
                             minusWeek:(NSUInteger) week
                           shortFormat:(Boolean) isShortFormat;

+ (NSString*) getMonthMinusNumberOfMonth:(NSDate*) baseDate
                              minusMonth:(NSUInteger) month
                             shortFormat:(Boolean) format;

+ (NSString*) getYearMinusNumberOfMonth:(NSDate*) baseDate
                             minusMonth:(NSUInteger) month
                            shortFormat:(Boolean) format;

#pragma mark - Get date with different formats

+ (NSDate*) getDateNear15mn:(NSDate*) initialDate;

+ (NSString*) getSimpleLocalizedDate:(NSDate*) date;
+ (NSString*) getDate:(NSDate*) date option:(DateDisplayOptions) theOption;
+ (NSString*) getDateWithRealTimeZone:(NSDate*) date timezone:(NSTimeZone*) timeZone option:(DateDisplayOptions) theOption;

+ (NSString*) getGMTDate:(NSDate*) date;
+ (NSString*) getShortGMTDate:(NSDate*) date;

// String must be YYYYMMDD
+(NSString*) getShortGMTDateFromString:(NSString*) dateString;
+(NSDate*) getDateFromShortString:(NSString*) dateString;

#pragma mark - Get string with time to be displayed based on monitoring period

+ (NSString*) configureTimeDetailsCellWithTimezone:(NSDate*) theRequestedDate
                                          timezone:(NSTimeZone*) theTimezone
                                               row:(NSInteger) theRow
                                  monitoringPeriod:(DCMonitoringPeriodView) theMonitoringPeriod;

+ (NSString*) configureTimeDetailsCell:(NSDate*) theRequestedDate
                                   row:(NSInteger) theRow
                      monitoringPeriod:(DCMonitoringPeriodView) theMonitoringPeriod;

+ (NSString*) configureTimeDetailsCellPeriod:(NSDate*) theRequestedDate
                                         row:(NSUInteger) theRow
                            monitoringPeriod:(DCMonitoringPeriodView) theMonitoringPeriod;

#pragma mark - Get formated string to display a duration

+ (NSString*) getDurationToString:(NSTimeInterval) duration
                     withSeconds:(Boolean) isWithSeconds;

@end
