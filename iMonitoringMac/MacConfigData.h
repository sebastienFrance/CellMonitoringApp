//
//  MacConfigData.h
//  iMonitoring
//
//  Created by sébastien brugalières on 08/12/2013.
//
//

#import <Foundation/Foundation.h>
#import "RequestUtilities.h"
#import "HTMLRequest.h"

@protocol MacConfigViewDataResponse;

@interface MacConfigData : NSObject<HTMLDataResponse>

@property(nonatomic, readonly) NSString* IPAddress;
@property(nonatomic, readonly) NSString* portNumber;
@property(nonatomic, readonly) NSString* userName;

- (id) init:(id<MacConfigViewDataResponse>) theDelegate;
- (void) openConnection:(NSString*) theIPAddress portNumber:(NSString*) thePortNumber userName:(NSString*) theUserName password:(NSString*) thePassword;
@end

@protocol MacConfigViewDataResponse
- (void) connectionSuccess;

@end
