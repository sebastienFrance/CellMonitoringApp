//
//  AroundMeViewItf.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 05/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "NavCell.h"
#import "cellDataSource.h"
#import "MapModeItf.h"
#import "MapRefreshItf.h"
#import "RouteInformation.h"
#import "AroundMeProtocols.h"
#import "BasicAroundMeViewController.h"

@class AroundMeViewMgt;
@class AroundMeMapViewMgt;
@class CellMonitoring;
@class RegionBookmark;
@class WorstKPIDataSource;


@protocol AroundMeViewItf <MapModeItf, MapRefreshItf>

@property (nonatomic, readonly) AroundMeViewMgt* viewMgt;
@property (nonatomic, readonly) AroundMeMapViewMgt* aroundMeMapVC;
@property (nonatomic, readonly) BasicAroundMeViewController* aroundMeViewController;
@property (nonatomic, retain) WorstKPIDataSource* lastWorstKPIs;


@property (nonatomic) NSString* zoneName;
@property (nonatomic) NSArray* navCells;


@property (nonatomic) CellMonitoring* neighborCenterCell;


- (MKMapView*) getMapView;


#pragma mark - Init from Navigation
- (void) initiliazeWithRegion:(RegionBookmark*) theRegion;
- (void) initiliazeWithZone:(NSString*) zoneName;
- (void) initializeFromNav:(NSArray*) theNavCells;
- (void) initiliazeWithNeighborsOf:(CellMonitoring*) theCell;
- (void) initializeWithBeighborsOfFromCell:(NSString*) theCell;

#pragma mark - Only for demo
- (void) stopDemoSession;

#pragma mark - Refresh Map view
- (void) loadViewContent;

#pragma mark - refresh Map display options (satellite, sectors...)
- (void) refreshMapDisplayOptions;
@end
