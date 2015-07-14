//
//  AroundMeViewData.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 04/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RequestUtilities.h"
#import "NeighborsDataSource.h"

@class RouteInformation;

@protocol CellDataSourceDelegate;


// used to download cells and neighbors from the server
// Cells and neighbors are kept in memory while no new cells are downloaded

@interface cellDataSource : NSObject <HTMLDataResponse, NeighborsLoadingItf>

@property (nonatomic, readonly) NSArray* filteredCells;
@property (nonatomic, readonly) NSArray* neighborsOverlay;
@property (nonatomic, readonly) NeighborsDataSource* neighborsDataSource;
@property (nonatomic) NSString* selectedCell;

@property (nonatomic, readonly) Boolean hasLatestCenterCoordinate;
@property (nonatomic, readonly) CLLocationCoordinate2D latestCenterCoordinate;

@property (nonatomic, readonly) NSArray* cellGroups;

@property (nonatomic) MKRoute* theEndRoute;


- (void) loadCellsAroundCoordinate:(double) theLatitude
                         longitude:(double) theLongitude
                          distance:(double) theDistance
                          delegate:(id<CellDataSourceDelegate>) theDelegate;

- (void) loadCellsFromZone:(NSString*) zoneName delegate:(id<CellDataSourceDelegate>) theDelegate;
- (void) loadNeighborsCellsFrom:(CellMonitoring*) neighborCenterCell delegate:(id<CellDataSourceDelegate>) theDelegate;
- (void) loadCellsFromNavigation:(NSArray*) navCells delegate:(id<CellDataSourceDelegate>) theDelegate;
- (void) loadCellsAroundRoute:(RouteInformation*) theRoute direction:(MKRoute*) theRouteDirection delegate:(id<CellDataSourceDelegate>) theDelegate;
- (void) loadACell:(NSString*) theCellId delegate:(id<CellDataSourceDelegate>) theDelegate;


// refresh filtered cells based on current user filter
- (NSArray*) refreshFilteredCells;

- (NSArray*) getFilteredCellsForTechnoId:(DCTechnologyId) technoId;
- (NSUInteger) getFilteredCellCountForTechnoId:(DCTechnologyId) technoId;
- (NSArray*) getAllCellsForTechnoId:(DCTechnologyId) technoId;

@end

@protocol CellDataSourceDelegate <NSObject>

- (void) cellDataSourceLoaded:(CellMonitoring*) theSelectedCell cellGroups:(NSArray*) theCellGroups error:(NSError*) theError;

@end



