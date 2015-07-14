//
//  ConnectionManager.h
//  iMonitoring
//
//  Created by sébastien brugalières on 08/12/2013.
//
//

#import <Foundation/Foundation.h>

@interface ConnectionManager : NSObject

@property (nonatomic, readonly) NSString* IPAddress;
@property (nonatomic, readonly) NSString* portNumber;
@property (nonatomic, readonly) NSString* userName;
@property (nonatomic, readonly) NSString* password;

+ (ConnectionManager*) sharedInstance;

- (void) setServerConfiguration:(NSString*) IPAddress portNumber:(NSString*) port userName:(NSString*) theUserName password:(NSString*) thePassword;
- (void) updatePassword:(NSString*) password;

@end
