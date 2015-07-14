//
//  ConnectionManager.m
//  iMonitoring
//
//  Created by sébastien brugalières on 08/12/2013.
//
//

#import "ConnectionManager.h"

@implementation ConnectionManager

+(ConnectionManager*)sharedInstance
{
    static dispatch_once_t pred;
    static ConnectionManager *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[ConnectionManager alloc] init];
    });
    return sharedInstance;
}

- (void) dealloc {
    // implement -dealloc & remove abort() when refactoring for
    // non-singleton use.
    abort();
}

// -------- Methods used to keep info about the server ----------
- (void) setServerConfiguration:(NSString*) IPAddress portNumber:(NSString*) port userName:(NSString*) theUserName password:(NSString*) thePassword {
    _IPAddress = IPAddress;
    _portNumber = port;
    
    _userName = theUserName;
    _password = thePassword;
}

- (void) updatePassword:(NSString*) password {
    _password = password;
}

@end
