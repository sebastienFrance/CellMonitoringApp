//
//  SessionURLRequestHandler.h
//  CellMonitoring
//
//  Created by sébastien brugalières on 27/04/2014.
//
//

#import <Foundation/Foundation.h>

#import "HTMLRequest.h"

@interface SessionURLRequestHandler : NSObject<HTMLRequest>

- (void) requestHasCompleted:(NSData*) result;
- (void) requestHasFailed;

@property (nonatomic) Boolean isZipped;
@property (nonatomic) NSString* zippedFileName;
@property (nonatomic) NSString* clientId;

@end
