//
//  NeighborsDataSource.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 01/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestUtilities.h"

@protocol NeighborsLoadingItf;
@class NeighborsDataSourceUtility;

@interface NeighborsDataSource : NSObject<HTMLDataResponse>

@property (nonatomic, readonly) CellMonitoring* centerCell;
@property(nonatomic, readonly) NeighborsDataSourceUtility* neighborData;

- (id) init:(id<NeighborsLoadingItf>) delegate ;
- (void) loadData:(CellMonitoring*) theCenterCell;

-(void) displayFilteredNeighborsOnMap:(MKMapView*) mapView;

@end

@protocol NeighborsLoadingItf 

- (void) neighborsDataIsLoaded:(CellMonitoring*) centerCell;
- (void) neighborsDataLoadingFailure;
@end