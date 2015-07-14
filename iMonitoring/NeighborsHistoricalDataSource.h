//
//  NeighborsHistoricalDataSource.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 24/01/2015.
//
//

#import <Foundation/Foundation.h>
#import "RequestUtilities.h"

@protocol NeighborsHistoricalLoadingItf;

@interface NeighborsHistoricalDataSource : NSObject<HTMLDataResponse>

@property (nonatomic, readonly) NSArray* theHistoricalData;

- (id) init:(id<NeighborsHistoricalLoadingItf>) delegate ;
- (void) loadData:(CellMonitoring*) theCenterCell;

@end

@protocol NeighborsHistoricalLoadingItf

- (void) neighborsHistoricalDataIsLoaded:(CellMonitoring*) centerCell;
- (void) neighborsHistoricalDataLoadingFailure;
@end