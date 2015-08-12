//
//  PasswordCheckUtility.h
//  iMonitoring
//
//  Created by sébastien brugalières on 08/12/2013.
//
//

#import <Foundation/Foundation.h>

@interface PasswordUtility : NSObject

typedef NS_ENUM(NSInteger, PasswordValidityStatus) {
    MainPasswordInvalid,
    MainPasswordTooShort,
    RetypePasswordInvalid,
    RetypePasswordTooShort,
    MainRetypePasswordNotEquals,
    validPasswords
};

+ (NSUInteger) minPasswordLength;
+(NSUInteger) minUserNameLength;

+ (PasswordValidityStatus) checkPasswordValidity:(const NSString*) password retype:(const NSString*) reTypePassword;
+(NSString*) getPasswordErrorMessage:(PasswordValidityStatus) status;

+ (Boolean) checkUserNameValidity:(const NSString*) userName;

#pragma mark - Hashing functions

+ (NSString *) hashStringForPassword:(const NSString *) data;
+ (NSString *) hashString:(const NSString *) data withSalt: (const NSString *) salt;


@end
