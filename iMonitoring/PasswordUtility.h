//
//  PasswordCheckUtility.h
//  iMonitoring
//
//  Created by sébastien brugalières on 08/12/2013.
//
//

#import <Foundation/Foundation.h>

@interface PasswordUtility : NSObject


+ (Boolean) checkPasswordValidity:(const NSString*) password retype:(const NSString*) reTypePassword;
+ (Boolean) checkUserNameValidity:(const NSString*) userName;

#pragma mark - Hashing functions

+ (NSString *) hashStringForPassword:(const NSString *) data;
+ (NSString *) hashString:(const NSString *) data withSalt: (const NSString *) salt;


@end
