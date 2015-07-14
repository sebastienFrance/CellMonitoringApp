//
//  AttributeNameValueTests.m
//  iMonitoring
//
//  Created by sébastien brugalières on 09/02/13.
//
//

#import "AttributeNameValueTests.h"
#import "AttributeNameValue.h"


@interface AttributeNameValueTests()

@property(nonatomic) AttributeNameValue* theAttrNameValue;

@end

@implementation AttributeNameValueTests

- (void)setUp
{
    [super setUp];
    
    self.theAttrNameValue = [[AttributeNameValue alloc] initWithNameValue:@"theKey"
                                                                value:@"theValue"
                                                              section:@"theSection"];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    
    XCTAssertEqualObjects(self.theAttrNameValue.name, @"theKey", @"Error key has not the appropriate value");
}

- (void)testAttributeNameValueClass
{
    XCTAssertEqualObjects(self.theAttrNameValue.value, @"theValue", @"Error key has not the appropriate value");
}

- (void)testAttributeNameValueSectionClass
{
    XCTAssertEqualObjects(self.theAttrNameValue.section, @"theSection", @"Error key has not the appropriate value");
}


@end
