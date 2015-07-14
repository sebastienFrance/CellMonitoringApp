//
//  RequestURLUtilities.m
//  CellMonitoring
//
//  Created by sébastien brugalières on 27/04/2014.
//
//

#import "RequestURLUtilities.h"
#import "ConnectionManager.h"
#import "HTMLRequest.h"
#import "SessionURLRequestHandler.h"


@implementation RequestURLUtilities

+ (id<HTMLRequest>) instantiateRequest:(id<HTMLDataResponse>) del clientId:(NSString*) theClientId {
    return [[SessionURLRequestHandler alloc] init:del clientId:theClientId];
}

#if TARGET_OS_MAC && !TARGET_OS_IPHONE

+ (id<HTMLRequest>) instantiateRequestForModal:(id<HTMLDataResponse>) del clientId:(NSString*) theClientId {
    return [[SessionURLRequestHandler alloc] initForModal:del clientId:theClientId];
}
#endif

static NSTimeInterval _defaultTimeoutForRequest = 90;

+ (void) setDetaultTimeoutForRequest:(NSTimeInterval) timeout{
    _defaultTimeoutForRequest = timeout;
}

+ (NSTimeInterval) getDefaultTimeoutForRequest {
    return _defaultTimeoutForRequest;
}

+ (NSURL*) getBaseURL {
    ConnectionManager* center = [ConnectionManager sharedInstance];
#if TARGET_OS_IPHONE
    NSString* urlString = [NSString stringWithFormat:@"https://%@:%@/iMonserver/App",center.IPAddress, center.portNumber];
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
    NSString* urlString = [NSString stringWithFormat:@"https://%@:%@/iMonserver/App",center.IPAddress, center.portNumber];
#endif
    return [NSURL URLWithString:urlString];
}

+ (NSUInteger) getDeviceType {
#if TARGET_OS_IPHONE
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return 1;
    } else {
        return 10;
    }
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
    return 20;
#endif

}

+ (void) dumpChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSLog(@"%s dumpChallenge called!!", __PRETTY_FUNCTION__);
    
    if (challenge.proposedCredential != Nil) {
        NSLog(@"willSendRequestForAuthenticationChallenge::has credential");
        
        NSURLCredential* credential = challenge.proposedCredential;
        NSArray *certificates = credential.certificates;
        if (certificates != nil) {
            NSLog(@"There are certificates: %ld",(unsigned long)certificates.count);
        } else {
            NSLog(@"There is no certificate");
        }
        
        SecIdentityRef identity = credential.identity;
        if (identity != NULL) {
            NSLog(@"There is a secIdentity");
        } else {
            NSLog(@"There is no secIdentity");
        }
        
        if (credential.hasPassword) {
            NSLog(@"There is a password");
        } else {
            NSLog(@"There is no password");
        }
        
        if (credential.user != Nil) {
            NSLog(@"There is a user: %@", credential.user);
        } else {
            NSLog(@"There is no user");
        }
        
    } else {
        NSLog(@"willSendRequestForAuthenticationChallenge::has not credential");
    }
    
    if (challenge.protectionSpace != Nil) {
        NSURLProtectionSpace *protection = challenge.protectionSpace;
        NSLog(@"willSendRequestForAuthenticationChallenge::has protection space");
        
        NSLog(@"Authenticated Method:%@", protection.authenticationMethod);
        NSLog(@"Host:%@", protection.host);
        
        NSArray* distingNames = protection.distinguishedNames;
        if (distingNames != Nil) {
            NSLog(@"There are distinguished names: %ld", (unsigned long)distingNames.count);
        } else {
            NSLog(@"There are no distinguished names");
        }
        
        if (protection.isProxy) {
            NSLog(@"It is a proxy with type: %@", protection.proxyType);
        } else {
            NSLog(@"It is not a proxy");
        }
        
        
        
        NSLog(@"Port:%ld", (long)protection.port);
        NSLog(@"Protocol:%@", protection.protocol);
        NSLog(@"Realm:%@", protection.realm);
        
        if (protection.receivesCredentialSecurely) {
            NSLog(@"It can receivesCredentialSecurely");
        } else {
            NSLog(@"It cannot receivesCredentialSecurely");
        }
        
        SecTrustRef sslState = protection.serverTrust;
        if (sslState != Nil) {
            NSLog(@"it has a sslstate");
        } else {
            NSLog(@"it has no sslstate");
        }
        if ([protection.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            NSLog(@"authenticationMethod is NSURLAuthenticationMethodServerTrust");
        } else if ([protection.authenticationMethod isEqualToString:NSURLAuthenticationMethodDefault]) {
            NSLog(@"authenticationMethod is NSURLAuthenticationMethodDefault");
        }
    } else {
        NSLog(@"willSendRequestForAuthenticationChallenge::has not a protection space");
    }
    
    
}


@end
