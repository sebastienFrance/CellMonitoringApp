//
//  CellTimezoneDataSource.m
//  iMonitoring
//
//  Created by sébastien brugalières on 23/12/2013.
//
//

#import "CellTimezoneDataSource.h"
#import "RequestUtilities.h"
#import "Utility.h"
#import "CellMonitoring.h"

@interface CellTimezoneDataSource()

@property (nonatomic, weak) id<CellTimezoneDataSourceDelegate> delegate;
@property (nonatomic, weak) CellMonitoring* theCell;

@end

@implementation CellTimezoneDataSource

#warning SEB: Timezone to be removed
- (id) initWithDelegate:(id<CellTimezoneDataSourceDelegate>) delegate cell:(CellMonitoring*) theCell{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _theCell = theCell;
    }
    return self;

}

-(void) loadTimeZone {
    [RequestUtilities getTimeZone:[self.theCell coordinate] delegate:self clientId:@"getTimeZone"];
}

#pragma mark - HTML Request Callbacks
- (void) dataReady: (id) theData clientId:(NSString *)theClientId {
    
    if ([theClientId isEqualToString:@"getTimeZone"]) {
        self.theCell.theTimezone= [Utility extractTimezoneFromData:theData];
        [self.delegate cellTimezoneResponse:self.theCell error:Nil];
    } else {
        NSError* error = [[NSError alloc] initWithDomain:@"Communication Error" code:1 userInfo:Nil];
        [self.delegate cellTimezoneResponse:self.theCell error:error];
    }
}


- (void) connectionFailure:(NSString*) theClientId {
    NSError* error = [[NSError alloc] initWithDomain:@"Communication Error" code:1 userInfo:Nil];
    [self.delegate cellTimezoneResponse:self.theCell error:error];
}




@end
