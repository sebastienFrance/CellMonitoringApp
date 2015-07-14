//
//  SessionURLRequestHandler.m
//  CellMonitoring
//
//  Created by sébastien brugalières on 27/04/2014.
//
//

#import "SessionURLRequestHandler.h"
#import "HTMLRequest.h"
#import "ConnectionManager.h"
#import "SessionURLRequest.h"
#import "Utility.h"
#import "RequestURLUtilities.h"
#import "JSONKit.h"

@interface SessionURLRequestHandler()

@property (nonatomic, weak) id<HTMLDataResponse> delegate;

@property (nonatomic) NSTimeInterval startDate;

@end

@implementation SessionURLRequestHandler

static NSUInteger zipFileNameId = 0;

#pragma mark - Constructor
- (id) init:(id<HTMLDataResponse>) theDelegate clientId:(NSString*) theClientId {
    if (self = [super init]){
        _delegate = theDelegate;
        _clientId = theClientId;
        _isZipped = FALSE;
    }
    return self;
}


#if TARGET_OS_MAC && !TARGET_OS_IPHONE

- (id) initForModal:(id<HTMLDataResponse>) theDelegate clientId:(NSString*) theClientId  {
    if (self = [super init]){
        _delegate = theDelegate;
        _clientId = theClientId;
        _isZipped = FALSE;
    }
    return self;
}
#endif



- (void) sendRequest:(NSString*) bodyURL zipped:(Boolean) zippedResponse {
    
    self.isZipped = zippedResponse;
    [self initializeForZip];
    
    SessionURLRequest* sessionURL = [SessionURLRequest sharedInstance];
    
    self.startDate = [NSDate timeIntervalSinceReferenceDate];
    
    [sessionURL sendRequest:bodyURL timeout:[RequestURLUtilities getDefaultTimeoutForRequest] handler:self];
}

- (void) sendRequest:(NSString*) bodyURL zipped:(Boolean) zippedResponse timeout:(NSTimeInterval) timeoutInterval {
    self.isZipped = zippedResponse;
    [self initializeForZip];

    SessionURLRequest* sessionURL = [SessionURLRequest sharedInstance];
    
    self.startDate = [NSDate timeIntervalSinceReferenceDate];
    
    [sessionURL sendRequest:bodyURL timeout:timeoutInterval handler:self];
}

- (void) sendRequestWithImage:(UIImage*)theImage  quality:(float) theQuality url:(NSString*) bodyURL zipped:(Boolean) zippedResponse {
    self.isZipped = zippedResponse;
    [self initializeForZip];
    
    SessionURLRequest* sessionURL = [SessionURLRequest sharedInstance];
    
    self.startDate = [NSDate timeIntervalSinceReferenceDate];
    
    [sessionURL sendImageRequest:theImage quality:theQuality parameter:bodyURL timeout:[RequestURLUtilities getDefaultTimeoutForRequest] handler:self];
}

// Request send to an internet server, not iMonServer (like Yahoo for timezone)
- (void) sendBasicRequest:(NSString*) url {
    SessionURLRequest* sessionURL = [SessionURLRequest sharedInstance];
    
    self.startDate = [NSDate timeIntervalSinceReferenceDate];
    
    [sessionURL sendBasicRequest:url timeout:[RequestURLUtilities getDefaultTimeoutForRequest] handler:self];
}


- (void) initializeForZip {
    if (self.isZipped) {
        zipFileNameId++;
        self.zippedFileName = [NSString stringWithFormat:@"export%ld.zip", (unsigned long)zipFileNameId];
        if (zipFileNameId == ULONG_MAX) {
            zipFileNameId = 0;
        }
    }
}


+ (void) setDetaultTimeoutForRequest:(NSTimeInterval) timeout {
    
}

- (void) requestHasCompleted:(NSData*) result {
    
    NSTimeInterval dateReceivedData = [NSDate timeIntervalSinceReferenceDate];
    
    NSLog(@"%s Full Response(%@): %f", __PRETTY_FUNCTION__, self.clientId, (dateReceivedData - self.startDate));
  
    if (result == Nil) {
        [self.delegate connectionFailure:self.clientId];
    } else {
        id data = [result objectFromJSONData];
        NSTimeInterval dateAfterJSONDeserialized = [NSDate timeIntervalSinceReferenceDate];
        NSLog(@"%s Full Response after JSON deserialized: %f (additional: %f)", __PRETTY_FUNCTION__, (dateAfterJSONDeserialized - self.startDate), (dateAfterJSONDeserialized - dateReceivedData));
        [self.delegate dataReady:data clientId:self.clientId];
    }
}

- (void) requestHasFailed {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self.delegate connectionFailure:self.clientId];
}


@end
