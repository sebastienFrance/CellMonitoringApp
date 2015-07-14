//
//  RequestURLUtilities.h
//  CellMonitoring
//
//  Created by sébastien brugalières on 27/04/2014.
//
//

#import <Foundation/Foundation.h>

@protocol HTMLRequest;
@protocol HTMLDataResponse;

@interface RequestURLUtilities : NSObject

+ (NSURL*) getBaseURL;
+ (NSUInteger) getDeviceType;

+ (void) dumpChallenge:(NSURLAuthenticationChallenge *)challenge;

+ (id<HTMLRequest>) instantiateRequest:(id<HTMLDataResponse>) del clientId:(NSString*) theClientId;

#if TARGET_OS_MAC && !TARGET_OS_IPHONE
+ (id<HTMLRequest>) instantiateRequestForModal:(id<HTMLDataResponse>) del clientId:(NSString*) theClientId;
#endif

+ (void) setDetaultTimeoutForRequest:(NSTimeInterval) timeout;
+ (NSTimeInterval) getDefaultTimeoutForRequest;

@end
