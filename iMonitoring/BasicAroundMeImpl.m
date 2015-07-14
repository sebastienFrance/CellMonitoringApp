//
//  BasicAroundMeImpl.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 22/11/2014.
//
//

#import "BasicAroundMeImpl.h"
#import "Utility.h"
#import "AroundMeViewMgt.h"
#import "AroundMeMapViewMgt.h"
#import "iMonitoring.h"
#import "NavCell.h"
#import "NavigationViewCell.h"
#import "MBProgressHUD.h"
#import "UserPreferences.h"
#import "RegionBookmark+MarkedRegion.h"

@interface BasicAroundMeImpl()

@property(nonatomic) Boolean isPreparingNeighborDisplay;

@end

@implementation BasicAroundMeImpl

@synthesize datasource          = _datasource;
@synthesize currentMapMode      = _currentMapMode;
@synthesize viewMgt             = _viewMgt;
@synthesize aroundMeMapVC       = _aroundMeMapVC;
@synthesize aroundMeViewController = _aroundMeViewController;
@synthesize lastWorstKPIs       = _lastWorstKPIs;
@synthesize neighborCenterCell  = _neighborCenterCell;

@synthesize zoneName = _zoneName;
@synthesize navCells = _navCells;




- (id)init:(BasicAroundMeViewController*) theViewController {
    if (self = [super init]) {
        _datasource = [[cellDataSource alloc] init];
        
        _currentMapMode = MapModeDefault;
        _aroundMeViewController = theViewController;
        
        _isPreparingNeighborDisplay = FALSE;
    }
    return self;
}

- (void) dismissAllPopovers {
    [self.aroundMeViewController dismissAllPopovers];
}

- (void) connectionCompleted {
    [self.aroundMeViewController connectionCompleted];
}

#pragma mark - MapMode protocol

- (void) setCurrentMapMode:(MapModeEnabled)currentMapMode {
    _currentMapMode = currentMapMode;
    
    self.aroundMeViewController.title = [Utility mapViewTitleForMapMode:currentMapMode];
}


#pragma mark - AroundMeViewItf protocol
// Common but different
- (void) loadViewContent {
    _aroundMeMapVC = [[AroundMeMapViewMgt alloc] init:self.getMapView aroundMe:self];
    _viewMgt = [[AroundMeViewMgt alloc] init:self map:self.getMapView];
    
    
}

// Common (almost)
- (void) initiliazeWithZone:(NSString*) zoneName {
    [self.aroundMeViewController dismissAllPopovers];
    
    self.currentMapMode = MapModeZone;
    self.zoneName = zoneName;
    
    [self reloadCellsFromServer];
}

// No default implementation

- (void) initializeFromNav:(NSArray*) theNavigationCells {
    self.navCells = theNavigationCells;
    [self showNavigationDataOnMap];
 
    [self.aroundMeViewController dismissAllPopovers];
}

- (void) refreshMapDisplayOptions {
    [self.aroundMeViewController dismissAllPopovers];
    [self.aroundMeViewController refreshMapDisplayOptions];
}

// Common
- (MKMapView*) getMapView {
    return [self.aroundMeViewController getMapView];
}

- (void) stopDemoSession {
    
}

- (void) initiliazeWithRegion:(RegionBookmark*)theRegion {
    [self.aroundMeViewController dismissAllPopovers];
    self.currentMapMode = MapModeDefault;
    [self.aroundMeMapVC showLocationOnMapAndReloadWithCamera:theRegion.theRegion];
}

- (void) initiliazeWithNeighborsOf:(CellMonitoring*) theCell {
    [self.aroundMeViewController dismissAllPopovers];
    
    self.neighborCenterCell = theCell;
    
    self.currentMapMode = MapModeNeighbors;
    [self reloadCellsFromServer];
}

- (void) initializeWithBeighborsOfFromCell:(NSString*) theCell {
    [self.aroundMeViewController dismissAllPopovers];

    self.currentMapMode = MapModeNeighbors;
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.aroundMeViewController.view animated:YES];
    hud.labelText = [Utility hudLoadingLabelForMapMode:self.currentMapMode];

    self.isPreparingNeighborDisplay = TRUE;
    
    [self.datasource loadACell:theCell delegate:self];
}

#pragma mark - MapDelegateItf Protocol


-(void) refreshMapContent {
    [self reloadCellsFromServer];
}

- (void) cellGroupSelectedOnMap:(CellMonitoringGroup *)theSelectedCellGroup annotationView:(MKAnnotationView *)view {
    [self.aroundMeViewController showCellGroupOnMap:theSelectedCellGroup annotationView:view];
}

-(void) mapViewUpdated {
    [self.aroundMeViewController updateUserActivity];
}
#pragma  mark - MapRefresh protocol

// Common
- (void) refreshMapWithFilter:(Boolean) refreshAnnotations overlays:(Boolean) refreshOverlays {
    
    NSArray* cellsToBeDisplayed = [self.datasource refreshFilteredCells];
    
    [self.aroundMeMapVC refreshMapAnnotationsAndOverlays:cellsToBeDisplayed annotations:refreshAnnotations overlays:refreshOverlays];
}

// Almost the same (except for NeighborMode)
- (void) reloadCellsFromServer {
    // Request the list of cells located around this point
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.aroundMeViewController.view animated:YES];
    hud.labelText = [Utility hudLoadingLabelForMapMode:self.currentMapMode];
    
    switch (self.currentMapMode) {
        case MapModeZone: {
            [self.datasource loadCellsFromZone:self.zoneName delegate:self];
            break;
        }
        case MapModeNeighbors: {
            [self.datasource loadNeighborsCellsFrom:self.neighborCenterCell delegate:self];
            break;
        }
        case MapModeNavMultiCell: {
            [self.datasource loadCellsFromNavigation:self.navCells delegate:self];
            break;
        }
        case MapModeRoute: {
            [self.datasource loadCellsAroundRoute:self.lastRoute direction:self.lastDirection delegate:self];
            break;
        }
        case MapModeDefault: {
            
            CLLocationCoordinate2D centerCoordinate = [self getMapView].centerCoordinate;
            [self.datasource loadCellsAroundCoordinate:centerCoordinate.latitude
                                             longitude:centerCoordinate.longitude
                                              distance:[UserPreferences sharedInstance].RangeInKilometers
                                              delegate:self];
            break;
        }
        default: {
            NSLog(@"reloadCellsFromServer: Warning unknown currentMapMode!");
        }
    }
    
}

// Common
- (void) displayCoverage {
    [self.aroundMeMapVC displayCoverage];
}


- (void) reloadCellsFromServerWithRouteAndDirection:(RouteInformation*) theRoute direction:(MKRoute*) theDirection {
    self.currentMapMode = MapModeRoute;
    self.lastRoute = theRoute;
    self.lastDirection = theDirection;
    [self reloadCellsFromServer];
}


// Configure the map to have the given cell at the center
- (void) showSelectedCellOnMap:(CellMonitoring*) cell {
    [self.aroundMeViewController dismissAllPopovers];
    [self.aroundMeMapVC showCellInRegion:cell];
}

// Return the list currently displayed on the map
- (NSArray*) getCellsFromMap {
    return [self.datasource filteredCells];
}

#pragma mark - CellDataSourceDelegate protocol

- (void) cellDataSourceLoaded:(CellMonitoring*) theSelectedCell cellGroups:(NSArray*) theCellGroups error:(NSError*) theError{
    
    [MBProgressHUD hideAllHUDsForView:self.aroundMeViewController.view animated:YES];
    if (theError != Nil) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Communication error" message:@"Cannot collect data from server" delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    } else {
        if (self.isPreparingNeighborDisplay) {
            self.isPreparingNeighborDisplay = FALSE;
            [self initiliazeWithNeighborsOf:theSelectedCell];
        } else {
            // cleanup the cache for the worst cell
            self.lastWorstKPIs = Nil;
            
            [self.aroundMeMapVC refreshMapViewWithCellGroups:theCellGroups selectedCell:theSelectedCell];
            
            self.datasource.selectedCell = Nil;
        }
    }
}

// Specific
- (void) showNavigationDataOnMap {
    
    if (self.navCells.count == 1) {
        
        self.currentMapMode = MapModeDefault;
        NavCell* theNavCell = self.navCells[0];
        self.datasource.selectedCell = theNavCell.cellId;
        [self.aroundMeMapVC showLocationOnMapAndReload:theNavCell.coordinate];
        
    } else {
        self.currentMapMode = MapModeNavMultiCell;
        
        [self reloadCellsFromServer];
    }
    
}


@end
