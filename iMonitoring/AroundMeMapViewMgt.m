//
//  AroundMeMapViewController.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 15/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AroundMeMapViewMgt.h"
#import "CellMonitoring.h"
#import "CellMonitoringGroup.h"
#import "cellDataSource.h"
#import "NeighborOverlay.h"
#import "UserPreferences.h"
#import "AroundMeMapViewDelegate.h"
#import "NeighborsDataSource.h"
#import "AzimuthsOverlay.h"

@interface AroundMeMapViewMgt()

@property(nonatomic, strong)  MKCircle* circleForCoverage;

@property(nonatomic, weak) id<MapModeItf> delegate;

@end

@implementation AroundMeMapViewMgt


- (id)init:(MKMapView*) theMapView aroundMe:(id<MapModeItf>) theAroundMe {
    if (self = [super init]) {
        _theMapView = theMapView;
        _delegate = theAroundMe;
    }
    return self;
}


#pragma mark - Public methods

// This method is called when the content of the map has been reloaded from the server
- (void) refreshMapViewWithCellGroups:(NSArray*) cellGroups selectedCell:(CellMonitoring*) theSelectedCell {
    
    [self refreshMapAnnotationsAndOverlays:cellGroups annotations:TRUE overlays:TRUE];
    
    MapModeEnabled currentMapMode = self.delegate.currentMapMode;
    
    
    if ((currentMapMode == MapModeZone) ||
        (currentMapMode == MapModeNeighbors) ||
        (currentMapMode == MapModeNavMultiCell) ||
        (currentMapMode == MapModeRoute)) {
        MKCoordinateRegion region = [CellMonitoringGroup getRegionThatFitsCells:cellGroups];
        [self.theMapView setRegion:region];
    }
    
    if (theSelectedCell != Nil) {
        [self.theMapView selectAnnotation:theSelectedCell.parentGroup animated:FALSE];
    }
    
}

// Put on the map the annotations and overlays (Sectors and Neighbors)
- (void) refreshMapAnnotationsAndOverlays:(NSArray*) listOfCellsToBeDisplayed annotations:(Boolean) refreshAnnotations overlays:(Boolean) refreshOverlays {

    if (refreshAnnotations) {
        [self refreshAnnotations:listOfCellsToBeDisplayed mapView:self.theMapView];
    }
    
    // Overlays must always be refreshed when annotations are refreshed (for example, WCDMA cells are displayed wih sector and then WCDMA cells are filtered => must remove
    // also the sector overlays of cells
    if (refreshOverlays || refreshAnnotations) {
        [self refreshOverlays:listOfCellsToBeDisplayed mapView:self.theMapView];
    }
}



// Add or Remove the overlay to display the coverage on the map depending on user Preferences
- (void) displayCoverage {
    if (self.delegate.currentMapMode != MapModeRoute) {
        
        [self.theMapView removeOverlay:self.circleForCoverage];
        
        if ([UserPreferences sharedInstance].isDisplayCoverage) {
            if (self.delegate.currentMapMode != MapModeZone) {
                MKCircle* circle;
                if (self.delegate.datasource.hasLatestCenterCoordinate) {
                    circle = [MKCircle circleWithCenterCoordinate:self.delegate.datasource.latestCenterCoordinate radius:[UserPreferences sharedInstance].RangeInMeters];
                } else {
                    circle = [MKCircle circleWithCenterCoordinate:self.theMapView.centerCoordinate radius:[UserPreferences sharedInstance].RangeInMeters];
                    
                }
                
                // Add coverage on the map
                self.circleForCoverage = circle;
                [self.theMapView addOverlay:circle level:MKOverlayLevelAboveRoads];
            }
        }
    }
}

// Find the current user location and reload the map with all cells
- (void) displayMapAroundUserLocation {

    MKUserLocation* userLocation = self.theMapView.userLocation;
    if (userLocation != Nil) {
        [self showLocationOnMapAndReload:userLocation.location.coordinate];
    }    
}

- (MKUserLocation*) getUserLocation {
    return self.theMapView.userLocation;
}



// Show the regions and RELOAD all cells from this region
- (void) showLocationOnMapAndReload:(CLLocationCoordinate2D) newLocation {
    
    MKMapCamera* endCamera = [self getDefaultEndCamera:newLocation];
    
    [AroundMeMapViewMgt configureMapRegionWithCamera:endCamera MapView:self.theMapView reloadCells:TRUE];
}


- (void) showLocationOnMapAndReloadWithCamera:(MKMapCamera*) newLocation {
    [AroundMeMapViewMgt configureMapRegionWithCamera:newLocation MapView:self.theMapView reloadCells:TRUE];
 }


// Just to show a cell in the region WITHOUT reloading cells from the region
- (void) showCellInRegion:(CellMonitoring*) theCell {
    
    MKMapCamera* endCamera = [self getDefaultEndCamera:theCell.coordinate];
    

    AroundMeMapViewDelegate *delegateMap = (AroundMeMapViewDelegate*) self.theMapView.delegate;
    [delegateMap goToCoordinateWithoutAnimation:endCamera MapView:self.theMapView reloadCells:FALSE];
    
    [self.theMapView selectAnnotation:theCell.parentGroup animated:TRUE];
}



- (void) showNeighborInRegion:(NeighborOverlay*) theNeighbor {
    NSArray* cells = @[theNeighbor.sourceCell, theNeighbor.targetCell];
    MKCoordinateRegion newRegion = [CellMonitoring getRegionThatFitsCells:cells];
    
    [self.theMapView setRegion:newRegion animated:FALSE];
    [self.theMapView selectAnnotation:theNeighbor.targetCell.parentGroup animated:TRUE];
}


#pragma mark - Private methods

+ (void) configureMapRegionWithCamera:(MKMapCamera*) newCamera MapView:(MKMapView*) theMapView reloadCells:(Boolean) forceToReloadCells {
    
    // For Performance, remove all annotations and overlays before to start animations
    [theMapView removeAnnotations:theMapView.annotations];
    [theMapView removeOverlays:theMapView.overlays];
    
    AroundMeMapViewDelegate *delegate = (AroundMeMapViewDelegate*) theMapView.delegate;
    [delegate goToCoordinate:newCamera MapView:theMapView reloadCells:forceToReloadCells];
}


- (void) refreshAnnotations:(NSArray*) listOfCellsToBeDisplayed mapView:(MKMapView*) theMapView {
    // Remove all annotations and add all new annotations
    [theMapView removeAnnotations:theMapView.annotations];
    [theMapView addAnnotations:listOfCellsToBeDisplayed];
    
    if (theMapView.userLocationVisible) {
        [theMapView setShowsUserLocation:YES];
    }
    
}

- (void) refreshOverlays:(NSArray*) listOfCellsToBeDisplayed mapView:(MKMapView*) theMapView {
    NSArray* overlayToRemove = theMapView.overlays;
    [theMapView removeOverlays:overlayToRemove];
    
    //NSLog(@"%s: Removed all overlays %lu", __PRETTY_FUNCTION__, (unsigned long)overlayToRemove.count);
   
    [self displaySectorOverlays:listOfCellsToBeDisplayed];
    [self displayCoverage];
    [self displayRoute:theMapView];
    
    [self addNeighborOverlay];
}

- (void) displaySectorOverlays:(NSArray*) listOfCellsToBeDisplayed {
    if ([UserPreferences sharedInstance].isDisplaySectors) {
        
        NSMutableArray* fullOverlayList = [[NSMutableArray alloc] init];
        for (CellMonitoringGroup* currentGroup in listOfCellsToBeDisplayed) {
            AzimuthsOverlay* azimuthOverlays = currentGroup.azimuthOverlays;
            if (azimuthOverlays != Nil) {
                [fullOverlayList addObject:azimuthOverlays];
            }
        }
        [self.theMapView addOverlays:fullOverlayList];
        
       // NSLog(@"%s: Added Azimuth overlay %lu", __PRETTY_FUNCTION__, (unsigned long)fullOverlayList.count);
    }
}


- (void) displayRoute:(MKMapView*) theMapView {
    if (self.delegate.currentMapMode == MapModeRoute) {
        cellDataSource* datasource = self.delegate.datasource;
        if (datasource.theEndRoute != Nil) {
            [theMapView addOverlay:datasource.theEndRoute.polyline level:MKOverlayLevelAboveRoads];
        }
    }
}

- (void) addNeighborOverlay {
    if (self.delegate.currentMapMode == MapModeNeighbors) {

        [self.delegate.datasource.neighborsDataSource displayFilteredNeighborsOnMap:self.theMapView];
    }
}


- (MKMapCamera*) getDefaultEndCamera:(CLLocationCoordinate2D) endLocation {

    if (self.theMapView.mapType == MKMapTypeSatelliteFlyover ||
        self.theMapView.mapType == MKMapTypeHybridFlyover) {
        MKMapCamera *endCamera = [MKMapCamera cameraLookingAtCenterCoordinate:endLocation
                                                                 fromDistance:100
                                                                        pitch:70
                                                                      heading:0];
        return endCamera;
    } else {
        MKMapCamera *endCamera = [MKMapCamera cameraLookingAtCenterCoordinate:endLocation
                                                            fromEyeCoordinate:endLocation
                                                                  eyeAltitude:500];
        endCamera.pitch = 55;
        return endCamera;
    }
    
}

@end
