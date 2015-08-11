//
//  CellMonitoringUITests.m
//  CellMonitoringUITests
//
//  Created by Sébastien Brugalières on 09/08/2015.
//
//

#import <XCTest/XCTest.h>

@interface CellMonitoringUITests : XCTestCase

@end

@implementation CellMonitoringUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    XCUIElement *passwordSecureTextField = app.secureTextFields[@"password"];
    [passwordSecureTextField tap];
    [passwordSecureTextField tap];
    [passwordSecureTextField typeText:@"iMonitoring1234"];
    
    XCUIElementQuery *toolbarsQuery = app.toolbars;
    [toolbarsQuery.buttons[@"Done"] tap];
    [toolbarsQuery.buttons[@"Search"] tap];
    [app.tables[@"Empty list"].buttons[@"WCDMA"] tap];
    
    XCUIElement *cellNameSearchField = app.searchFields[@"Cell name"];
    [cellNameSearchField tap];
    [cellNameSearchField typeText:@"fr_"];
    [[[[[[[[[[app childrenMatchingType:XCUIElementTypeWindow] elementBoundByIndex:0] childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther] elementBoundByIndex:1] tap];
    [app.buttons[@"More Info"] tap];
    
    XCUIElementQuery *tablesQuery = app.tables;
    [tablesQuery.staticTexts[@"Display main cell parameters"] swipeUp];
    [[[[[tablesQuery.cells containingType:XCUIElementTypeStaticText identifier:@"Connection Success Rate"] childrenMatchingType:XCUIElementTypeStaticText] matchingIdentifier:@"91.08% (-15Min: 93.35%)"] elementBoundByIndex:0] tap];
    
}

@end
