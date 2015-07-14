//
//  HTMLRequest.h
//  iMonitoring
//
//  Created by sébastien brugalières on 18/08/13.
//
//

#import <Foundation/Foundation.h>

@protocol HTMLDataResponse;

@protocol HTMLRequest <NSObject>

- (id) init:(id<HTMLDataResponse>) theDelegate clientId:(NSString*) theClientId;

#if TARGET_OS_MAC && !TARGET_OS_IPHONE

- (id) initForModal:(id<HTMLDataResponse>) theDelegate clientId:(NSString*) theClientId;
#endif




- (void) sendRequest:(NSString*) bodyURL zipped:(Boolean) zippedResponse;
- (void) sendRequest:(NSString*) bodyURL zipped:(Boolean) zippedResponse timeout:(NSTimeInterval) timeoutInterval;
- (void) sendRequestWithImage:(UIImage*)theImage quality:(float) theQuality url:(NSString*) bodyURL zipped:(Boolean) zippedResponse;


// Request send to an internet server, not iMonServer (like Yahoo for timezone)
- (void) sendBasicRequest:(NSString*) url;


@end

@protocol HTMLDataResponse
- (void) dataReady:(id) theData clientId:(NSString*) theClientId;
- (void) connectionFailure:(NSString*) theClientId;

@end
