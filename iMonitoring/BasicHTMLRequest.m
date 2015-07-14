//
//  BasicHTMLRequest.m
//  iMonitoring
//
//  Created by sébastien brugalières on 18/08/13.
//
//

#import "BasicHTMLRequest.h"
#import "Utility.h"
#import "ConnectionManager.h"
#import "JSONKit.h"
#import "RequestURLUtilities.h"

@interface BasicHTMLRequest()

@property (nonatomic) NSMutableData* receivedData;
@property (nonatomic) NSString* clientId;

@property (nonatomic) Boolean isZippedResponse;
@property (nonatomic) NSString* zipFileName;

@property (nonatomic, weak) id<HTMLDataResponse> delegate;

@property (nonatomic) NSTimeInterval startDate;

#if TARGET_OS_MAC && !TARGET_OS_IPHONE

@property (nonatomic) Boolean isModal;
#endif

@end

@implementation BasicHTMLRequest

static NSUInteger zipFileNameId = 0;

#pragma mark - Constructor
- (id) init:(id<HTMLDataResponse>) theDelegate clientId:(NSString*) theClientId {
    if (self = [super init]){
        _delegate = theDelegate;
        _clientId = theClientId;
        _isZippedResponse = FALSE;
#if TARGET_OS_MAC && !TARGET_OS_IPHONE
        _isModal = FALSE;
#endif
    }
    return self;
}


#if TARGET_OS_MAC && !TARGET_OS_IPHONE

- (id) initForModal:(id<HTMLDataResponse>) theDelegate clientId:(NSString*) theClientId  {
    if (self = [super init]){
        _delegate = theDelegate;
        _clientId = theClientId;
        _isZippedResponse = FALSE;
        _isModal = TRUE;
    }
    return self;
}
#endif

#pragma mark - SendRequest to iMonServer
- (void) sendRequest:(NSString*) bodyURL zipped:(Boolean) zippedResponse {
    [self sendRequest:bodyURL zipped:zippedResponse timeout:[RequestURLUtilities getDefaultTimeoutForRequest]];
}


- (void) sendRequest:(NSString*)bodyURL zipped:(Boolean) zippedResponse timeout:(NSTimeInterval) timeoutInterval  {
    
    ConnectionManager* center = [ConnectionManager sharedInstance];
    NSString* fullBodyURL = [NSString stringWithFormat:@"%@&user=%@&passwd=%@&device=%ld"
                             ,bodyURL,
                             center.userName,
                             center.password,
                             (unsigned long)[RequestURLUtilities getDeviceType]];
    
    fullBodyURL = [fullBodyURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    self.isZippedResponse = zippedResponse;
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest
                                     requestWithURL:[RequestURLUtilities getBaseURL]
                                     cachePolicy:NSURLRequestUseProtocolCachePolicy
                                     timeoutInterval:timeoutInterval];
    if (theRequest == Nil) {
        [self.delegate connectionFailure:self.clientId];
    }
    [theRequest setHTTPMethod:@"POST"];
    
    if (zippedResponse == FALSE) {
        [theRequest setHTTPBody:[fullBodyURL dataUsingEncoding:NSUTF8StringEncoding]];
    } else {
        self.zipFileName = [NSString stringWithFormat:@"export%ld.zip", (unsigned long)zipFileNameId];
        zipFileNameId++;
        if (zipFileNameId == ULONG_MAX) {
            zipFileNameId = 0;
        }
        
        NSString* bodyWithZip = [NSString stringWithFormat:@"%@&zip=true&zipName=%@",fullBodyURL, self.zipFileName];
        [theRequest setHTTPBody:[bodyWithZip dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    
#if TARGET_OS_IPHONE
    // create the connection with the request and start loading the data
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
    NSURLConnection *theConnection;
    if (self.isModal) {
        theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:NO];
        [theConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSModalPanelRunLoopMode];
        [theConnection start];
    } else {
        theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    }
#endif
    if (theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        self.receivedData = [NSMutableData data];
        self.startDate = [NSDate timeIntervalSinceReferenceDate];
    } else {
        [self.delegate connectionFailure:self.clientId];
        // Inform the user that the connection failed.
    }
}

- (void) sendRequestWithImage:(UIImage*)theImage  quality:(float) theQuality url:(NSString*) bodyURL zipped:(Boolean) zippedResponse {
#warning SEB: to be implemeneted
}

#pragma mark - Basic requests non iMonServer (to Google / Yahoo... for timezone or others services)
- (void) sendBasicRequest:(NSString*) url {
    [self sendBasicRequest:url timeout:[RequestURLUtilities getDefaultTimeoutForRequest]];
}


- (void) sendBasicRequest:(NSString*) url timeout:(NSTimeInterval) timeoutInterval  {
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest
                                     requestWithURL:[NSURL URLWithString:url]
                                     cachePolicy:NSURLRequestUseProtocolCachePolicy
                                     timeoutInterval:timeoutInterval];
    if (theRequest == Nil) {
        [self.delegate connectionFailure:self.clientId];
    }
    [theRequest setHTTPMethod:@"POST"];
    
    // create the connection with the request and start loading the data
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        self.receivedData = [NSMutableData data];
        self.startDate = [NSDate timeIntervalSinceReferenceDate];
    } else {
        [self.delegate connectionFailure:self.clientId];
        // Inform the user that the connection failed.
    }
}



#pragma mark - NSURLConnectionDataDelegate protocol
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    return request;
}

- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request {
    return Nil;
}
- (void)connection:(NSURLConnection *)connection   didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
   
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return cachedResponse;
}



//warning found in NSURLConnectionDataDelegate instead of NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    [self.receivedData setLength:0];
}

//warning found in NSURLConnectionDataDelegate instead of NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [self.receivedData appendData:data];
}


//warning found in NSURLConnectionDataDelegate instead of NSURLConnectionDelegate
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    
    NSTimeInterval dateReceivedData = [NSDate timeIntervalSinceReferenceDate];
    
    NSLog(@"Full Response(%@): %f", self.clientId, (dateReceivedData - self.startDate));
    
    if (self.isZippedResponse) {
        NSData* theunzippedData = [Utility unzipFromData:self.receivedData outputFileName:self.zipFileName];
        NSTimeInterval dateAfterUnzipped = [NSDate timeIntervalSinceReferenceDate];
        NSLog(@"Full Response after unzipped: %f (additional: %f)",(dateAfterUnzipped - self.startDate), (dateAfterUnzipped - dateReceivedData));
        
        if (theunzippedData != Nil) {
            // NSError* error;
            //  NSDictionary* data =  [NSJSONSerialization JSONObjectWithData:theData options:0 error:&error];
          
            id data = [theunzippedData objectFromJSONData];
            NSTimeInterval dateAfterJSONDeserialized = [NSDate timeIntervalSinceReferenceDate];
            NSLog(@"Full Response after JSON deserialized: %f (additional: %f)",(dateAfterJSONDeserialized - self.startDate), (dateAfterJSONDeserialized - dateAfterUnzipped));
            
            [self.delegate dataReady:data clientId:self.clientId];
        } else {
            [self.delegate connectionFailure:self.clientId];
        }
    } else {
        id data = [self.receivedData objectFromJSONData];
        NSTimeInterval dateAfterJSONDeserialized = [NSDate timeIntervalSinceReferenceDate];
        NSLog(@"Full Response after JSON deserialized: %f (additional: %f)",(dateAfterJSONDeserialized - self.startDate), (dateAfterJSONDeserialized - dateReceivedData));
        [self.delegate dataReady:data clientId:self.clientId];
    }
    
    self.receivedData = Nil;
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
 //   [RequestURLUtilities dumpChallenge:challenge];
    
    
    if (challenge.protectionSpace != Nil) {
        NSURLProtectionSpace *protection = challenge.protectionSpace;
        
        SecTrustRef sslState = protection.serverTrust;
        if (sslState == Nil) {
            NSLog(@"it has no sslstate");
        }
        
        
        if ([protection.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            
            
            // warning normaly I should check the validity of the SecTrustRef before to trust
            NSURLCredential* credential = [NSURLCredential credentialForTrust:sslState];
            
            [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
            
        } else if ([protection.authenticationMethod isEqualToString:NSURLAuthenticationMethodDefault]) {
            
            //warning should select something different for Persistence
            NSURLCredential* credential = [NSURLCredential credentialWithUser:@"UserName"
                                                                     password:@"Password"
                                                                  persistence:NSURLCredentialPersistenceForSession];
            
            [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
        }
        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
        
    }
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection didFailWithError");
    [self.delegate connectionFailure:self.clientId];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    return FALSE;
}



@end
