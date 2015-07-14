//
//  CellAlarmTests.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 19/05/2014.
//
//

#import <XCTest/XCTest.h>
#import "CellAlarm.h"
#import <limits.h>

@interface CellAlarmTests : XCTestCase

@end

@implementation CellAlarmTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void) testBasicAlarm {
    NSDictionary* alarmDictionary = @{@"severity" : @0,
                                      @"probableCause": @"Fire Detected",
                                      @"dateAndTime": @0,
                                      @"alarmType": @0,
                                      @"additionalText": @"the Additional Text",
                                      @"isAcknowledged": @TRUE};

    CellAlarm* baseAlarm = [[CellAlarm alloc] initWithAlarmData:alarmDictionary];

    XCTAssertTrue([baseAlarm.probableCause isEqualToString:@"Fire Detected"], @"ProbableCause ok");
    XCTAssertTrue([baseAlarm.additionalText isEqualToString:@"the Additional Text"], @"ProbableCause ok");
    XCTAssertTrue(baseAlarm.isAcknowledged == TRUE, @"isAcknowledged == True is ok");

    unsigned long value = 60UL*60UL*24UL*365UL*20UL*1000UL; // Multiply by 1000 because the interface use milliseconds instead of seconds
    NSNumber* doubleForDate = [NSNumber numberWithUnsignedLong:value];
    NSDictionary* alarmDictionaryAckFalse = @{@"severity" : @0,
                                      @"probableCause": @"Fire Detected",
                                      @"dateAndTime": doubleForDate, // around 20 year from 1971 (multiply by 1000 because in the interface it's in milliseconds
                                      @"alarmType": @0,
                                      @"additionalText": @"the Additional Text",
                                      @"isAcknowledged": @FALSE};
    baseAlarm = [[CellAlarm alloc] initWithAlarmData:alarmDictionaryAckFalse];

    XCTAssertTrue(baseAlarm.isAcknowledged == FALSE, @"isAcknowledged == False is ok");

    NSDate* initialTime = [NSDate dateWithTimeIntervalSince1970:(60*60*24*365*20)];
    XCTAssertTrue([initialTime isEqualToDate:baseAlarm.dateAndTime], @"AlarmDate is ok");
}

-(void) testAlarmSeverityComparison {
    NSNumber* severityCritical = [NSNumber numberWithUnsignedInteger:Critical];
    NSDictionary* criticalAlarmDictionary = @{@"severity" : severityCritical,
                                      @"probableCause": @"Fire Detected",
                                      @"dateAndTime": @0,
                                      @"alarmType": @0,
                                      @"additionalText": @"the Additional Text",
                                      @"isAcknowledged": @TRUE};

    CellAlarm* criticalAlarm = [[CellAlarm alloc] initWithAlarmData:criticalAlarmDictionary];

    NSNumber* severityMinor = [NSNumber numberWithUnsignedInteger:Minor];
    NSDictionary* minorAlarmDictionary = @{@"severity" : severityMinor,
                                      @"probableCause": @"Fire Detected",
                                      @"dateAndTime": @0,
                                      @"alarmType": @0,
                                      @"additionalText": @"the Additional Text",
                                      @"isAcknowledged": @TRUE};

    CellAlarm* minorAlarm = [[CellAlarm alloc] initWithAlarmData:minorAlarmDictionary];

    XCTAssertTrue([criticalAlarm compareWithSeverity:minorAlarm] == NSOrderedAscending, @"AlarmComparisonSeverity ascending ok");
    XCTAssertTrue([criticalAlarm compareWithSeverity:criticalAlarm] == NSOrderedSame, @"AlarmComparisonSeverity same ok");
    XCTAssertTrue([minorAlarm compareWithSeverity:criticalAlarm] == NSOrderedDescending, @"AlarmComparisonSeverity descending ok");
}

-(void) testAlarmDateComparison {
    NSDictionary* oldAlarmDictionary = @{@"severity" : @0,
                                              @"probableCause": @"Fire Detected",
                                              @"dateAndTime": @0,
                                              @"alarmType": @0,
                                              @"additionalText": @"the Additional Text",
                                              @"isAcknowledged": @TRUE};

    CellAlarm* oldAlarm = [[CellAlarm alloc] initWithAlarmData:oldAlarmDictionary];

    unsigned long value = 60UL*60UL*24UL*365UL*20UL*1000UL; // Multiply by 1000 because the interface use milliseconds instead of seconds
    NSNumber* doubleForDate = [NSNumber numberWithUnsignedLong:value];
    NSDictionary* newAlarmDictionary = @{@"severity" : @0,
                                           @"probableCause": @"Fire Detected",
                                           @"dateAndTime": doubleForDate,
                                           @"alarmType": @0,
                                           @"additionalText": @"the Additional Text",
                                           @"isAcknowledged": @TRUE};

    CellAlarm* newAlarm = [[CellAlarm alloc] initWithAlarmData:newAlarmDictionary];

    XCTAssertTrue([newAlarm compareWithDateAndTime:oldAlarm] == NSOrderedAscending, @"AlarmComparisonDate ascending ok");
    XCTAssertTrue([newAlarm compareWithDateAndTime:newAlarm] == NSOrderedSame, @"AlarmComparisonDate same ok");
    XCTAssertTrue([oldAlarm compareWithDateAndTime:newAlarm] == NSOrderedDescending, @"AlarmComparisonDate descending ok");

}

- (void)testAlarmSeverity
{
    for (AlarmSeverityId i = 0; i < 5; i++) {

        NSNumber* severity = [NSNumber numberWithUnsignedInteger:i];
        NSDictionary* alarmDictionary = @{@"severity" : severity,
                                          @"probableCause": @"Fire Detected",
                                          @"dateAndTime": @0,
                                          @"alarmType": @0,
                                          @"additionalText": @"the Additional Text",
                                          @"isAcknowledged": @TRUE};

        CellAlarm* baseAlarm = [[CellAlarm alloc] initWithAlarmData:alarmDictionary];

        NSString* alarmString = Nil;
        switch (i) {
            case Cleared: {
                XCTAssertTrue(baseAlarm.severity == Cleared, @"AlarmSeverityId is ok");
                alarmString = @"Cleared";
                break;
            }
            case Minor: {
                XCTAssertTrue(baseAlarm.severity == Minor, @"AlarmSeverityId is ok");
                alarmString = @"Minor";
                break;
            }
            case Major: {
                XCTAssertTrue(baseAlarm.severity == Major, @"AlarmSeverityId is ok");
                alarmString = @"Major";
                break;
            }
            case Critical: {
                XCTAssertTrue(baseAlarm.severity == Critical, @"AlarmSeverityId is ok");
                alarmString = @"Critical";
                break;
            }
            case Warning: {
                XCTAssertTrue(baseAlarm.severity == Warning, @"AlarmSeverityId is ok");
                alarmString = @"Warning";
                break;
            }
            default: {
                XCTFail(@"Unknown Alarm severity");
            }
        }
        XCTAssertTrue([baseAlarm.severityIdNumber integerValue] == i , @"AlarmSeverityIdNumber ok");
        XCTAssertNotNil(baseAlarm.severityLightColor, @"SeverityLightColor ok");
        XCTAssertNotNil(baseAlarm.severityColor, @"SeverityColor ok");
        XCTAssertNotNil(baseAlarm.severityHTMLColor, @"SeverityHTMLColor ok");

        XCTAssertTrue([baseAlarm.severityString isEqualToString:alarmString], @"AlarmSeverityString ok");
    }
    
}

- (void) testAlarmType {
    for (AlarmTypeId i = 0; i < 6; i++) {

        NSNumber* alarmType = [NSNumber numberWithUnsignedInteger:i];
        NSDictionary* alarmDictionary = @{@"severity" : @0,
                                          @"probableCause": @"Fire Detected",
                                          @"dateAndTime": @0,
                                          @"alarmType": alarmType,
                                          @"additionalText": @"the Additional Text",
                                          @"isAcknowledged": @TRUE};
        CellAlarm* baseAlarm = [[CellAlarm alloc] initWithAlarmData:alarmDictionary];

        NSString* alarmTypeString = Nil;

        switch (i) {
            case Other: {
                XCTAssertTrue(baseAlarm.alarmType == Other, @"AlarmTypeId is ok");
                alarmTypeString = @"Other";
                break;
            }
            case CommunicationAlarm: {
                XCTAssertTrue(baseAlarm.alarmType == CommunicationAlarm, @"AlarmTypeId is ok");
                alarmTypeString = @"Communication alarm";
                break;
            }
            case QualityOfServiceAlarm: {
                XCTAssertTrue(baseAlarm.alarmType == QualityOfServiceAlarm, @"AlarmTypeId is ok");
                alarmTypeString = @"Quality of service alarm";
                break;
            }
            case ProcessingErrorAlarm: {
                XCTAssertTrue(baseAlarm.alarmType == ProcessingErrorAlarm, @"AlarmTypeId is ok");
                alarmTypeString = @"Processing error alarm";
                break;
            }
            case EnvironmentalAlarm: {
                XCTAssertTrue(baseAlarm.alarmType == EnvironmentalAlarm, @"AlarmTypeId is ok");
                alarmTypeString = @"Environmental alarm";
                break;
            }
            default: {
                XCTAssertTrue(baseAlarm.alarmType == Unknown, @"AlarmTypeId is ok");
                alarmTypeString = @"Unknown";
            }
        }

        XCTAssertTrue([baseAlarm.alarmTypeString isEqualToString:alarmTypeString], @"Alarm Type ok");
    }

}



@end
