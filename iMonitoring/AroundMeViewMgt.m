//
//  AroundMeViewMgt.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 04/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AroundMeViewMgt.h"
#import "cellDataSource.h"
#import "DataCenter.h"
#import "AroundMeViewController.h"
#import "AroundMeMapViewMgt.h"
#import "CellMonitoring.h"
#import "NeighborOverlay.h"
#import "RegionBookmark+MarkedRegion.h"
#import "UserPreferences.h"
#import "MapModeItf.h"
#import "BasicAroundMeImpl.h"
#import "iPadImonitoringViewController.h"


@interface AroundMeViewMgt()

@property (nonatomic, weak) id<MapModeItf> mapMode;
@property (nonatomic, weak) MKMapView* mapView;

@end


@implementation AroundMeViewMgt

- (id)init:(id<MapModeItf>) theMapMode map:(MKMapView*) theMapView{
    if (self = [super init]) {
        _mapMode = theMapMode;
        _mapView = theMapView;
    }
    return self;
}

#pragma mark - MarkCell protocol 
- (void) marked:(UIColor*) theColor userText:(NSString *)theText {
    [AroundMeViewMgt cleanupPopovers];
    [RegionBookmark createMarkedRegion:self.mapView.camera color:theColor name:theText];
}

- (void) cancel {
    [AroundMeViewMgt cleanupPopovers];
}

#pragma mark - DisplayRegion protocol
- (void) showRegionFromAddress:(CLLocationCoordinate2D) coordinate address:(NSString*) theAddress {
    
    [AroundMeViewMgt cleanupPopovers];
    
    _lastSearch = theAddress;
    
    
    self.mapMode.currentMapMode = MapModeDefault;

    id<AroundMeViewItf> delegate = [DataCenter sharedInstance].aroundMeItf;
    [delegate.aroundMeMapVC showLocationOnMapAndReload:coordinate];
}


- (void) showRegionFromSelectedCell:(CLLocationCoordinate2D) coordinate withSelectedCell:(NSString*) cellName {
    
    [AroundMeViewMgt cleanupPopovers];
    
    _lastSearch = cellName;
    self.mapMode.currentMapMode = MapModeDefault;

    id<AroundMeViewItf> delegate = [DataCenter sharedInstance].aroundMeItf;
    delegate.datasource.selectedCell = cellName;
    
    [delegate.aroundMeMapVC showLocationOnMapAndReload:coordinate];
}

- (void) showNeighborInRegion:(NeighborOverlay*) theNeighbor {
    id<AroundMeViewItf> delegate = [DataCenter sharedInstance].aroundMeItf;
    [delegate.aroundMeMapVC showNeighborInRegion:theNeighbor];
}

- (MKMapView*) getMapView {
    return self.mapView;
}


#pragma mark - Utilities
+ (void) cleanupPopovers {
    BasicAroundMeImpl* delegate = (BasicAroundMeImpl*)[DataCenter sharedInstance].aroundMeItf;
    [delegate dismissAllPopovers];
}



@end
