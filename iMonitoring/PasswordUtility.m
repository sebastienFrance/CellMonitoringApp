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

+ (Boolean) checkPasswordValidity:(const NSString*) password retype:(const NSString*) reTypePassword {
    
    if (password == Nil || reTypePassword == Nil) {
        [PasswordUtility showAlert:@"Missing data" message:@"Enter a valid password"];
        return FALSE;
    }
    
    if ([password isEqualToString:@""]) {
        [PasswordUtility showAlert:@"Missing data" message:@"Enter a valid password"];
        return FALSE;
    }
    
    if (password.length < 5) {
        [PasswordUtility showAlert:@"Missing data" message:@"Password must be at least 5 characters"];
        return FALSE;
    }
    
    if ([reTypePassword isEqualToString:@""]) {
        [PasswordUtility showAlert:@"Missing data" message:@"Enter a valid retype password"];
        return FALSE;
    }
    
    if ([password isEqualToString:(NSString*)reTypePassword] == FALSE) {
        [PasswordUtility showAlert:@"Incorrect data" message:@"New passwords are not indentical"];
        return FALSE;
    }
    
    return TRUE;
}

+ (Boolean) checkUserNameValidity:(const NSString*) userName {
    if (userName == Nil) {
        [PasswordUtility showAlert:@"Incorrect user name" message:@"User name must be at least 5 characters long."];
        return FALSE;
    }
    
    if (userName.length < 5) {
        [PasswordUtility showAlert:@"Incorrect user name" message:@"User name must be at least 5 characters long."];
        return FALSE;
    }
    
    NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz0123456789"] invertedSet];
    if ([userName rangeOfCharacterFromSet:set].location != NSNotFound) {
        [PasswordUtility showAlert:@"Incorrect user name" message:@"User name must contains only lower case letter and/or numbers"];
        return FALSE;
    }
    
    return TRUE;
}


+ (void) showAlert:(NSString*) title message:(NSString*) theMessage {
#if TARGET_OS_IPHONE
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:theMessage delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alert show];
#else
    NSAlert* alert = [NSAlert alertWithMessageText:title defaultButton:@"ok" alternateButton:Nil otherButton:Nil informativeTextWithFormat:@"%@",theMessage];
    [alert runModal];
#endif
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
