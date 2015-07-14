//
//  LocateCellDataSource.m
//  iMonitoring
//
//  Created by sébastien brugalières on 14/12/2013.
//
//

#import "LocateCellDataSource.h"
#import "CellMonitoring.h"

@interface LocateCellDataSource()

@property (nonatomic) id<LocateCellDelegate> delegate;

@end


@implementation LocateCellDataSource


- (id) initWithCellDelegate:(id<LocateCellDelegate>) delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        // Custom initialization
    }
    return self;
}

- (void) dataReady: (id) theData clientId:(NSString *)theClientId {
    NSArray* data = theData;
    
    NSMutableArray* listOfCells = [[NSMutableArray alloc] initWithCapacity:data.count];
    
    for (NSDictionary* currCell in data) {
        CellMonitoring* newCell = [[CellMonitoring alloc] initWithDictionary:currCell];
        
        [listOfCells addObject:newCell];
    }
    
    [self.delegate cellStartingWithResponse:listOfCells error:Nil];
}

- (void) connectionFailure:(NSString*) theClientId {
    NSError* error = [[NSError alloc] initWithDomain:@"Communication Error" code:1 userInfo:Nil];
    [self.delegate cellStartingWithResponse:Nil error:error];
}


- (void) requestCellStartingWith:(NSString*) searchText technology:(NSString*) scope maxResults:(NSUInteger) maxResultsRequested {
    [RequestUtilities getCellsStartingWith:searchText technology:scope maxResults:maxResultsRequested delegate:self clientId:@"getCellsStartingWith"];
}



@end
