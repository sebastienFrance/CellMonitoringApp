//
//  ConfigViewData.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 01/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RequestUtilities.h"

@protocol ConfigViewDataResponse;

@interface ConfigViewData : NSObject<HTMLDataResponse>

@property(nonatomic, readonly) NSString* IPAddress;
@property(nonatomic, readonly) NSString* portNumber;
@property(nonatomic, readonly) NSString* userName;

- (id) init:(UIViewController<ConfigViewDataResponse>*) theDelegate;
- (void) openConnection:(NSString*) theIPAddress portNumber:(NSString*) thePortNumber userName:(NSString*) theUserName password:(NSString*) thePassword;
@end

@protocol ConfigViewDataResponse 
- (void) connectionSuccess; 
- (UIView*) getView;
@end
