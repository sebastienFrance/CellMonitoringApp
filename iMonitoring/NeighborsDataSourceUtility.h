//
//  NeighborsDataSourceUtility.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 25/01/2015.
//
//

#import <Foundation/Foundation.h>
#import "CellMonitoring.h"

@interface NeighborsDataSourceUtility : NSObject

@property (nonatomic, readonly) NSDictionary* neighborsCells;
@property (nonatomic, readonly) NSArray* neighborsOverlays;
@property (nonatomic, readonly) NSArray* neighborsIntraFreq;
@property (nonatomic, readonly) NSArray* neighborsInterFreq;
@property (nonatomic, readonly) NSArray* neighborsInterRAT;
@property (nonatomic, readonly) NSArray* neighborsByANR;
@property (nonatomic, readonly) NSDictionary* neighborsByInterFreq;
@property (nonatomic, readonly) NSDictionary* allNeighorsByTargetCell;
@property (nonatomic, readonly) NSArray* cellGroups;

@property (nonatomic, readonly) CellMonitoring* centerCell;

// Extract NR and target cells from JSON
- (id) init:(NSArray*) data centerCell:(CellMonitoring*) theCell;

@end
