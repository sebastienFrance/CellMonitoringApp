//
//  iMonitoringTests.m
//  iMonitoringTests
//
//  Created by sébastien brugalières on 09/02/13.
//
//

#import "KPITests.h"
#import "KPI.h"


@interface KPITests()

@property (nonatomic) KPI* theSimpleKPI;
@property (nonatomic) KPI* theKPIWithoutThreshold;
@property (nonatomic) KPI* theSevIncreaseWithLowerValueKPI;
@property (nonatomic) KPI* theSevIncreaseWithHigherValueKPI;

@end

@implementation KPITests


//KPI dictionary structure:
//KPIDictionaries[x].name = name of the dictionary
//KPIDictionaries[x].descripton = description of the dictionary
//KPIDictionaries[x].KPIs[y].techno = Tehcnology of the KPIs
//KPIDictionaries[x].KPIs[y].KPIs[z].name = external name of the KPI
//KPIDictionaries[x].KPIs[y].KPIs[z].internalName
//KPIDictionaries[x].KPIs[y].KPIs[z].shortDescription
//KPIDictionaries[x].KPIs[y].KPIs[z].domain
//KPIDictionaries[x].KPIs[y].KPIs[z].formula
//KPIDictionaries[x].KPIs[y].KPIs[z].unit
//KPIDictionaries[x].KPIs[y].KPIs[z].direction
//KPIDictionaries[x].KPIs[y].KPIs[z].low
//KPIDictionaries[x].KPIs[y].KPIs[z].medium
//KPIDictionaries[x].KPIs[y].KPIs[z].high
//KPIDictionaries[x].KPIs[y].KPIs[z].relatedKPI

- (void)setUp
{
    [super setUp];
 
    
    
    NSDictionary* simpleKPI = @{@"name": @"Request",
                               @"internalName": @"internal_request_name",
                               @"shortDescription": @"a big number of request",
                               @"formula": @"Request",
                               @"domain": @"connection",
                               @"unit": @"Req",
                               @"direction": @"",
                               @"low": @"",
                               @"medium": @"",
                               @"high": @"",
                               @"relatedKPI": @""};
    
    self.theSimpleKPI = [[KPI alloc] init:simpleKPI techno:@"LTE"];

    NSDictionary* KPIWithoutThreshold = @{@"name": @"Success Rate",
                               @"internalName": @"internal_success_rate",
                               @"shortDescription": @"a big success",
                               @"formula": @"Sucess / Request",
                               @"domain": @"connection",
                               @"unit": @"%",
                               @"direction": @"",
                               @"low": @"",
                               @"medium": @"",
                               @"high": @"",
                               @"relatedKPI": @""};
    self.theKPIWithoutThreshold = [[KPI alloc] init:KPIWithoutThreshold techno:@"LTE"];

    NSDictionary* SevIncreaseWithLowerValueKPI = @{@"name": @"Success Rate",
                                         @"internalName": @"internal_success_rate",
                                         @"shortDescription": @"a big success",
                                         @"formula": @"Sucess / Request",
                                         @"domain": @"connection",
                                         @"unit": @"%",
                                         @"direction": @"decrease",
                                         @"low": @"98.0",
                                         @"medium": @"96.0",
                                         @"high": @"95.0",
                                         @"relatedKPI": @""};
    self.theSevIncreaseWithLowerValueKPI = [[KPI alloc] init:SevIncreaseWithLowerValueKPI techno:@"WCDMA"];

    NSDictionary* SevIncreaseWithHigherValueKPI = @{@"name": @"Failure Rate",
                                                  @"internalName": @"internal_failure_rate",
                                                  @"shortDescription": @"a big failure",
                                                  @"formula": @"Failure / Request",
                                                  @"domain": @"connection",
                                                  @"unit": @"%",
                                                  @"direction": @"increase",
                                                  @"low": @"1.0",
                                                  @"medium": @"2.5",
                                                  @"high": @"5.0",
                                                  @"relatedKPI": @""};
    self.theSevIncreaseWithHigherValueKPI = [[KPI alloc] init:SevIncreaseWithHigherValueKPI techno:@"GSM"];


}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}


- (void)testProperties
{
    XCTAssertEqualObjects(self.theKPIWithoutThreshold.name, @"Success Rate", @"Error name properties has not the appropriate value");
    XCTAssertEqualObjects(self.theKPIWithoutThreshold.internalName, @"internal_success_rate", @"Error internalName properties has not the appropriate value");
    XCTAssertEqualObjects(self.theKPIWithoutThreshold.shortDescription, @"a big success", @"Error shortDescription properties has not the appropriate value");
    XCTAssertEqualObjects(self.theKPIWithoutThreshold.formula, @"Sucess / Request", @"Error formula properties has not the appropriate value");
    XCTAssertEqualObjects(self.theKPIWithoutThreshold.domain, @"connection", @"Error domain properties has not the appropriate value");
    XCTAssertEqualObjects(self.theKPIWithoutThreshold.techno, @"LTE", @"Error techno properties has not the appropriate value");

    XCTAssertEqualObjects(self.theKPIWithoutThreshold.unit, @"%", @"Error unit properties has not the appropriate value");
    XCTAssertEqualObjects(self.theSimpleKPI.unit, @"Req", @"Error unit properties has not the appropriate value");
    
    // Check KPI techno
    
    XCTAssertTrue(self.theKPIWithoutThreshold.technology == DCTechnologyLTE, @"Error it's not a LTE KPI");
    XCTAssertTrue(self.theKPIWithoutThreshold.technology != DCTechnologyWCDMA, @"Error it's a WCDMA KPI");
    XCTAssertTrue(self.theKPIWithoutThreshold.technology != DCTechnologyGSM, @"Error it's a GSM KPI");

    XCTAssertTrue(self.theSevIncreaseWithLowerValueKPI.technology != DCTechnologyLTE, @"Error it's a LTE KPI");
    XCTAssertTrue(self.theSevIncreaseWithLowerValueKPI.technology == DCTechnologyWCDMA, @"Error it's not a WCDMA KPI");
    XCTAssertTrue(self.theSevIncreaseWithLowerValueKPI.technology != DCTechnologyGSM, @"Error it's a GSM KPI");

    XCTAssertTrue(self.theSevIncreaseWithHigherValueKPI.technology != DCTechnologyLTE, @"Error it's a LTE KPI");
    XCTAssertTrue(self.theSevIncreaseWithHigherValueKPI.technology != DCTechnologyWCDMA, @"Error it's a WCDMA KPI");
    XCTAssertTrue(self.theSevIncreaseWithHigherValueKPI.technology == DCTechnologyGSM, @"Error it's not a GSM KPI");
    
    // Check Direction 
    XCTAssertTrue(self.theSimpleKPI.hasDirection == FALSE, @"Error KPI has a direction");
    XCTAssertTrue(self.theSevIncreaseWithLowerValueKPI.hasDirection == TRUE, @"Error KPI has no direction");
    
    XCTAssertTrue(self.theSevIncreaseWithHigherValueKPI.isDirectionIncrease == TRUE, @"Error KPI direction doesn't increase");
    XCTAssertTrue(self.theSevIncreaseWithLowerValueKPI.isDirectionIncrease == FALSE, @"Error KPI direction increase");

    // Check Threshold
    XCTAssertEqual(self.theSevIncreaseWithLowerValueKPI.lowThreshold, (float) 98.0, @"Error low Threshold has not the appropriate value");
    XCTAssertEqual(self.theSevIncreaseWithLowerValueKPI.mediumThreshold, (float) 96.0, @"Error low Threshold has not the appropriate value");
    XCTAssertEqual(self.theSevIncreaseWithLowerValueKPI.highThreshold, (float) 95.0, @"Error low Threshold has not the appropriate value");
}

- (void) testValue {
    XCTAssertTrue([self.theKPIWithoutThreshold getKPIValueFromNumber:Nil] == 0.0, @"Error KPI with nil doesn't return 0.0");
    XCTAssertEqual([self.theKPIWithoutThreshold getKPIValueFromNumber:@(99.5f)], (float)0.995, @"Error KPI value not returning right value for %%");
    
    XCTAssertEqualObjects([self.theKPIWithoutThreshold getDisplayableValueFromNumber:@99.553f], @"99.55%", @"Error KPI value not correctly formated for Display");
    XCTAssertEqualObjects([self.theKPIWithoutThreshold getHTMLDisplayableValueFromNumber:@99.553f], @"99.55&#37;", @"Error KPI value not correctly formated for Display");

    XCTAssertEqualObjects([self.theKPIWithoutThreshold getDisplayableValueFromNumber:Nil], @"No Value", @"Error KPI value not correctly formated for Display");
    XCTAssertEqualObjects([self.theKPIWithoutThreshold getHTMLDisplayableValueFromNumber:Nil], @"No Value", @"Error KPI value not correctly formated for Display");
    
    XCTAssertEqualObjects([self.theKPIWithoutThreshold getColorValueFromNumber:nil], [UIColor lightGrayColor], @"Bad default color when no value");
    XCTAssertEqualObjects([self.theKPIWithoutThreshold getColorValueFromNumber:@99.5f], [UIColor lightGrayColor], @"Bad default color when value without thresholds");

    XCTAssertEqual([self.theKPIWithoutThreshold getColorIdFromNumber:nil], KPIColorwhite, @"Bad default colorId when no value");
    XCTAssertEqual([self.theKPIWithoutThreshold getColorIdFromNumber:@99.5f], KPIColorgreen, @"Bad default colorId when value without thresholds");
}

- (void) testColor {
    
    // For % without thresholds
    XCTAssertEqualObjects([self.theKPIWithoutThreshold getColorValueFromNumber:nil], [UIColor lightGrayColor], @"Bad default color when no value");
    XCTAssertEqualObjects([self.theKPIWithoutThreshold getColorValueFromNumber:@99.5f], [UIColor lightGrayColor], @"Bad default color when value without thresholds");
    
    XCTAssertEqual([self.theKPIWithoutThreshold getColorIdFromNumber:nil], KPIColorwhite, @"Bad default colorId when no value");
    XCTAssertEqual([self.theKPIWithoutThreshold getColorIdFromNumber:@99.5f], KPIColorgreen, @"Bad default colorId when value without thresholds");

    XCTAssertEqualObjects([self.theKPIWithoutThreshold getHTMLColorFromNumber:nil], @"white", @"bad default HTML color when no value");
    XCTAssertEqualObjects([self.theKPIWithoutThreshold getHTMLColorFromNumber:@99.5f], @"green", @"bad default HTML color when no value");
   
    // For % with increase Threshold
    XCTAssertEqualObjects([self.theSevIncreaseWithLowerValueKPI getColorValueFromNumber:@99.5f], [UIColor greenColor], @"Bad color when value higher than lower threshold");
    XCTAssertEqualObjects([self.theSevIncreaseWithLowerValueKPI getColorValueFromNumber:@98.0f], [UIColor greenColor], @"Bad color when value is equal to lower threshold");
    XCTAssertEqualObjects([self.theSevIncreaseWithLowerValueKPI getColorValueFromNumber:@97.0f], [UIColor yellowColor], @"Bad color when value is equal to medium threshold");
    XCTAssertEqualObjects([self.theSevIncreaseWithLowerValueKPI getColorValueFromNumber:@95.0f], [UIColor orangeColor], @"Bad color when value is equal to lower threshold");
    XCTAssertEqualObjects([self.theSevIncreaseWithLowerValueKPI getColorValueFromNumber:@94.0f], [UIColor redColor], @"Bad color when value lower than high threshold");
    
    XCTAssertEqual([self.theSevIncreaseWithLowerValueKPI getColorIdFromNumber:@99.5f], KPIColorgreen, @"Bad colorId when value higher than lower threshold");
    XCTAssertEqual([self.theSevIncreaseWithLowerValueKPI getColorIdFromNumber:@98.0f], KPIColorgreen, @"Bad colorId when value is equal to lower threshold");
    XCTAssertEqual([self.theSevIncreaseWithLowerValueKPI getColorIdFromNumber:@97.0f], KPIColoryellow, @"Bad colorId when value is equal to medium threshold");
    XCTAssertEqual([self.theSevIncreaseWithLowerValueKPI getColorIdFromNumber:@95.0f], KPIColororange, @"Bad colorId when value is equal to lower threshold");
    XCTAssertEqual([self.theSevIncreaseWithLowerValueKPI getColorIdFromNumber:@94.0f], KPIColorred, @"Bad colorId when value lower than high threshold");
    
    XCTAssertEqualObjects([self.theSevIncreaseWithLowerValueKPI getHTMLColorFromNumber:@99.5f], @"green", @"Bad HTML color when value higher than lower threshold");
    XCTAssertEqualObjects([self.theSevIncreaseWithLowerValueKPI getHTMLColorFromNumber:@98.0f], @"green", @"Bad HTML color when value is equal to lower threshold");
    XCTAssertEqualObjects([self.theSevIncreaseWithLowerValueKPI getHTMLColorFromNumber:@97.0f], @"yellow", @"Bad HTML color when value is equal to medium threshold");
    XCTAssertEqualObjects([self.theSevIncreaseWithLowerValueKPI getHTMLColorFromNumber:@95.0f], @"orange", @"Bad HTML color when value is equal to lower threshold");
    XCTAssertEqualObjects([self.theSevIncreaseWithLowerValueKPI getHTMLColorFromNumber:@94.0f], @"red", @"Bad HTML color when value lower than high threshold");
 
    // For % with decrease Threshold
    XCTAssertEqualObjects([self.theSevIncreaseWithHigherValueKPI getColorValueFromNumber:@0.25f], [UIColor greenColor], @"Bad color when value lower than lower threshold");
    XCTAssertEqualObjects([self.theSevIncreaseWithHigherValueKPI getColorValueFromNumber:@1.0f], [UIColor greenColor], @"Bad color when value is equal to lower threshold");
    XCTAssertEqualObjects([self.theSevIncreaseWithHigherValueKPI getColorValueFromNumber:@2.5f], [UIColor yellowColor], @"Bad color when value is equal to medium threshold");
    XCTAssertEqualObjects([self.theSevIncreaseWithHigherValueKPI getColorValueFromNumber:@5.0f], [UIColor orangeColor], @"Bad color when value is equal to lower threshold");
    XCTAssertEqualObjects([self.theSevIncreaseWithHigherValueKPI getColorValueFromNumber:@6.5f], [UIColor redColor], @"Bad color when value greater than high threshold");
    
    XCTAssertEqual([self.theSevIncreaseWithHigherValueKPI getColorIdFromNumber:@0.25f], KPIColorgreen, @"Bad colorId when value higher than lower threshold");
    XCTAssertEqual([self.theSevIncreaseWithHigherValueKPI getColorIdFromNumber:@1.0f], KPIColorgreen, @"Bad colorId when value is equal to lower threshold");
    XCTAssertEqual([self.theSevIncreaseWithHigherValueKPI getColorIdFromNumber:@2.5f], KPIColoryellow, @"Bad colorId when value is equal to medium threshold");
    XCTAssertEqual([self.theSevIncreaseWithHigherValueKPI getColorIdFromNumber:@5.0f], KPIColororange, @"Bad colorId when value is equal to lower threshold");
    XCTAssertEqual([self.theSevIncreaseWithHigherValueKPI getColorIdFromNumber:@6.5f], KPIColorred, @"Bad colorId when value lower than high threshold");
    
    XCTAssertEqualObjects([self.theSevIncreaseWithHigherValueKPI getHTMLColorFromNumber:@0.25f], @"green", @"Bad HTML color when value higher than lower threshold");
    XCTAssertEqualObjects([self.theSevIncreaseWithHigherValueKPI getHTMLColorFromNumber:@1.0f], @"green", @"Bad HTML color when value is equal to lower threshold");
    XCTAssertEqualObjects([self.theSevIncreaseWithHigherValueKPI getHTMLColorFromNumber:@2.5f], @"yellow", @"Bad HTML color when value is equal to medium threshold");
    XCTAssertEqualObjects([self.theSevIncreaseWithHigherValueKPI getHTMLColorFromNumber:@5.0f], @"orange", @"Bad HTML color when value is equal to lower threshold");
    XCTAssertEqualObjects([self.theSevIncreaseWithHigherValueKPI getHTMLColorFromNumber:@6.5f], @"red", @"Bad HTML color when value lower than high threshold");
    
}

@end
