//
//  PasswordUtilityTests.m
//  CellMonitoring
//
//  Created by sébastien brugalières on 25/04/2014.
//
//

#import <XCTest/XCTest.h>
#import "PasswordUtility.h"

@interface PasswordUtilityTests : XCTestCase

@end

@implementation PasswordUtilityTests

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

- (void)testcheckPasswordValidity
{
    XCTAssertTrue([PasswordUtility checkPasswordValidity:@"ItIsPassword" retype:@"ItIsPassword"], @"Password is validated as compliant");
    XCTAssertFalse([PasswordUtility checkPasswordValidity:Nil retype:Nil], @"Password is not compliant because nil");
    XCTAssertFalse([PasswordUtility checkPasswordValidity:@"" retype:@""], @"Password is not compliant because empty");
    XCTAssertEqual(MainPasswordTooShort, [PasswordUtility checkPasswordValidity:@"toto" retype:@"toto"], @"Password is not compliant because too short");
    XCTAssertEqual(MainRetypePasswordNotEquals, [PasswordUtility checkPasswordValidity:@"ItIsPassword" retype:@"OtherPassword"], @"Password is not compliant because they are differents");
}

- (void)testcheckUserNameValidity
{
    XCTAssertTrue([PasswordUtility checkUserNameValidity:@"abcdef"], @"Username is compliant");
    XCTAssertTrue([PasswordUtility checkUserNameValidity:@"abcde1"], @"Username is compliant");
    XCTAssertFalse([PasswordUtility checkUserNameValidity:Nil], @"Username is not compliant due to invalid character");
   XCTAssertFalse([PasswordUtility checkUserNameValidity:@"abcde@"], @"Username is not compliant due to invalid character");
    XCTAssertFalse([PasswordUtility checkUserNameValidity:@"abe@"], @"Username is not compliant because too short");
}

static const NSString* hashFortestHash = @"c041f070f581ef28ff266e74915980de4a56ba11a55c89d8889034e3b26795e9";
static  NSString* hashString = @"testHash";
static  const NSString* salt = @"iMon1972";

- (void)testhashStringForPassword
{
    XCTAssertNil([PasswordUtility hashStringForPassword:Nil], "Nil hash for Nil password");
    XCTAssertNotNil([PasswordUtility hashStringForPassword:@""],@"Hash empty string is compliant");
    
    
    XCTAssertEqualObjects([PasswordUtility hashStringForPassword:hashString], hashFortestHash, @"Hash for password is compliant");
    XCTAssertNotEqualObjects([PasswordUtility hashStringForPassword:@"testHash1"], hashFortestHash, @"Hash for password is not compliant");
    
}

- (void)testhashString
{
    XCTAssertNil([PasswordUtility hashString:Nil withSalt:Nil], "Nil hash with Nil data and salt");
    XCTAssertNil([PasswordUtility hashString:@"testHash" withSalt:Nil], "Nil hash with Nil salt");
    XCTAssertNil([PasswordUtility hashString:Nil withSalt:@""], "Nil hash with Nil salt");

    XCTAssertEqualObjects([PasswordUtility hashString:hashString withSalt:salt], hashFortestHash, @"generated hash is compliant");
    
    XCTAssertNotEqualObjects([PasswordUtility hashString:hashString withSalt:@"iMon1973"], hashFortestHash, @"generated hash is compliant");
  
}

@end
