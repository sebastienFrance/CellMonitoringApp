//
//  CellAlarm.h
//  iMonitoring
//
//  Created by sébastien brugalières on 05/09/13.
//
//

#import <Foundation/Foundation.h>
@class CellMonitoring;

@interface CellAlarm : NSObject

typedef NS_ENUM(NSUInteger, AlarmSeverityId) {
    Cleared = 0,
    Warning = 1,
    Minor = 2,
    Major = 3,
    Critical = 4
};

typedef NS_ENUM(NSUInteger, AlarmTypeId) {
    Unknown = 0,
    Other = 1,
    CommunicationAlarm = 2,
    QualityOfServiceAlarm = 3,
    ProcessingErrorAlarm = 4,
    EnvironmentalAlarm = 5
};


@property(nonatomic, readonly) AlarmSeverityId severity;
@property(nonatomic, readonly) NSString* severityString;
@property(nonatomic, readonly) NSNumber* severityIdNumber;

#if TARGET_OS_IPHONE
@property(nonatomic, readonly) UIColor* severityLightColor;
@property(nonatomic, readonly) UIColor* severityColor;
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
@property(nonatomic, readonly) NSColor* severityLightColor;
@property(nonatomic, readonly) NSColor* severityColor;
#endif

@property(nonatomic, readonly) NSString* severityHTMLColor;



@property(nonatomic, readonly) AlarmTypeId alarmType;
@property(nonatomic, readonly) NSString* alarmTypeString;

@property(nonatomic, readonly) NSString* probableCause;
@property(nonatomic, readonly) NSString* additionalText;
@property(nonatomic, readonly) Boolean isAcknowledged;
@property(nonatomic, readonly) NSDate* dateAndTime;



- (id) initWithAlarmData:(NSDictionary*) theAlarmData;

- (NSComparisonResult) compareWithSeverity:(CellAlarm *)otherObject;
- (NSComparisonResult) compareWithDateAndTime:(CellAlarm *)otherObject;

- (NSString*) getAlarmDate:(CellMonitoring*) sourceCell;

#if TARGET_OS_IPHONE
+(UIColor*) getColorForSeverity:(AlarmSeverityId) severity;
+(UIColor*) getLightColorForSeverity:(AlarmSeverityId) severity;
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
+(NSColor*) getColorForSeverity:(AlarmSeverityId) severity;
+(NSColor*) getLightColorForSeverity:(AlarmSeverityId) severity;
#endif
+ (NSString*) getHTMLColorForSeverity:(AlarmSeverityId) severity;

+(NSString*) getAlarmSeverityFor:(AlarmSeverityId) severityId;

@end
