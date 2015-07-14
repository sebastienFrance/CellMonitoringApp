//
//  NeighborOverlay.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 14/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "BasicTypes.h"

@class CellMonitoring;



@interface NeighborOverlay : NSObject <MKOverlay>

@property (nonatomic, readonly) Boolean noRemove;
@property (nonatomic, readonly) Boolean noHo;
@property (nonatomic, readonly) Boolean measuredbyANR;

@property (nonatomic, readonly) NSString* dlFrequency;
@property (nonatomic, readonly) NRTypeId NRType;
@property (nonatomic, readonly) NSString* NRTypeString;


@property (nonatomic, readonly) CLLocationDistance distanceSourceTarget;
@property (nonatomic, readonly) NSString* distance;

@property (nonatomic, readonly) MKPolyline* thePolyline;
@property (nonatomic, readonly) CellMonitoring* sourceCell;
@property (nonatomic, readonly) CellMonitoring* targetCell;
@property (nonatomic, readonly) NSString* targetCellId; // to be used when target cannot be found
@property (nonatomic, readonly) MKPolylineRenderer* polylineView;

#pragma mark - Constructor
- (id) initWithDictionary:(NSDictionary*) neighborDictionary source:(CellMonitoring*) sourceCell target:(CellMonitoring*) targetCell;

#pragma mark - Distance utilities

- (NSComparisonResult) compareDistance:(NeighborOverlay *)otherObject;
- (NSComparisonResult) compareDistanceFromShortest:(NeighborOverlay *)otherObject;

+ (NSArray*) getNeighborWithDistanceGreaterThanMin:(NSArray*) neighbors;
+ (NSArray*) getFilteredNeighborOverlayFor:(NSArray*) neighbors;

@end
