//
//  DateUtilityTests.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 18/05/2014.
//
//

#import <XCTest/XCTest.h>
#import "DateUtility.h"

@interface DateUtilityTests : XCTestCase

@property(nonatomic) NSDateFormatter* format;
@property(nonatomic) NSDate*  testDate;

@end

@implementation DateUtilityTests

- (void)setUp
{
    [super setUp];

    self.format = [[NSDateFormatter alloc] init];
    NSTimeZone* timezone = [NSTimeZone timeZoneWithName:@"CEST"];
    [self.format setTimeZone:timezone];


    [self.format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    self.testDate = [self.format dateFromString:@"2014-05-18 21:03:32"];

    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetDateMethods
{

    NSDate* dateBeFore15MinGP = [self.format dateFromString:@"2014-05-18 09:12:32"];
    NSDate* dateAligned15MinGP = [self.format dateFromString:@"2014-05-18 08:45:32"];
    NSDate* resultDate = [DateUtility getDateNear15mn:Nil];
    XCTAssertNil(resultDate, @"getDateNear15mn returned Nil with initial date nil");

    resultDate = [DateUtility getDateNear15mn:dateBeFore15MinGP];
    XCTAssertTrue([resultDate isEqualToDate:dateAligned15MinGP], @"Date aligned correctly with previous GP");

    NSDate* dateAfterMinGP = [self.format dateFromString:@"2014-05-18 09:15:32"];
    NSDate* dateAligned15MinLaterGP = [self.format dateFromString:@"2014-05-18 09:00:32"];
    resultDate = [DateUtility getDateNear15mn:dateAfterMinGP];
    XCTAssertTrue([resultDate isEqualToDate:dateAligned15MinLaterGP], @"Date aligned correctly with next GP");

    NSString* nilString = [DateUtility getDate:Nil option:withHHmmss];
    XCTAssertNil(nilString, @"getDate returned Nil with initial date nil");

    NSString* dateStringResult = [DateUtility getDate:self.testDate option:withHHmmss];
    XCTAssertTrue([dateStringResult isEqualToString:@"2014-05-18 21:03:32"], @"getDate withHHmmss format is ok");
    XCTAssertFalse([dateStringResult isEqualToString:@"2014-05-18 21:03:00"], @"getDate withHHmmss format is ok");

    dateStringResult = [DateUtility getDate:self.testDate option:withHHmm];
    XCTAssertTrue([dateStringResult isEqualToString:@"2014-05-18 21:03"], @"getDate withHHmm format is ok");
    XCTAssertFalse([dateStringResult isEqualToString:@"2014-05-18 21:03:00"], @"getDate withHHmm format is ok");

    dateStringResult = [DateUtility getDate:self.testDate option:withHH00];
    XCTAssertTrue([dateStringResult isEqualToString:@"2014-05-18 21:00"], @"getDate withHH00 format is ok");
    XCTAssertFalse([dateStringResult isEqualToString:@"2014-05-18 21:03"], @"getDate withHH00 format is ok");

    nilString = [DateUtility getDateWithTimeZone:Nil timezone:@"UTC" option:withHHmmss];
    XCTAssertNil(nilString, @"getDateWithTimeZone returned Nil with initial date nil");

    dateStringResult = [DateUtility getDateWithTimeZone:self.testDate timezone:@"UTC" option:withHHmmss];
    XCTAssertTrue([dateStringResult isEqualToString:@"2014-05-18 19:03:32"], @"getDate withHHmmss format with timezone UTC is ok");
    XCTAssertFalse([dateStringResult isEqualToString:@"2014-05-18 21:03:32"], @"getDate withHHmmss format with timezone UTC is ok");

    nilString = [DateUtility getGMTDate:Nil];
    XCTAssertNil(nilString, @"getGMTDate returned Nil with initial date nil");

    dateStringResult = [DateUtility getGMTDate:self.testDate];
    XCTAssertTrue([dateStringResult isEqualToString:@"2014.05.18 19.03"], @"getGMTDate is ok");

}

- (void)testMinusDateComputation
{
    NSString* dateStringResult = [DateUtility getDayMinusNumberOfDay:self.testDate minusDay:0 shortFormat:FALSE];
    XCTAssertTrue([dateStringResult isEqualToString:@"Sunday"], @"getDayMinusNumberOfDay with Long Format is ok");

    dateStringResult = [DateUtility getDayMinusNumberOfDay:Nil minusDay:0 shortFormat:TRUE];
    XCTAssertTrue([dateStringResult isEqualToString:@"Wrong date"], @"getDayMinusNumberOfDay with short Format is ok");

    dateStringResult = [DateUtility getDayMinusNumberOfDay:self.testDate minusDay:0 shortFormat:TRUE];
    XCTAssertTrue([dateStringResult isEqualToString:@"Sun"], @"getDayMinusNumberOfDay with short Format is ok");

    dateStringResult = [DateUtility getDayMinusNumberOfDay:self.testDate minusDay:8 shortFormat:FALSE];
    XCTAssertTrue([dateStringResult isEqualToString:@"Saturday"], @"getDayMinusNumberOfDay with Long Format is ok");

    dateStringResult = [DateUtility getDayMinusNumberOfDay:self.testDate minusDay:8 shortFormat:TRUE];
    XCTAssertTrue([dateStringResult isEqualToString:@"Sat"], @"getDayMinusNumberOfDay with short Format is ok");

    dateStringResult = [DateUtility getMonthMinusNumberOfMonth:Nil minusMonth:0 shortFormat:TRUE];
    XCTAssertTrue([dateStringResult isEqualToString:@"Wrong date"], @"getMonthMinusNumberOfMonth with short Format is ok");

    dateStringResult = [DateUtility getMonthMinusNumberOfMonth:self.testDate minusMonth:0 shortFormat:FALSE];
    XCTAssertTrue([dateStringResult isEqualToString:@"May"], @"getMonthMinusNumberOfMonth with Long Format is ok");

    dateStringResult = [DateUtility getMonthMinusNumberOfMonth:self.testDate minusMonth:0 shortFormat:TRUE];
    XCTAssertTrue([dateStringResult isEqualToString:@"May"], @"getMonthMinusNumberOfMonth with short Format is ok");

    dateStringResult = [DateUtility getMonthMinusNumberOfMonth:self.testDate minusMonth:3 shortFormat:FALSE];
    XCTAssertTrue([dateStringResult isEqualToString:@"February"], @"getMonthMinusNumberOfMonth with Long Format is ok");

    dateStringResult = [DateUtility getMonthMinusNumberOfMonth:self.testDate minusMonth:3 shortFormat:TRUE];
    XCTAssertTrue([dateStringResult isEqualToString:@"Feb"], @"getMonthMinusNumberOfMonth with short Format is ok");

    dateStringResult = [DateUtility getWeekMinusNumberOfWeek:Nil minusWeek:0 shortFormat:TRUE];
    XCTAssertTrue([dateStringResult isEqualToString:@"Wrong date"], @"getWeekMinusNumberOfWeek with short Format is ok");

    dateStringResult = [DateUtility getWeekMinusNumberOfWeek:self.testDate minusWeek:0 shortFormat:FALSE];
    XCTAssertTrue([dateStringResult isEqualToString:@"week 21"], @"getWeekMinusNumberOfWeek with Long Format is ok");

    dateStringResult = [DateUtility getWeekMinusNumberOfWeek:self.testDate minusWeek:0 shortFormat:TRUE];
    XCTAssertTrue([dateStringResult isEqualToString:@"w21"], @"getWeekMinusNumberOfWeek with short Format is ok");

    dateStringResult = [DateUtility getWeekMinusNumberOfWeek:self.testDate minusWeek:3 shortFormat:FALSE];
    XCTAssertTrue([dateStringResult isEqualToString:@"week 18"], @"getWeekMinusNumberOfWeek with Long Format is ok");

    dateStringResult = [DateUtility getWeekMinusNumberOfWeek:self.testDate minusWeek:3 shortFormat:TRUE];
    XCTAssertTrue([dateStringResult isEqualToString:@"w18"], @"getWeekMinusNumberOfWeek with short Format is ok");

    dateStringResult = [DateUtility getWeekMinusNumberOfWeek:self.testDate minusWeek:22 shortFormat:FALSE];
    XCTAssertTrue([dateStringResult isEqualToString:@"week 51"], @"getWeekMinusNumberOfWeek with Long Format is ok");

    dateStringResult = [DateUtility getWeekMinusNumberOfWeek:self.testDate minusWeek:22 shortFormat:TRUE];
    XCTAssertTrue([dateStringResult isEqualToString:@"w51"], @"getWeekMinusNumberOfWeek with short Format is ok");

    dateStringResult = [DateUtility getDayMonthMinusNumberOfDay:Nil minusDay:0 shortFormat:TRUE];
    XCTAssertTrue([dateStringResult isEqualToString:@"Wrong date"], @"getDayMonthMinusNumberOfDay with short Format is ok");

    dateStringResult = [DateUtility getDayMonthMinusNumberOfDay:self.testDate minusDay:0 shortFormat:FALSE];
    XCTAssertTrue([dateStringResult isEqualToString:@"18 May"], @"getDayMonthMinusNumberOfDay with Long Format is ok");

    dateStringResult = [DateUtility getDayMonthMinusNumberOfDay:self.testDate minusDay:0 shortFormat:TRUE];
    XCTAssertTrue([dateStringResult isEqualToString:@"18 May"], @"getDayMonthMinusNumberOfDay with short Format is ok");

    dateStringResult = [DateUtility getDayMonthMinusNumberOfDay:self.testDate minusDay:138 shortFormat:FALSE];
    XCTAssertTrue([dateStringResult isEqualToString:@"31 December"], @"getDayMonthMinusNumberOfDay with Long Format is ok");

    dateStringResult = [DateUtility getDayMonthMinusNumberOfDay:self.testDate minusDay:138 shortFormat:TRUE];
    XCTAssertTrue([dateStringResult isEqualToString:@"31 Dec"], @"getDayMonthMinusNumberOfDay with short Format is ok");

    dateStringResult = [DateUtility getYearMinusNumberOfMonth:Nil minusMonth:0 shortFormat:TRUE];
    XCTAssertTrue([dateStringResult isEqualToString:@"Wrong date"], @"getYearMinusNumberOfMonth with short Format is ok");

    dateStringResult = [DateUtility getYearMinusNumberOfMonth:self.testDate minusMonth:0 shortFormat:FALSE];
    XCTAssertTrue([dateStringResult isEqualToString:@"2014"], @"getYearMinusNumberOfMonth with Long Format is ok");

    dateStringResult = [DateUtility getYearMinusNumberOfMonth:self.testDate minusMonth:0 shortFormat:TRUE];
    XCTAssertTrue([dateStringResult isEqualToString:@"14"], @"getYearMinusNumberOfMonth with short Format is ok");

    dateStringResult = [DateUtility getYearMinusNumberOfMonth:self.testDate minusMonth:1 shortFormat:FALSE];
    XCTAssertTrue([dateStringResult isEqualToString:@"2014"], @"getYearMinusNumberOfMonth with Long Format is ok");

    dateStringResult = [DateUtility getYearMinusNumberOfMonth:self.testDate minusMonth:1 shortFormat:TRUE];
    XCTAssertTrue([dateStringResult isEqualToString:@"14"], @"getYearMinusNumberOfMonth with short Format is ok");

    dateStringResult = [DateUtility getYearMinusNumberOfMonth:self.testDate minusMonth:5 shortFormat:FALSE];
    XCTAssertTrue([dateStringResult isEqualToString:@"2013"], @"getYearMinusNumberOfMonth with Long Format is ok");

    dateStringResult = [DateUtility getYearMinusNumberOfMonth:self.testDate minusMonth:5 shortFormat:TRUE];
    XCTAssertTrue([dateStringResult isEqualToString:@"13"], @"getYearMinusNumberOfMonth with short Format is ok");
    
}
- (void)testDurationToString
{
    NSString* stringResult = [DateUtility getDurationToString:3600 withSeconds:TRUE];
    XCTAssertTrue([stringResult isEqualToString:@"01h00mn00s"], @"getDayMinusNumberOfDay with Long Format is ok");

    stringResult = [DateUtility getDurationToString:3665 withSeconds:TRUE];
    XCTAssertTrue([stringResult isEqualToString:@"01h01mn05s"], @"getDayMinusNumberOfDay with Long Format is ok");
}

@end
