//
//  NeighborsDataSource.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 01/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NeighborsDataSource.h"
#import "RequestUtilities.h"
#import "CellMonitoring.h"
#import "NeighborOverlay.h"
#import "CellMonitoringGroup.h"
#import "UserPreferences.h"
#import <MapKit/MapKit.h>
#import "NeighborsDataSourceUtility.h"

@interface NeighborsDataSource() {
    CellMonitoring* _centerCell;
}


@property(nonatomic) NeighborsDataSourceUtility* neighborData;

@property (nonatomic, weak) id<NeighborsLoadingItf> delegate;

@end

@implementation NeighborsDataSource

#pragma mark - HTMLDataResponse
- (void) connectionFailure:(NSString*) theClientId {
    [self.delegate neighborsDataLoadingFailure];
}


- (void) dataReady:(id) theData clientId:(NSString*) theClientId {
    NSArray* data = theData;

    self.neighborData = [[NeighborsDataSourceUtility alloc] init:data centerCell:_centerCell];
    
    [self.delegate neighborsDataIsLoaded:self.centerCell];
}

#pragma mark - Readonly accessors

#pragma mark - Utility method
-(void) displayFilteredNeighborsOnMap:(MKMapView*) mapView {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    
    if (userPrefs.isDisplayNeighborsIntraFreq) {
        NSArray* neighbors = [NeighborOverlay getFilteredNeighborOverlayFor:self.neighborData.neighborsIntraFreq];
        [mapView addOverlays:neighbors];
    }
    if (userPrefs.isDisplayNeighborsInterFreq) {
        NSArray* neighbors = [NeighborOverlay getFilteredNeighborOverlayFor:self.neighborData.neighborsInterFreq];
        [mapView addOverlays:neighbors];
    }
    
    if (userPrefs.isDisplayNeighborsInterRAT) {
        NSArray* neighbors = [NeighborOverlay getFilteredNeighborOverlayFor:self.neighborData.neighborsInterRAT];
        [mapView addOverlays:neighbors];
    }
}


#pragma mark - Initialization

- (id) init:(id<NeighborsLoadingItf>) delegate {
    
    if (self = [super init]) {
        _delegate = delegate;
    }
    
    return self;
    
}

#pragma mark - Request to download NRs

- (void) loadData:(CellMonitoring*) theCenterCell {
    _centerCell = theCenterCell;
    [RequestUtilities getCellWithNeighbors:self cell:_centerCell clientId:@"CellNeighbors"]; 
}


@end
