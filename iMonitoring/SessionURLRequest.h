//
//  SessionURLRequest.h
//  CellMonitoring
//
//  Created by sébastien brugalières on 27/04/2014.
//
// Test For Git

#import <Foundation/Foundation.h>

@class SessionURLRequestHandler;

@interface SessionURLRequest : NSObject<NSURLSessionDownloadDelegate>

+(SessionURLRequest*)sharedInstance;

- (void) sendRequest:(NSString*) bodyURL timeout:(NSTimeInterval) timeoutInterval handler:(SessionURLRequestHandler*) theHandler;
- (void) sendBasicRequest:(NSString*) url timeout:(NSTimeInterval) timeoutInterval handler:(SessionURLRequestHandler*) theHandler;
- (void) sendImageRequest:(UIImage*)image quality:(float) theQuality parameter:(NSString*)bodyURL timeout:(NSTimeInterval) timeoutInterval handler:(SessionURLRequestHandler*) theHandler;

@end
