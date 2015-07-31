//
//  SessionURLRequest.m
//  CellMonitoring
//
//  Created by sébastien brugalières on 27/04/2014.
//
//

#import "SessionURLRequest.h"
#import "ConnectionManager.h"
#import "RequestURLUtilities.h"
#import "SessionURLRequestHandler.h"
#import "Utility.h"

#if TARGET_OS_IPHONE
#import "iMonitoring.h"
#endif

@interface SessionURLRequest()

@property (nonatomic) NSURLSession* session;

@property (nonatomic) NSMutableDictionary* handlers;

@end

@implementation SessionURLRequest

#pragma mark - Initializations

+(SessionURLRequest*)sharedInstance
{
    static dispatch_once_t pred;
    static SessionURLRequest *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[SessionURLRequest alloc] init];
    });
    return sharedInstance;
}

- (id)init{
    if (self = [super init] ) {
        [self initURLSession];
        _handlers = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)initURLSession
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.SebCompany.CellMonitoring"];
    _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
}

#pragma mark - API
- (void) sendImageRequest:(UIImage*)image quality:(float) theQuality parameter:(NSString*)bodyURL timeout:(NSTimeInterval) timeoutInterval handler:(SessionURLRequestHandler*) theHandler{
    
    ConnectionManager* center = [ConnectionManager sharedInstance];
    NSString* fullBodyURL = [NSString stringWithFormat:@"%@&user=%@&passwd=%@&device=%ld"
                             ,bodyURL,
                             center.userName,
                             center.password,
                             (unsigned long)[RequestURLUtilities getDeviceType]];
    
    fullBodyURL = [fullBodyURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest
                                     requestWithURL:[RequestURLUtilities getBaseURL]
                                     cachePolicy:NSURLRequestUseProtocolCachePolicy
                                     timeoutInterval:timeoutInterval];
    
    if (theRequest == Nil) {
        [theHandler requestHasFailed];
        return;
    }
    
    [theRequest setHTTPMethod:@"POST"];
    
    // ******************
    
    // we want a JSON response
    [theRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    // the boundary string. Can be whatever we want, as long as it doesn't appear as part of "proper" fields
    NSString *boundary = @"qqqq___CellMonitoringUpload___qqqq";
    
    // setting the Content-type and the boundary
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [theRequest setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // we need a buffer of mutable data where we will write the body of the request
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"Parameters\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", fullBodyURL] dataUsingEncoding:NSUTF8StringEncoding]];

    [SessionURLRequest appendImageTo:body image:image quality:theQuality boundary:boundary];

    // we close the body with one last boundary
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    // *******************
    
    if (theHandler.isZipped == FALSE) {
        [theRequest setHTTPBody:body];
    } else {
        NSString* bodyWithZip = [NSString stringWithFormat:@"%@&zip=true&zipName=%@",fullBodyURL, theHandler.zippedFileName];
        [theRequest setHTTPBody:[bodyWithZip dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSURLSessionDownloadTask* downloadTask = [self.session downloadTaskWithRequest:theRequest];
    
    self.handlers[downloadTask] = theHandler;
    
    [downloadTask resume];
}

+(void) appendImageTo:(NSMutableData*) body image:(UIImage*) image quality:(float) theQuality boundary:(NSString*) boundary {
    // creating a NSData representation of the image
    UIImage* normalizedImage = [Utility normalizedImage:image];
    NSData *imageData = UIImageJPEGRepresentation(normalizedImage, theQuality < 1.0 ? theQuality : 1.0);
    
    // if we have successfully obtained a NSData representation of the image
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"photo\"; filename=\"imageForSite.jpeg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    } else {
        NSLog(@"%s no image data to upload!!!", __PRETTY_FUNCTION__);
    }
}

- (void) sendRequest:(NSString*)bodyURL timeout:(NSTimeInterval) timeoutInterval handler:(SessionURLRequestHandler*) theHandler{
    
    ConnectionManager* center = [ConnectionManager sharedInstance];
    NSString* fullBodyURL = [NSString stringWithFormat:@"%@&user=%@&passwd=%@&device=%ld"
                             ,bodyURL,
                             center.userName,
                             center.password,
                             (unsigned long)[RequestURLUtilities getDeviceType]];
    
    fullBodyURL = [fullBodyURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest
                                     requestWithURL:[RequestURLUtilities getBaseURL]
                                     cachePolicy:NSURLRequestUseProtocolCachePolicy
                                     timeoutInterval:timeoutInterval];
    
    if (theRequest == Nil) {
        [theHandler requestHasFailed];
        return;
    }
    
    [theRequest setHTTPMethod:@"POST"];
    
    if (theHandler.isZipped == FALSE) {
        [theRequest setHTTPBody:[fullBodyURL dataUsingEncoding:NSUTF8StringEncoding]];
    } else {
        NSString* bodyWithZip = [NSString stringWithFormat:@"%@&zip=true&zipName=%@",fullBodyURL, theHandler.zippedFileName];
        [theRequest setHTTPBody:[bodyWithZip dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSLog(@"%s URL: %@", __PRETTY_FUNCTION__, fullBodyURL);
    NSURLSessionDownloadTask* downloadTask = [self.session downloadTaskWithRequest:theRequest];
    
    self.handlers[downloadTask] = theHandler;
    
    [downloadTask resume];
 
}

- (void) sendBasicRequest:(NSString*) url timeout:(NSTimeInterval) timeoutInterval handler:(SessionURLRequestHandler*) theHandler {
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest
                                     requestWithURL:[NSURL URLWithString:url]
                                     cachePolicy:NSURLRequestUseProtocolCachePolicy
                                     timeoutInterval:timeoutInterval];
    if (theRequest == Nil) {
        [theHandler requestHasFailed];
        return;
    }

    [theRequest setHTTPMethod:@"POST"];
    
    
    NSURLSessionDownloadTask* downloadTask = [self.session downloadTaskWithRequest:theRequest];
    
    self.handlers[downloadTask] = theHandler;
    
    [downloadTask resume];
}


#pragma mark - NSURLSessionDownloadDelegate Protocol

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)downloadURL
{
    SessionURLRequestHandler* handler = self.handlers[downloadTask];
    [self.handlers removeObjectForKey:downloadTask];
   
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (fileManager == Nil) {
        [self callErrorHandler:handler];
        return;
    }
    
    NSArray *URLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    if ((URLs == Nil) || URLs.count == 0) {
        [self callErrorHandler:handler];
        return;
    }
    
    NSURL *documentsDirectory = [URLs objectAtIndex:0];
    if (documentsDirectory == Nil) {
        [self callErrorHandler:handler];
        return;
    }
    
    NSURL *originalURL = [[downloadTask originalRequest] URL];
    if (originalURL == Nil) {
        [self callErrorHandler:handler];
        return;
    }

    NSURL *destinationURL = [documentsDirectory URLByAppendingPathComponent:[originalURL lastPathComponent]];
    if (destinationURL == Nil) {
        [self callErrorHandler:handler];
        return;
    }
    
    // For the purposes of testing, remove any existing file at the destination.
    NSData* receivedData = [NSData dataWithContentsOfURL:downloadURL];
    if (receivedData == Nil) {
        [self callErrorHandler:handler];
        return;
    }
    
    [fileManager removeItemAtURL:destinationURL error:NULL];
    
    
    NSData* resultData = Nil;
    if (handler.isZipped) {
        NSData* theunzippedData = [Utility unzipFromData:receivedData outputFileName:handler.zippedFileName];
        if (theunzippedData == Nil) {
            [self callErrorHandler:handler];
            return;
        }
        
        resultData = theunzippedData;
    } else {
        resultData = receivedData;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [handler requestHasCompleted:resultData];
    });
}

- (void) callErrorHandler:(SessionURLRequestHandler*) handler {
    dispatch_async(dispatch_get_main_queue(), ^{
        [handler requestHasFailed];
    });
    
}


-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    //    NSLog(@"%s", __PRETTY_FUNCTION__);
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
//    NSLog(@"%s", __PRETTY_FUNCTION__);

}

#pragma mark - NSURLSessionTaskDelegate Protocol

// Server errors are not reported through the error parameter. The only errors your delegate receives through the error parameter are client-side errors, such as being unable to resolve the hostname or connect to the host.
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error != Nil) {
        NSLog(@"Session download has failed : %@", error);
        SessionURLRequestHandler* handler = self.handlers[task];
        [self.handlers removeObjectForKey:task];
        [self callErrorHandler:handler];
    }
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    // NSLog(@"bytes sent: %lld / total bytes sents: %lld / total bytes expected to sent: %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
}


#pragma mark - NSURLSessionDelegate Protocol

- (void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    
    //[RequestURLUtilities dumpChallenge:challenge];
    
    
    if (challenge.protectionSpace != Nil) {
        NSURLProtectionSpace *protection = challenge.protectionSpace;

        SecTrustRef sslState = protection.serverTrust;
        if (sslState == Nil) {
            NSLog(@"%s Warning: empty serverTrust",__PRETTY_FUNCTION__);
        }
        
        
        if ([protection.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            
            NSLog(@"%s => NSURLAuthenticationMethodServerTrust", __PRETTY_FUNCTION__);
            // warning normaly I should check the validity of the SecTrustRef before to trust
            NSURLCredential* credential = [NSURLCredential credentialForTrust:sslState];

            // Put in command for test
            //[challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
            
           completionHandler(NSURLSessionAuthChallengeUseCredential, credential);

        } else {
            NSLog(@"%s => Called for another challenge", __PRETTY_FUNCTION__);
           completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, NULL);
        }
      //  [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
        
    }

    
}


- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);

    // cancel all pending requests
    for (SessionURLRequestHandler* handler in self.handlers) {
        [self callErrorHandler:handler];
    }
    
    [self.handlers removeAllObjects];
}

#if TARGET_OS_IPHONE

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    [self callCompletionHanderIfFinished];
}

-(void) callCompletionHanderIfFinished {
    iMonitoring *appDelegate = (iMonitoring*)[UIApplication sharedApplication].delegate;
    if (appDelegate.completionHandler) {
        void (^completionHander)() = appDelegate.completionHandler;
        appDelegate.completionHandler = Nil;
        completionHander();
    }
}
#endif

@end
