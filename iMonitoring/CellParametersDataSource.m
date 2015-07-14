//
//  CellParametersDataSource.m
//  iMonitoring
//
//  Created by sébastien brugalières on 22/12/2013.
//
//

#import "CellParametersDataSource.h"
#import "CellMonitoring.h"
#import "CellParameterUtility.h"

@interface CellParametersDataSource()

@property (nonatomic, weak) CellMonitoring* theCell;
@property (nonatomic, weak) id<CellParametersDataSourceDelegate> theDelegate;

@end

@implementation CellParametersDataSource


- (id) init:(id<CellParametersDataSourceDelegate>) delegate {
    if (self = [super init]) {
        _theDelegate = delegate;
    }
    
    return self;
}

-(void) loadData:(CellMonitoring *)cell {
    
    self.theCell = cell;
    [RequestUtilities getCellParameters:self.theCell delegate:self clientId:@"cellParameters"];
}

#pragma mark - HTMLDataResponse protocol
- (void) dataReady: (id) theData clientId:(NSString *)theClientId {
    
    if ([theClientId isEqualToString:@"cellParameters"]) {
        Parameters* cellParameter = [CellParameterUtility buildParameters:theData];
        
        [self.theCell initializeCellParameters:cellParameter];
        [self.theDelegate cellParametersWithResponse:self.theCell error:Nil];
    } else {
        NSLog(@"Unknown clientId: %@", theClientId);
        NSError* error = [[NSError alloc] initWithDomain:@"Communication Error" code:1 userInfo:Nil];
        [self.theDelegate cellParametersWithResponse:self.theCell error:error];
    }
}


- (void) connectionFailure:(NSString*) theClientId {
    NSError* error = [[NSError alloc] initWithDomain:@"Communication Error" code:1 userInfo:Nil];
    [self.theDelegate cellParametersWithResponse:self.theCell error:error];
}




@end
