//
//  NeighborsDataSourceUtility.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 25/01/2015.
//
//

#import "NeighborsDataSourceUtility.h"
#import "NeighborsDataSource.h"
#import "RequestUtilities.h"
#import "CellMonitoring.h"
#import "NeighborOverlay.h"
#import "CellMonitoringGroup.h"
#import "UserPreferences.h"
#import <MapKit/MapKit.h>

@interface NeighborsDataSourceUtility()

@property (nonatomic) CellMonitoring* centerCell;

@property (nonatomic) NSDictionary* neighborsCells;
@property (nonatomic) NSArray* neighborsOverlays;
@property (nonatomic) NSArray* neighborsIntraFreq;
@property (nonatomic) NSArray* neighborsInterFreq;
@property (nonatomic) NSArray* neighborsInterRAT;
@property (nonatomic) NSArray* neighborsByANR;

// Key: NSString* dlFrequency
// Value: NSArray* NeighborOverlay
@property (nonatomic) NSDictionary* neighborsByInterFreq;

@property (nonatomic) NSArray* cellGroups;
@property (nonatomic) NSDictionary* allNeighorsByTargetCell;

@end

static const NSString* PARAM_targetCell = @"targetCell";

@implementation NeighborsDataSourceUtility

- (id) init:(NSArray*) data centerCell:(CellMonitoring*) theCell {
    // Extract the Neighbors Cells
    if (self = [super init]) {
        
        _centerCell = theCell;
        
        NSDictionary* dicoTargetCells = data[2];
        NSDictionary* neighborsCellsByTelecomId = [self extractNeighborCells:dicoTargetCells];
        
        // extract the NRs
        NSDictionary* dicoNeighbors = data[1];
        [self extractNeighborRelations:dicoNeighbors neighborsCells:neighborsCellsByTelecomId];
    }
    
    return self;
}


#pragma mark - Extract data from JSON

- (NSDictionary*) extractNeighborCells:(NSDictionary*) dicoTargetCells {
    NSArray* targetCells = dicoTargetCells[@"TargetCells"];
    
    NSMutableDictionary* theNeighborsCells = [[NSMutableDictionary alloc] initWithCapacity:targetCells.count];
    NSMutableDictionary* neighborsCellsByTelecomId = [[NSMutableDictionary alloc] initWithCapacity:targetCells.count];
    
    NSMutableDictionary* cellGroups = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary* currCell in targetCells) {
        CellMonitoring* newCell = [[CellMonitoring alloc]initWithDictionary:currCell];
        
        [self addCellToCellGroup:newCell cellGroups:cellGroups];
        
        theNeighborsCells[newCell.id] = newCell;
        neighborsCellsByTelecomId[newCell.telecomId] = newCell;
    }
    
    self.neighborsCells = theNeighborsCells;
    
    if (self.centerCell.parentGroup == Nil) {
        [self addCellToCellGroup:self.centerCell cellGroups:cellGroups];
    }
    
    self.cellGroups = [cellGroups allValues];
    for (CellMonitoringGroup* currentGroup in self.cellGroups) {
        [currentGroup commit];
    }
    
    return neighborsCellsByTelecomId;
}

- (void) addCellToCellGroup:(CellMonitoring*) theCell cellGroups:(NSMutableDictionary*) theCellGroups {
    // Add the center cell to the cellGroup
    NSString* coordKey = [NSString stringWithFormat:@"%f%f", theCell.coordinate.latitude, theCell.coordinate.longitude];
    CellMonitoringGroup* currentCellGroup = theCellGroups[coordKey];
    if (currentCellGroup == Nil) {
        currentCellGroup = [[CellMonitoringGroup alloc] initWithCoordinate:theCell.coordinate];
        theCellGroups[coordKey] = currentCellGroup;
    }
    [currentCellGroup addCell:theCell];
    theCell.parentGroup = currentCellGroup;
}


- (void) extractNeighborRelations:(NSDictionary*) dicoNeighbors neighborsCells:(NSDictionary*) neighborsCellsByTelecomId {
    NSMutableArray* theNeighborsOverlays = [[NSMutableArray alloc] initWithCapacity:self.neighborsCells.count];
    
    NSMutableArray* theNeighborsIntraFreq = [[NSMutableArray alloc] init];
    NSMutableArray* theNeighborsInterFreq = [[NSMutableArray alloc] init];
    NSMutableArray* theNeighborsInterRAT = [[NSMutableArray alloc] init];
    NSMutableArray* theNeighborsByANR = [[NSMutableArray alloc] init];
    
    NSMutableDictionary* theNeighborsByInterFreq = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* allNeighborsByTarget = [[NSMutableDictionary alloc] init];
    
    NSArray* neighbors = dicoNeighbors[@"NR"];
    for (NSDictionary* currentNeighborFromJSON in neighbors) {

        NSString* targetCellName = currentNeighborFromJSON[PARAM_targetCell];
        CellMonitoring* targetCell = neighborsCellsByTelecomId[targetCellName];
        if (targetCell == Nil) {
            // It can happen when we haven't loaded the 3G or 2G cells
            NSLog(@"%s Warning cannot find target cell %@", __PRETTY_FUNCTION__, targetCellName);
        }
        NeighborOverlay* newNeighbor = [[NeighborOverlay alloc] initWithDictionary:currentNeighborFromJSON source:self.centerCell target:targetCell];

        [theNeighborsOverlays addObject:newNeighbor];

        if (allNeighborsByTarget[targetCellName] != Nil) {
            NSLog(@"%s Warning, two neighbors with the same target: %@",__PRETTY_FUNCTION__, targetCellName);
        }

        allNeighborsByTarget[targetCellName] = newNeighbor;
        
        if (newNeighbor.measuredbyANR) {
            [theNeighborsByANR addObject:newNeighbor];
        }
        
        switch (newNeighbor.NRType) {
            case NRInterFreq: {
                [theNeighborsInterFreq addObject:newNeighbor];
                
                NSMutableArray* cellsFreq = theNeighborsByInterFreq[newNeighbor.dlFrequency];
                if (cellsFreq == Nil) {
                    cellsFreq = [[NSMutableArray alloc] init];
                    theNeighborsByInterFreq[newNeighbor.dlFrequency] = cellsFreq;
                }
                [cellsFreq addObject:newNeighbor];
                
                break;
            }
            case NRIntraFreq: {
                [theNeighborsIntraFreq addObject:newNeighbor];
                break;
            }
            case NRInterRAT: {
                [theNeighborsInterRAT addObject:newNeighbor];
                break;
            }
            default: {
                NSLog(@"%s warning, unknown type for NR with target cell: %@", __PRETTY_FUNCTION__, targetCellName);
            }
        }
    }
    
    // Order NR by distance
    self.neighborsOverlays = [theNeighborsOverlays sortedArrayUsingSelector:@selector(compareDistance:)];
    self.neighborsIntraFreq = [theNeighborsIntraFreq sortedArrayUsingSelector:@selector(compareDistance:)];
    self.neighborsInterFreq = [theNeighborsInterFreq sortedArrayUsingSelector:@selector(compareDistance:)];
    self.neighborsInterRAT = [theNeighborsInterRAT sortedArrayUsingSelector:@selector(compareDistance:)];
    self.neighborsByANR = [theNeighborsByANR sortedArrayUsingSelector:@selector(compareDistance:)];
    
    self.allNeighorsByTargetCell = allNeighborsByTarget;
    
    // For each Frequency, order by distance
    NSMutableDictionary* orderedNeighborsByInterFreq = [[NSMutableDictionary alloc] init];
    for (NSString* key in theNeighborsByInterFreq) {
        NSArray* neighbors = theNeighborsByInterFreq[key];
        NSArray* neighborsOrderedByDistance = [neighbors sortedArrayUsingSelector:@selector(compareDistance:)];
        orderedNeighborsByInterFreq[key] = neighborsOrderedByDistance;
    }
    
    self.neighborsByInterFreq = orderedNeighborsByInterFreq;
}

@end
