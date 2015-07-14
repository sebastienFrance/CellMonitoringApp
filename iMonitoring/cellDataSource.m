//
//  AroundMeViewData.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 04/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cellDataSource.h"

#import "CellMonitoring.h"
#import "CellMonitoringGroup.h"
#import "RequestUtilities.h"
#import "CellBookmark+MarkedCell.h"
#import "UserPreferences.h"
#import "CellFilter.h"
#import "RouteInformation.h"
#import "NeighborsDataSourceUtility.h"

@interface cellDataSource ()

@property (nonatomic) NSArray* cellGroups;

@property (nonatomic, weak) id<CellDataSourceDelegate> delegate;

@end

@implementation cellDataSource

@synthesize neighborsOverlay;


- (id)init {
    if (self = [super init]) {
        _hasLatestCenterCoordinate = FALSE;
    }
    return self;
}

#pragma mark - Accessors

- (NSArray*) getFilteredCellsForTechnoId:(DCTechnologyId) technoId {
    
    NSMutableArray* cellForTechno = [[NSMutableArray alloc] init];
    
    for (CellMonitoringGroup* currentCellGroup in self.cellGroups) {
        [cellForTechno addObjectsFromArray:[currentCellGroup getFilteredCellsForTechnoId:technoId]];
    }
    return cellForTechno;
}

- (NSArray*) getAllCellsForTechnoId:(DCTechnologyId) technoId {
    NSMutableArray* cellForTechno = [[NSMutableArray alloc] init];

    for (CellMonitoringGroup* currentCellGroup in self.cellGroups) {
        [cellForTechno addObjectsFromArray:[currentCellGroup getAllCellsForTechnoId:technoId]];
    }
    return cellForTechno;
}


- (NSUInteger) getFilteredCellCountForTechnoId:(DCTechnologyId) technoId {
    NSUInteger sumCountByTechno = 0;
    for (CellMonitoringGroup* currentGroup in self.cellGroups) {
        sumCountByTechno += [currentGroup getFilteredCellCountForTechnoId:technoId];
    }
    
    return sumCountByTechno;
}

- (NSArray*) filteredCells {
    NSMutableArray* cellForTechno = [[NSMutableArray alloc] init];
    
    for (CellMonitoringGroup* currentCellGroup in self.cellGroups) {
        [cellForTechno addObjectsFromArray:currentCellGroup.filteredCells];
    }
    return cellForTechno;   
}

- (NSArray*) neighborsOverlay {
    return _neighborsDataSource.neighborData.neighborsOverlays;
}

#pragma mark - Refresh cell lists

- (NSArray*) refreshFilteredCells {
    
    CellFilter* currentCellFilter = [[CellFilter alloc] init];

    for (CellMonitoringGroup *currentCellGroup in self.cellGroups) {
        [currentCellGroup refreshCellGroupFromFilter:currentCellFilter];
    }

    return [self removeEmptyCellGroupsFrom:self.cellGroups];
}

- (NSArray*) removeEmptyCellGroupsFrom:(NSArray*) cellGroups {
    if ([UserPreferences sharedInstance].isFilterEmptySite == FALSE) {
        NSMutableArray* newCellGroups = [[NSMutableArray alloc] init];
        for (CellMonitoringGroup* currentCellGroup in cellGroups) {
            if (currentCellGroup.hasVisibleCells) {
                [newCellGroups addObject:currentCellGroup];
            }
        }
        return newCellGroups;
    } else {
        return cellGroups;
    }
}


+ (void) addMarkedCellsToFilteredCells:(NSArray*) cells filteredCells:(NSMutableArray*) theFilteredCells{
    
    for (CellMonitoring* cell in cells) {
        if ([CellBookmark isCellMarked:cell]) {
            [theFilteredCells addObject:cell];
        }
    }
}


#pragma mark - Data loader

- (void) loadCellsAroundCoordinate:(double) theLatitude longitude:(double) theLongitude distance:(double) theDistance delegate:(id<CellDataSourceDelegate>) theDelegate {
    
    self.delegate = theDelegate;
    
    _hasLatestCenterCoordinate = TRUE;
    _latestCenterCoordinate.latitude = theLatitude;
    _latestCenterCoordinate.longitude = theLongitude;
    
    [RequestUtilities getCellsAround:_latestCenterCoordinate distance:theDistance delegate:self clientId:@"getCellsAround"];
}



- (void) loadCellsFromZone:(NSString*) zoneName delegate:(id<CellDataSourceDelegate>) theDelegate {
    self.delegate = theDelegate;

    _hasLatestCenterCoordinate = FALSE;
    [RequestUtilities getCellsOfZone:zoneName delegate:self clientId:@"getCellsOfZone"];
}


- (void) loadNeighborsCellsFrom:(CellMonitoring*) neighborCenterCell delegate:(id<CellDataSourceDelegate>) theDelegate {
    
    self.delegate = theDelegate;

    _hasLatestCenterCoordinate = TRUE;
    _latestCenterCoordinate = neighborCenterCell.coordinate;
    _neighborsDataSource = [[NeighborsDataSource alloc] init:self];
    
    [_neighborsDataSource loadData:neighborCenterCell];
}

- (void) loadACell:(NSString*) theCellId delegate:(id<CellDataSourceDelegate>) theDelegate {
    
    self.delegate = theDelegate;
    
    _hasLatestCenterCoordinate = FALSE;
    self.selectedCell = theCellId;
    
    [RequestUtilities getACell:theCellId delegate:self clientId:@"getACell"];
}

- (void) loadCellsFromNavigation:(NSArray*) navCells delegate:(id<CellDataSourceDelegate>) theDelegate {
    
    self.delegate = theDelegate;

    _hasLatestCenterCoordinate = FALSE;
    
    [RequestUtilities getCells:navCells delegate:self clientId:@"getCellsOfNav"];
}

- (void) loadCellsAroundRoute:(RouteInformation*) theRoute direction:(MKRoute*) theRouteDirection delegate:(id<CellDataSourceDelegate>) theDelegate {
    self.delegate = theDelegate;
    
    _hasLatestCenterCoordinate = TRUE;
    _latestCenterCoordinate = theRoute.routeEnd;
    
    self.theEndRoute = theRouteDirection;
    
    float floadDistance = theRoute.distanceLookup / 1000.0;
    
    [RequestUtilities getCellsAroundRoute:self.theEndRoute distance:floadDistance delegate:self clientId:@"getCellsAroundRoute"];

}


#pragma mark - NeighborsLoadingItf protocol

- (void) neighborsDataIsLoaded:(CellMonitoring*) centerCell {
    
    NSDictionary* cells = _neighborsDataSource.neighborData.neighborsCells;
    NSMutableArray* neighborCells = [[NSMutableArray alloc] initWithArray:[cells allValues]];
    
    [neighborCells addObject:centerCell];
    [neighborCells sortUsingComparator:^(CellMonitoring* obj1, CellMonitoring* obj2) {
        
        return [obj1.id compare:obj2.id];
    }];

    self.cellGroups = Nil; // Cleanup old group of cells from memory
    // split the cells in the different table depending on their technology
    NSMutableDictionary* cellGroups = [[NSMutableDictionary alloc] init];

    for (CellMonitoring* currentCell in neighborCells) {
        
        // Add the cell to the list of cells classified by Geo Coordinates to find all cell with the same geo Coord
        NSString* coordKey = [NSString stringWithFormat:@"%f%f",currentCell.coordinate.latitude, currentCell.coordinate.longitude];
        CellMonitoringGroup* currentCellGroup = cellGroups[coordKey];
        if (currentCellGroup == Nil) {
            currentCellGroup = [[CellMonitoringGroup alloc] initWithCoordinate:currentCell.coordinate];
            cellGroups[coordKey] = currentCellGroup;
        }
        [currentCellGroup addCell:currentCell];
        currentCell.parentGroup = currentCellGroup;

    }
    
    self.cellGroups = [cellGroups allValues];
    for (CellMonitoringGroup* currentGroup in self.cellGroups) {
        [currentGroup commit];
    }

    
    NSArray* cellsGroupOnMap = [self removeEmptyCellGroupsFrom:self.cellGroups];
    [self.delegate cellDataSourceLoaded:Nil cellGroups:cellsGroupOnMap error:Nil];
}

- (void) neighborsDataLoadingFailure {

    NSError* error = [[NSError alloc] initWithDomain:@"Communication Error" code:1 userInfo:Nil];
    [self.delegate cellDataSourceLoaded:Nil cellGroups:Nil error:error];
}

#pragma mark - HTMLDataResponse protocol


- (void) dataReady: (id) theData clientId:(NSString *)theClientId {
    NSArray* data = theData;

    if (data == Nil) {
        NSError* error = [[NSError alloc] initWithDomain:@"Communication Error" code:1 userInfo:Nil];
        [self.delegate cellDataSourceLoaded:Nil cellGroups:Nil error:error];
        return;
    }
   
    //NSLog(@"CellDetails data: %@", data);
    
    self.cellGroups = Nil; // cleanup memory before to create new cells.
    NSMutableDictionary* newCellGroups = [[NSMutableDictionary alloc] init];
        
    // find the cell that was used to make the search 
    CellMonitoring* theSelectedCell = Nil;
   
    // Look all cells returned from the server
    for (NSDictionary* currCell in data) {

        if (currCell == (id)[NSNull null]) continue; // defense, ignore cells not found.
        
        // create a new cell and initialize its properties
        CellMonitoring* newCell = [[CellMonitoring alloc]initWithDictionary:currCell];
               
        if (_selectedCell != Nil) {
            if ([newCell.id isEqualToString:_selectedCell]) {
                theSelectedCell = newCell;
                self.selectedCell = Nil;
            }
        }
        
        // Add the cell to the list of cells classified by Geo Coordinates to find all cell with the same geo Coord
        NSString* coordKey = [NSString stringWithFormat:@"%f%f",newCell.coordinate.latitude, newCell.coordinate.longitude];
        // add list of cells in CellGroup
        
        CellMonitoringGroup* currentCellGroup = newCellGroups[coordKey];
        if (currentCellGroup == Nil) {
            currentCellGroup = [[CellMonitoringGroup alloc] initWithCoordinate:newCell.coordinate];
            newCellGroups[coordKey] = currentCellGroup;
        }
        [currentCellGroup addCell:newCell];
        newCell.parentGroup = currentCellGroup;
        if (newCell.parentGroup == Nil) {
            NSLog(@"Warning, no parent group for cell: %@",newCell.id);
            
            
        }
    }

    self.cellGroups = [newCellGroups allValues];
    for (CellMonitoringGroup* currentGroup in self.cellGroups) {
        [currentGroup commit];
    }

    NSArray* cellsGroupOnMap = [self removeEmptyCellGroupsFrom:self.cellGroups];
    
    [self.delegate cellDataSourceLoaded:theSelectedCell cellGroups:cellsGroupOnMap error:Nil];
}



- (void) connectionFailure:(NSString*) theClientId {
    NSError* error = [[NSError alloc] initWithDomain:@"Communication Error" code:1 userInfo:Nil];
    [self.delegate cellDataSourceLoaded:Nil cellGroups:Nil error:error];
}



@end
