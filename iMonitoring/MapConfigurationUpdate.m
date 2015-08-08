//
//  MapConfigurationUpdate.m
//  iMonitoring
//
//  Created by sébastien brugalières on 18/12/2013.
//
//

#import "MapConfigurationUpdate.h"
#import "UserPreferences.h"
#import "MapRefreshItf.h"

@interface MapConfigurationUpdate()

@property (nonatomic) Boolean isMarkedCellsOnly;
@property (nonatomic) NSString* FilterCellName;
@property (nonatomic) Boolean isLTEDisplayed;
@property (nonatomic) Boolean isWCDMADisplayed;
@property (nonatomic) Boolean isGSMDisplayed;
@property (nonatomic) NSDictionary<NSNumber*, NSSet<NSNumber*>*>* frequencyFilteredPerTechno;
@property (nonatomic) NSDictionary<NSNumber*, NSSet<NSString*>*>* releasesFilteredPerTechno;
@property (nonatomic) Boolean isEmptySiteDisplayed;

@property (nonatomic) MKMapType mapType;
@property (nonatomic, getter = isBuildingDisplayed) Boolean buildingDisplayed;
@property (nonatomic, getter = isCoverageDisplayed) Boolean coverageDisplayed;
@property (nonatomic, getter = isAutomaticRefresh) Boolean automaticRefresh;
@property (nonatomic, getter = isDisplaySectors) Boolean displaySectors;
@property (nonatomic, getter = isDisplaySectorAngle) Boolean displaySectorAngle;

@property (nonatomic) double distance;
@property (nonatomic) NSUInteger sectorRadius;

@property (nonatomic, weak) id<MapModeItf> mapMode;
@property (nonatomic, weak) MKMapView* mapView;
@property (nonatomic, weak) id<MapRefreshItf> mapRefresh;



@property (nonatomic) double neighborDistanceMin;
@property (nonatomic, getter = isDisplayNeighborsIntraFreq) Boolean displayNeighborsIntraFreq;
@property (nonatomic, getter = isDisplayNeighborsInterFreq) Boolean displayNeighborsInterFreq;
@property (nonatomic, getter = isDisplayNeighborsInterRAT) Boolean displayNeighborsInterRAT;
@property (nonatomic, getter = isDisplayNeighborsbyANROnly) Boolean displayNeighborsByANROnly;

@property (nonatomic, getter = isDisplayNeighborsWhiteListed) Boolean displayNeighborsWhiteListed;
@property (nonatomic, getter = isDisplayNeighborsBlackListed) Boolean displayNeighborsBlackListed;
@property (nonatomic, getter = isDisplayNeighborsNotBLNotWL) Boolean displayNeighborsNotBLNotWL;


@end


@implementation MapConfigurationUpdate
@synthesize currentMapMode = _currentMapMode;

- (id)init:(id<MapModeItf>) theMapMode refresh:(id<MapRefreshItf>) theMapRefresh map:(MKMapView*) theMapView{
    if (self = [super init]) {
        _mapMode = theMapMode;
        _mapView = theMapView;
        _mapRefresh = theMapRefresh;
        [self initializeOptions];
        
        // init mapview configuration
        
        _mapView.showsPointsOfInterest = FALSE;
        _mapView.showsScale = TRUE;
        _mapView.pitchEnabled = TRUE;
        _mapView.showsBuildings = _buildingDisplayed;
        _mapView.mapType = self.mapType;
    }
    return self;
}

- (void) initializeOptions {
    
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    
    double NewDistance          = userPrefs.RangeInMeters;
    _distance = NewDistance;
    
    _automaticRefresh            = userPrefs.isAutomaticRefresh;
    _isMarkedCellsOnly           = userPrefs.isFilterMarkedCells;
    _FilterCellName              = userPrefs.FilterCellName;
    _isLTEDisplayed              = [userPrefs isCellFiltered:DCTechnologyLTE];
    _isWCDMADisplayed            = [userPrefs isCellFiltered:DCTechnologyWCDMA];
    _isGSMDisplayed              = [userPrefs isCellFiltered:DCTechnologyGSM];

    _frequencyFilteredPerTechno  = [userPrefs filterFrequenciesAllTechnos];
    _releasesFilteredPerTechno   = [userPrefs filterReleasesAllTechnos];

    _isEmptySiteDisplayed        = userPrefs.isFilterEmptySite;
    _mapType                     = userPrefs.MapType;
    _buildingDisplayed           = userPrefs.isBuildingView;
    _coverageDisplayed           = userPrefs.isDisplayCoverage;
    _displaySectors              = userPrefs.isDisplaySectors;
    _displaySectorAngle          = userPrefs.isDisplaySectorAngle;
    _sectorRadius                = userPrefs.SectorRadius;
    
    [self doInitializeSpecificsOptions];
}

// For Subclasses
//- (void) doInitializeSpecificsOptions {
//    
//}


#pragma mark - configurationUpdated protocol

- (MapModeEnabled) currentMapMode {
    return self.mapMode.currentMapMode;
}

- (void) updateConfiguration {
    
    Boolean mustRefreshMap = FALSE;
    Boolean updateMapAnnotations = FALSE;
    Boolean updateMapOverlays = FALSE;
    
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    
    double NewDistance = userPrefs.RangeInMeters;
    
    if (NewDistance != self.distance) {
        _distance = NewDistance;
        mustRefreshMap = TRUE;
    }
    
    if (userPrefs.isFilterMarkedCells != self.isMarkedCellsOnly) {
        self.isMarkedCellsOnly = userPrefs.isFilterMarkedCells;
        updateMapAnnotations = TRUE;
    }
    
    if ([userPrefs.FilterCellName isEqualToString:self.FilterCellName] == FALSE) {
        self.FilterCellName = userPrefs.FilterCellName;
        updateMapAnnotations = TRUE;
    }
    
    if ([userPrefs isCellFiltered:DCTechnologyLTE] != self.isLTEDisplayed) {
        self.isLTEDisplayed = [userPrefs isCellFiltered:DCTechnologyLTE];
        updateMapAnnotations = TRUE;
    }
    
    if ([userPrefs isCellFiltered:DCTechnologyWCDMA] != self.isWCDMADisplayed) {
        self.isWCDMADisplayed = [userPrefs isCellFiltered:DCTechnologyWCDMA];
        updateMapAnnotations = TRUE;
    }
    
    if ([userPrefs isCellFiltered:DCTechnologyGSM] != self.isGSMDisplayed) {
        self.isGSMDisplayed = [userPrefs isCellFiltered:DCTechnologyGSM];
        updateMapAnnotations = TRUE;
    }

    updateMapAnnotations |= [self updateFilteringFrequenciesPrefs];

    updateMapAnnotations |= [self updateFilteringReleasesPrefs];
    
    if (userPrefs.isFilterEmptySite != self.isEmptySiteDisplayed) {
        self.isEmptySiteDisplayed = userPrefs.isFilterEmptySite;
        updateMapAnnotations = TRUE;
    }
    
    Boolean hasSatelliteChanged = FALSE;
    if (userPrefs.MapType != self.mapType) {
        self.mapType = userPrefs.MapType;
        hasSatelliteChanged = TRUE;
        self.mapView.mapType = self.mapType;
    }
    
    // Just update the building view in case it has changed
    self.buildingDisplayed = userPrefs.isBuildingView;
    self.mapView.showsBuildings = self.isBuildingDisplayed;
    
    if (userPrefs.isDisplayCoverage != self.isCoverageDisplayed) {
        self.coverageDisplayed = userPrefs.isDisplayCoverage;
        [self.mapRefresh displayCoverage];
    } else {
        // change the color of the coverage if it was displayed
        // because of the change of the map type (white is better on satellite
        // and black better for standard
        if (hasSatelliteChanged) [self.mapRefresh displayCoverage];
    }
    
    if (userPrefs.isAutomaticRefresh != self.isAutomaticRefresh) {
        self.automaticRefresh = userPrefs.isAutomaticRefresh;
        
        if (userPrefs.isAutomaticRefresh == TRUE) {
            // Better to force a refresh in this case because maybe the mapped has been
            // moved before and so nothing is currently displayed on it.
            mustRefreshMap = TRUE;
        } // if the automatic refresh is disabled we don't need to refresh the map content
    }
    
    if (userPrefs.isDisplaySectors != self.isDisplaySectors) {
        updateMapOverlays = TRUE;
        self.displaySectors = userPrefs.isDisplaySectors;
    }
 
    if (userPrefs.isDisplaySectorAngle != self.isDisplaySectorAngle) {
        updateMapOverlays = TRUE;
        self.displaySectorAngle = userPrefs.isDisplaySectorAngle;
    }
    
    NSUInteger newSectorRadius = userPrefs.SectorRadius;
    if (newSectorRadius != self.sectorRadius) {
        self.sectorRadius = newSectorRadius;
        updateMapOverlays = TRUE;
    }
    
    updateMapOverlays |= [self doSpecificUpdateConfiguration];
    
    
    if (mustRefreshMap) {
        [self.mapRefresh reloadCellsFromServer];
    } else  {
        [self.mapRefresh refreshMapWithFilter:updateMapAnnotations overlays:updateMapOverlays];
    }
}

- (Boolean) updateFilteringFrequenciesPrefs {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];

    Boolean updateMapAnnotations = FALSE;
    NSDictionary<NSNumber*, NSSet<NSNumber*>*>* newFrequencyFilterAllTechnos = [userPrefs filterFrequenciesAllTechnos];
    NSSet<NSNumber*>* newFrequencyFilter = newFrequencyFilterAllTechnos[@(DCTechnologyLTE)];
    NSSet<NSNumber*>* oldFrequencyFilter = self.frequencyFilteredPerTechno[@(DCTechnologyLTE)];

    if ((newFrequencyFilter != Nil) && (([newFrequencyFilter isEqualToSet:oldFrequencyFilter]) == FALSE)) {
        updateMapAnnotations = TRUE;
    }

    newFrequencyFilter = newFrequencyFilterAllTechnos[@(DCTechnologyWCDMA)];
    oldFrequencyFilter = self.frequencyFilteredPerTechno[@(DCTechnologyWCDMA)];

    if ((newFrequencyFilter != Nil) && (([newFrequencyFilter isEqualToSet:oldFrequencyFilter]) == FALSE)) {
        updateMapAnnotations = TRUE;
    }

    newFrequencyFilter = newFrequencyFilterAllTechnos[@(DCTechnologyGSM)];
    oldFrequencyFilter = self.frequencyFilteredPerTechno[@(DCTechnologyGSM)];

    if ((newFrequencyFilter != Nil) && (([newFrequencyFilter isEqualToSet:oldFrequencyFilter]) == FALSE)) {
        updateMapAnnotations = TRUE;
    }

    self.frequencyFilteredPerTechno = newFrequencyFilterAllTechnos;

    return updateMapAnnotations;
}

- (Boolean) updateFilteringReleasesPrefs {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];

    Boolean updateMapAnnotations = FALSE;
    NSDictionary<NSNumber*,NSSet<NSString*>*>* newReleasesFilterAllTechnos = [userPrefs filterReleasesAllTechnos];
    NSSet<NSString*>* newReleasesFilter = newReleasesFilterAllTechnos[@(DCTechnologyLTE)];
    NSSet<NSString*>* oldReleasesFilter = self.releasesFilteredPerTechno[@(DCTechnologyLTE)];

    if ((newReleasesFilter != Nil) && (([newReleasesFilter isEqualToSet:oldReleasesFilter]) == FALSE)) {
        updateMapAnnotations = TRUE;
    }

    newReleasesFilter = newReleasesFilterAllTechnos[@(DCTechnologyWCDMA)];
    oldReleasesFilter = self.releasesFilteredPerTechno[@(DCTechnologyWCDMA)];

    if ((newReleasesFilter != Nil) && (([newReleasesFilter isEqualToSet:oldReleasesFilter]) == FALSE)) {
        updateMapAnnotations = TRUE;
    }

    newReleasesFilter = newReleasesFilterAllTechnos[@(DCTechnologyGSM)];
    oldReleasesFilter = self.releasesFilteredPerTechno[@(DCTechnologyGSM)];

    if ((newReleasesFilter != Nil) && (([newReleasesFilter isEqualToSet:oldReleasesFilter]) == FALSE)) {
        updateMapAnnotations = TRUE;
    }

    self.releasesFilteredPerTechno = newReleasesFilterAllTechnos;

    return updateMapAnnotations;
}



- (Boolean) doSpecificUpdateConfiguration {
    Boolean updateMapOverlays = FALSE;
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    
    if (userPrefs.isDisplayNeighborsIntraFreq != self.isDisplayNeighborsIntraFreq) {
        updateMapOverlays = TRUE;
        self.displayNeighborsIntraFreq = userPrefs.isDisplayNeighborsIntraFreq;
    }
    if (userPrefs.isDisplayNeighborsInterFreq != self.isDisplayNeighborsInterFreq) {
        updateMapOverlays = TRUE;
        self.displayNeighborsInterFreq = userPrefs.isDisplayNeighborsInterFreq;
    }
    if (userPrefs.isDisplayNeighborsInterRAT != self.isDisplayNeighborsInterRAT) {
        updateMapOverlays = TRUE;
        self.displayNeighborsInterRAT = userPrefs.isDisplayNeighborsInterRAT;
    }
    if (userPrefs.isDisplayNeighborsWhiteListed != self.isDisplayNeighborsWhiteListed) {
        updateMapOverlays = TRUE;
        self.displayNeighborsWhiteListed = userPrefs.isDisplayNeighborsWhiteListed;
    }
    if (userPrefs.isDisplayNeighborsBlackListed != self.isDisplayNeighborsBlackListed) {
        updateMapOverlays = TRUE;
        self.displayNeighborsBlackListed = userPrefs.isDisplayNeighborsBlackListed;
    }
    if (userPrefs.isDisplayNeighborsNotBLNotWL != self.isDisplayNeighborsNotBLNotWL) {
        updateMapOverlays = TRUE;
        self.displayNeighborsNotBLNotWL = userPrefs.isDisplayNeighborsNotBLNotWL;
    }
    
    
    
    if (userPrefs.isDisplayNeighborsByANR != self.isDisplayNeighborsbyANROnly) {
        updateMapOverlays = TRUE;
        self.displayNeighborsByANROnly = userPrefs.isDisplayNeighborsByANR;
    }
    
    double NewNeighborDistanceMin = userPrefs.NeighborDistanceMinInMeters;
    
    if (NewNeighborDistanceMin != self.neighborDistanceMin) {
        self.neighborDistanceMin = NewNeighborDistanceMin;
        updateMapOverlays = TRUE;
    }
    
    return updateMapOverlays;
}

- (void) doInitializeSpecificsOptions {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    _displayNeighborsIntraFreq      = userPrefs.isDisplayNeighborsIntraFreq;
    _displayNeighborsInterFreq      = userPrefs.isDisplayNeighborsInterFreq;
    _displayNeighborsInterRAT       = userPrefs.isDisplayNeighborsInterRAT;
    _displayNeighborsWhiteListed    = userPrefs.isDisplayNeighborsWhiteListed;
    _displayNeighborsBlackListed    = userPrefs.isDisplayNeighborsBlackListed;
    _displayNeighborsNotBLNotWL     = userPrefs.isDisplayNeighborsNotBLNotWL;
    _displayNeighborsByANROnly      = userPrefs.isDisplayNeighborsByANR;
    
    double MinNeighborDistance  = userPrefs.NeighborDistanceMinInMeters;
    _neighborDistanceMin = MinNeighborDistance;
    
}

@end
