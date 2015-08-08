//
//  UserPreferences.h
//  iMonitoring
//
//  Created by sébastien brugalières on 23/03/13.
//
//

#import <Foundation/Foundation.h>
#import "MonitoringPeriodUtility.h"
#import "BasicTypes.h"
@import MapKit;


@interface UserPreferences : NSObject

+ (UserPreferences*) sharedInstance;


@property (nonatomic) DCMonitoringPeriodView KPIDefaultMonitoringPeriod;

@property (nonatomic) NSString* ServerIPAddress;
@property (nonatomic) NSUInteger ServerPortNumber;
@property (nonatomic) NSString* ServerUserName;
@property (nonatomic) NSString* ServerPassword;

@property (nonatomic, getter = isTouchIdEnabled) Boolean touchIdEnabled;

@property (nonatomic, getter = isFilterMarkedCells) Boolean FilterMarkedCells;
@property (nonatomic) NSString* FilterCellName;
@property (nonatomic, getter = isFilterEmptySite) Boolean FilterEmptySite;

@property (nonatomic) MKMapType MapType;
@property (nonatomic, getter = isBuildingView) Boolean BuildingView;
@property (nonatomic, getter = isDisplayCoverage) Boolean DisplayCoverage;
@property (nonatomic, getter = isAutomaticRefresh) Boolean AutomaticRefresh;
@property (nonatomic, getter = isFollowUserPosition) Boolean FollowUserPosition;
@property (nonatomic) NSUInteger RangeInMeters;
@property (nonatomic, readonly) double RangeInKilometers;
@property (nonatomic) NSUInteger SectorRadius;
@property (nonatomic, getter = isDisplaySectors) Boolean DisplaySectors;
@property (nonatomic, getter = isDisplaySectorAngle) Boolean DisplaySectorAngle;
@property (nonatomic, getter = isDisplayNeighborsIntraFreq) Boolean DisplayNeighborsIntraFreq;
@property (nonatomic, getter = isDisplayNeighborsInterFreq) Boolean DisplayNeighborsInterFreq;
@property (nonatomic, getter = isDisplayNeighborsInterRAT) Boolean DisplayNeighborsInterRAT;

@property (nonatomic, getter = isDisplayNeighborsWhiteListed) Boolean DisplayNeighborsWhiteListed;
@property (nonatomic, getter = isDisplayNeighborsBlackListed) Boolean DisplayNeighborsBlackListed;
@property (nonatomic, getter = isDisplayNeighborsNotBLNotWL) Boolean DisplayNeighborsNotBLNotWL;

@property (nonatomic, getter = isDisplayNeighborsByANR) Boolean DisplayNeighborsByANR;
@property (nonatomic) NSUInteger NeighborDistanceMinInMeters;
@property (nonatomic, readonly) double NeighborDistanceMinInKilometers;

@property (nonatomic) NSUInteger CellDashboardDefaultViewScope;
@property (nonatomic) NSUInteger ZoneDashboardDefaultScope;

@property (nonatomic) CGSize cellKPISize;
@property (nonatomic) CGSize zoneCellSize;


#pragma mark - Route options

@property (nonatomic) NSString* RouteFrom;
@property (nonatomic) NSString* RouteTo;
@property (nonatomic) NSUInteger RouteLookupInMeters;
@property (nonatomic) NSUInteger RouteTransportType;

#pragma mark - Graphic options
@property (nonatomic, getter = isCellKPIDetailsGradiant) Boolean cellKPIDetailsGradiant;
@property (nonatomic, getter = isCellDashboardGradiant) Boolean cellDashboardGradiant;
@property (nonatomic, getter = isZoneKPIDetailsGradiant) Boolean zoneKPIDetailsGradiant;
@property (nonatomic, getter = isZoneDashboardGradiant) Boolean zoneDashboardGradiant;
@property (nonatomic, getter = isMapAnimation) Boolean mapAnimation;
@property (nonatomic, getter = isGeoIndexLookup) Boolean geoIndexLookup;

#pragma mark - image options
@property (nonatomic) float imageUploadQuality;

#pragma mark - Help options
@property (nonatomic) Boolean startHelp;
@property (nonatomic) Boolean startWithoutLicenseHelp;
@property (nonatomic) Boolean iPadDashboardHelp;
@property (nonatomic) Boolean iPadCellDashboardHelp;
@property (nonatomic) Boolean helpForGenericGraphicKPI;

-(Boolean) isCellFiltered:(DCTechnologyId) technology;
-(void) setFilteredCell:(DCTechnologyId) technology filter:(Boolean) filterCells;

-(NSSet<NSNumber*>*) filterFrequenciesFor:(DCTechnologyId) technology;
-(void) setFilterFrequenciesFor:(DCTechnologyId) technology filter:(NSSet*) frequencies;
-(NSDictionary<NSNumber*, NSSet<NSNumber*>*>*) filterFrequenciesAllTechnos;

-(NSSet<NSString*>*) filterReleasesFor:(DCTechnologyId) technology;
-(void) setFilterReleasesFor:(DCTechnologyId) technology filter:(NSSet<NSString*>*) releases;
-(NSDictionary<NSNumber*,NSSet<NSString*>*>*) filterReleasesAllTechnos;

@end
