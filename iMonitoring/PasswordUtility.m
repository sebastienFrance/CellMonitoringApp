//
//  PasswordCheckUtility.m
//  iMonitoring
//
//  Created by sébastien brugalières on 08/12/2013.
//
//

#import "PasswordUtility.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation PasswordUtility

+(NSUInteger) minPasswordLength {
    return 5;
}

+ (PasswordValidityStatus) checkPasswordValidity:(const NSString*) password retype:(const NSString*) reTypePassword {

    if (password == Nil || [password isEqualToString:@""]) {
        return MainPasswordInvalid;
    }

    if (password.length < [PasswordUtility minPasswordLength]) {
        return MainPasswordTooShort;
    }

    if (reTypePassword == Nil || [reTypePassword isEqualToString:@""]) {
        return RetypePasswordInvalid;
    }

    if (reTypePassword.length < [PasswordUtility minPasswordLength]) {
        return RetypePasswordTooShort;
    }

    if ([password isEqualToString:(NSString*)reTypePassword] == FALSE) {
        return MainRetypePasswordNotEquals;
    }

    return validPasswords;
}

+(NSString*) getPasswordErrorMessage:(PasswordValidityStatus) status {
    switch (status) {
        case MainPasswordInvalid: return @"Password must not be empty.";
        case MainPasswordTooShort: return [NSString stringWithFormat:@"Password must be at least %lu characters.",(unsigned long)[PasswordUtility minPasswordLength]];
        case RetypePasswordInvalid: return @"Retype password must not be empty.";
        case RetypePasswordTooShort: return [NSString stringWithFormat:@"Retype password must be at least %lu characters.",(unsigned long)[PasswordUtility minPasswordLength]];
        case MainRetypePasswordNotEquals: return @"Password and Retype Password must be equals.";
        case validPasswords: return @"Passwords are valid.";
        default: return @"Uknown status";
    }
}


+(NSUInteger) minUserNameLength {
    return 5;
}


+ (Boolean) checkUserNameValidity:(const NSString*) userName {
    if (userName == Nil) {
        return FALSE;
    }
    
    if (userName.length < [PasswordUtility minUserNameLength]) {
        return FALSE;
    }
    
    NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz0123456789"] invertedSet];
    if ([userName rangeOfCharacterFromSet:set].location != NSNotFound) {
        return FALSE;
    }
    
    return TRUE;
}


#pragma mark - Hashing functions

+ (NSString *) hashStringForPassword:(const NSString *) data {
    
    return [PasswordUtility hashString:data withSalt:@"iMon1972"];
}

+ (NSString *) hashString:(const NSString *) data withSalt: (const NSString *) salt {
    
    if (data == Nil || salt == Nil) {
        return Nil;
    }
    
    const char *cKey  = [salt cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSString *hash;
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", cHMAC[i]];
    hash = output;
    return hash;
    
}



@end
