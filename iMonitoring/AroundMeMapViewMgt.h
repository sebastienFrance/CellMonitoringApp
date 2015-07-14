//
//  AroundMeMapViewController.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 15/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MapModeItf.h"

@class NeighborOverlay;
@class CellMonitoring;

@interface AroundMeMapViewMgt : NSObject

@property (nonatomic, weak, readonly) MKMapView* theMapView;


- (id)init:(MKMapView*) theMapView aroundMe:(id<MapModeItf>) theAroundMe;

// Reload Map content from server
- (void) displayMapAroundUserLocation;
- (void) showLocationOnMapAndReload:(CLLocationCoordinate2D) newLocation;
- (void) showLocationOnMapAndReloadWithCamera:(MKMapCamera*) newLocation;

// No cell reload, just graphical update with current data on current map
- (void) refreshMapAnnotationsAndOverlays:(NSArray*) listOfCellsToBeDisplayed
                              annotations:(Boolean) refreshAnnotations
                                 overlays:(Boolean) refreshOverlays;

- (void) refreshMapViewWithCellGroups:(NSArray*) cellGroups selectedCell:(CellMonitoring*) theSelectedCell;
- (void) displayCoverage;
- (void) showCellInRegion:(CellMonitoring*) theCell;
- (void) showNeighborInRegion:(NeighborOverlay*) theNeighbor;

- (MKUserLocation*) getUserLocation;



@end
