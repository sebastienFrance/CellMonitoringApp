//
//  CellAlarm.m
//  iMonitoring
//
//  Created by sébastien brugalières on 05/09/13.
//
//

#import "CellAlarm.h"
#import "HTMLMailUtility.h"
#import "CellMonitoring.h"
#import "DateUtility.h"
#import "Utility.h"

@implementation CellAlarm


/*
 private int _severity;
 private String _probableCause;
 private long _dateAndTime;
 private int _alarmType;
 private String _additionalText;
 private Boolean _isAcknowledged;

 */

static const NSString* PARAM_Alarm_Severity = @"severity";
static const NSString* PARAM_Alarm_ProbableCause = @"probableCause";
static const NSString* PARAM_Alarm_DateAndTime = @"dateAndTime";
static const NSString* PARAM_Alarm_AlarmType = @"alarmType";
static const NSString* PARAM_Alarm_AdditionalText = @"additionalText";
static const NSString* PARAM_Alarm_IsAcknowledged = @"isAcknowledged";


- (id) initWithAlarmData:(NSDictionary*) theAlarmData {
    if (self = [super init]) {
        NSNumber* alarmSeverity = theAlarmData[PARAM_Alarm_Severity];
        _severity = alarmSeverity.integerValue;
        
        _probableCause = theAlarmData[PARAM_Alarm_ProbableCause];
        NSNumber* dateAndTime = theAlarmData[PARAM_Alarm_DateAndTime];
        unsigned long durationInMs = dateAndTime.unsignedLongValue;
        NSTimeInterval timeInSec = durationInMs / 1000;
        _dateAndTime = [NSDate dateWithTimeIntervalSince1970:timeInSec];
        
        NSNumber* alarmType = theAlarmData[PARAM_Alarm_AlarmType];
        _alarmType = alarmType.integerValue;
        
        _additionalText = theAlarmData[PARAM_Alarm_AdditionalText];
        
        NSNumber* isAcknowledged = theAlarmData[PARAM_Alarm_IsAcknowledged];
        _isAcknowledged = isAcknowledged.boolValue;
    }
    return self;
}

static NSString *alarmTypeConstantString[] = { @"Unknown", @"Other", @"Communication alarm",@"Quality of service alarm",@"Processing error alarm",@"Environmental alarm" };

- (NSString*) alarmTypeString {
    return alarmTypeConstantString[self.alarmType];
}

+(NSString*) getAlarmSeverityFor:(AlarmSeverityId) severityId {
    return alarmTypeConstantString[severityId];
}

static NSString *severityConstantString[] = { @"Cleared", @"Warning", @"Minor",@"Major",@"Critical" };


- (NSComparisonResult) compareWithDateAndTime:(CellAlarm *)otherObject {
    
    NSComparisonResult result = [self.dateAndTime compare:otherObject.dateAndTime];
    if (result == NSOrderedAscending) {
        return NSOrderedDescending;
    } else if (result == NSOrderedDescending) {
        return NSOrderedAscending;
    } else {
        return NSOrderedSame;
    }
}


- (NSComparisonResult) compareWithSeverity:(CellAlarm *)otherObject {
    if (self.severity == otherObject.severity) {
        return NSOrderedSame;
    }
    
    if (self.severity <= otherObject.severity) {
        return NSOrderedDescending;
    } else {
        return NSOrderedAscending;
    }
 }



- (NSString*) severityString {
    return severityConstantString[self.severity];
}

- (NSNumber*) severityIdNumber {
    return [NSNumber numberWithInteger:self.severity];
}

- (NSString*) getAlarmDate:(CellMonitoring*) sourceCell {
    if (sourceCell.hasTimezone) {
        return [NSString stringWithFormat:@"%@",[DateUtility getDateWithRealTimeZone:self.dateAndTime
                                                                        timezone:sourceCell.theTimezone
                                                                          option:withHHmmss]];
    } else {
        return [NSString stringWithFormat:@"%@ (LT)",[DateUtility getDate:self.dateAndTime
                                                                   option:withHHmmss]];
    }

}


#if TARGET_OS_IPHONE

- (UIColor*) severityLightColor {
   return [CellAlarm getLightColorForSeverity:self.severity];
}

- (UIColor*) severityColor {
    return [CellAlarm getColorForSeverity:self.severity];
}
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
- (NSColor*) severityLightColor {
    return [CellAlarm getLightColorForSeverity:self.severity];
}

- (NSColor*) severityColor {
    return [CellAlarm getColorForSeverity:self.severity];
}
#endif

- (NSString*) severityHTMLColor {
    return [CellAlarm getHTMLColorForSeverity:self.severity];
}

+ (NSString*) getHTMLColorForSeverity:(AlarmSeverityId) severity {
    switch (severity) {
        case Warning: {
            return [HTMLMailUtility getBlueColorCode];
        }
        case Minor: {
            return [HTMLMailUtility getYellowColorCode];
        }
        case Major: {
            return [HTMLMailUtility getOrangeColorCode];
        }
        case Critical: {
            return [HTMLMailUtility getRedColorCode];
        }
        case Cleared: {
            return [HTMLMailUtility getGreenColorCode];
        }
    }
    
 
}

#if TARGET_OS_IPHONE
+(UIColor*) getColorForSeverity:(AlarmSeverityId) severity {
    switch (severity) {
        case Warning: {
            return [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.5];
        }
        case Minor: {
            return [UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:0.5];
        }
        case Major: {
            return [UIColor colorWithRed:1.0 green:0.5 blue:1.0 alpha:0.5];
        }
        case Critical: {
            return [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5];
        }
        case Cleared: {
            return [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.5];
        }
    }

}
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
+(NSColor*) getColorForSeverity:(AlarmSeverityId) severity {
    switch (severity) {
        case Warning: {
            return [NSColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.5];
        }
        case Minor: {
            return [NSColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:0.5];
        }
        case Major: {
            return [NSColor colorWithRed:1.0 green:0.5 blue:1.0 alpha:0.5];
        }
        case Critical: {
            return [NSColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5];
        }
        case Cleared: {
            return [NSColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.5];
        }
    }
    
}
#endif

#if TARGET_OS_IPHONE

+(UIColor*) getLightColorForSeverity:(AlarmSeverityId) severity {
    switch (severity) {
        case Warning: {
            return [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.1];
        }
        case Minor: {
            return [UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:0.1];
        }
        case Major: {
            return [UIColor colorWithRed:1.0 green:0.5 blue:1.0 alpha:0.1];
        }
        case Critical: {
            return [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.1];
        }
        case Cleared: {
            return [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.1];
        }
    }
}
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
+(NSColor*) getLightColorForSeverity:(AlarmSeverityId) severity {
    switch (severity) {
        case Warning: {
            return [NSColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.1];
        }
        case Minor: {
            return [NSColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:0.1];
        }
        case Major: {
            return [NSColor colorWithRed:1.0 green:0.5 blue:1.0 alpha:0.1];
        }
        case Critical: {
            return [NSColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.1];
        }
        case Cleared: {
            return [NSColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.1];
        }
    }
}
#endif

@end
