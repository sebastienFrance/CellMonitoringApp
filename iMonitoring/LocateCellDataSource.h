//
//  LocateCellDataSource.h
//  iMonitoring
//
//  Created by sébastien brugalières on 14/12/2013.
//
//

#import <Foundation/Foundation.h>
#import "RequestUtilities.h"

@protocol LocateCellDelegate;

@interface LocateCellDataSource : NSObject<HTMLDataResponse>


- (id) initWithCellDelegate:(id<LocateCellDelegate>) delegate;

- (void) requestCellStartingWith:(NSString*) searchText technology:(NSString*) scope maxResults:(NSUInteger) maxResultsRequested;

@end

@protocol LocateCellDelegate <NSObject>

-(void) cellStartingWithResponse:(NSMutableArray*) cells error:(NSError*) theError;


@end