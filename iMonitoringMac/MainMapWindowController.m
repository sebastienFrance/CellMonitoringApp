//
//  MainMapWindowController.m
//  iMonitoring
//
//  Created by sébastien brugalières on 12/12/2013.
//
//

#import "MainMapWindowController.h"
#import "LoginWindowController.h"

#import "LocateCellDataSource.h"
#import <CoreLocation/CoreLocation.h>
#import "UserPreferences.h"
#import "AroundMeMapViewDelegate.h"
#import "AroundMeMapViewMgt.h"
#import "MapPreferencesController.h"
#import "MapConfigurationUpdate.h"
#import "WorstKPIDataSource.h"
#import "CellGroupPopoverViewController.h"
#import "CellsOnCoverageWindowController.h"
#import "NavigationWindowController.h"
#import "ZoneWindowController.h"
#import "SimpleGraphicWindowController.h"
#import "DashboardWorstCellWindowController.h"
#import "MonitoringPeriodUtility.h"
#import "CellSearchPopoverViewController.h"
#import "DashboardSelectionPopoverViewController.h"

@interface MainMapWindowController()

@property LoginWindowController* theLoginWindow;

@property MapPreferencesController* theMapPreferencesWindow;

@property (weak) IBOutlet MKMapView *theMapView;
@property (weak) IBOutlet NSSearchField *theSearchField;

@property (nonatomic) AroundMeMapViewDelegate* mapDelegate;

@property (nonatomic) LocateCellDataSource* thelocateCellDatasource;

@property (nonatomic) MapConfigurationUpdate* mapConfUpdate;

@property (nonatomic) WorstKPIDataSource* lastWorstKPIs;

@property (nonatomic) NSPopover* cellGroupPopover;
@property (nonatomic) NSPopover* cellSearchPopover;
@property (nonatomic) CellSearchPopoverViewController* searchCellViewController;

@property (nonatomic) CellsOnCoverageWindowController* cellsOnCoverage;


@property (nonatomic) CellMonitoring* neighborCenterCell;
@property (nonatomic) NavigationWindowController* routeWindowController;

@property (nonatomic) RouteInformation* lastRoute;
@property (nonatomic) MKRoute* lastDirection;


@property (nonatomic) ZoneWindowController* zoneWindow;
@property (nonatomic) NSString* zoneName;
@property (nonatomic) SimpleGraphicWindowController* simpleGraphic;

@property (nonatomic) DashboardWorstCellWindowController* dashboardWorstCells;
@property (nonatomic) NSPopover* dashboardPopover;


@end

@implementation MainMapWindowController

@synthesize currentMapMode       = _currentMapMode;
@synthesize datasource          = _datasource;

// Cells contains a list of CellMonitoring
-(void) cellStartingWithResponse:(NSMutableArray *)cells error:(NSError *)theError {
    
    if (theError != Nil) {
        return;
    }
    
    if (self.cellSearchPopover == Nil) {
        self.searchCellViewController = [[CellSearchPopoverViewController alloc] init];
        self.cellSearchPopover = [MainMapWindowController createPopoverForCellSearch:self.searchCellViewController];
        self.cellSearchPopover.delegate = self;
       
        NSRectEdge prefEdge = CGRectMaxYEdge;
        
        [self.cellSearchPopover showRelativeToRect:[self.theSearchField bounds] ofView:self.theSearchField preferredEdge:prefEdge];
        
    }
    
    [self.searchCellViewController updateWith:self.theSearchField.stringValue cells:cells];
}


+ (NSPopover*)createPopoverForCellSearch:(CellSearchPopoverViewController*) searchCellViewController {
    
    // create and setup our popover
    NSPopover* cellSearchPopover = [[NSPopover alloc] init];
    
    cellSearchPopover.contentViewController = searchCellViewController;
    cellSearchPopover.appearance = NSPopoverAppearanceMinimal;
    cellSearchPopover.animates = TRUE;
    
    // AppKit will close the popover when the user interacts with a user interface element outside the popover.
    // note that interacting with menus or panels that become key only when needed will not cause a transient popover to close.
    cellSearchPopover.behavior = NSPopoverBehaviorTransient;
    
    return cellSearchPopover;
}

- (void)popoverWillClose:(NSNotification *)notification {
    self.cellSearchPopover = Nil;
    self.searchCellViewController = Nil;
}


- (IBAction)searchField:(NSSearchField *)sender {
    [self.thelocateCellDatasource requestCellStartingWith:self.theSearchField.stringValue
                                               technology:@"All"
                                               maxResults:50];
}
- (IBAction)preferencesButtonPushed:(NSButton *)sender {
    self.theMapPreferencesWindow = [[MapPreferencesController alloc] init];
    
    self.theMapPreferencesWindow.delegate = self.mapConfUpdate;
    
    [self.theMapPreferencesWindow showWindow:self];
    
}

- (IBAction)locationPushed:(NSButton *)sender {
    self.currentMapMode = MapModeDefault;

    [self.aroundMeMapVC displayMapAroundUserLocation];
}

- (void)goToAddress:(NSString *) address {
    
    [self.cellSearchPopover performClose:self];
    
    self.currentMapMode = MapModeDefault;
    
    CLGeocoder* reverseGeoCoder = [[CLGeocoder alloc] init];
    
#if TARGET_OS_IPHONE
    CLCircularRegion* aroundRegion = [[CLCircularRegion alloc] initWithCenter:self.theMapView.region.center radius:100000.0 identifier:@"AreaRegion"];
#else
    CLRegion* aroundRegion = [[CLRegion alloc] initCircularRegionWithCenter:self.theMapView.region.center radius:1000000 identifier:@"AreaRegion"];
#endif
    
    [reverseGeoCoder geocodeAddressString:address inRegion:aroundRegion completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error){
            NSLog(@"Geocode failed with error: %@", error);
            return;
        }
        CLPlacemark* currentPlacemark = [placemarks lastObject];
        CLLocation *location = currentPlacemark.location;
        
        NSLog(@"Found region: lat %f / long %f", location.coordinate.latitude,location.coordinate.longitude );
        [self.aroundMeMapVC showLocationOnMapAndReload:location.coordinate];
        
        //[self reloadCellsFromServer:location.coordinate];
    }];
    
}

- (void) goToCell:(CellMonitoring*) theCell {
    
    [self.cellSearchPopover performClose:self];

    //_lastSearch = cellName;
    self.currentMapMode = MapModeDefault;
    
    _datasource.selectedCell = theCell.id;
    
    [self.aroundMeMapVC showLocationOnMapAndReload:theCell.coordinate];
}

- (IBAction)dashboardButtonPushed:(NSButton *)sender {
    
    DashboardSelectionPopoverViewController* controller = [[DashboardSelectionPopoverViewController alloc] init:_datasource];
    self.dashboardPopover = [MainMapWindowController createPopoverForDashboard:controller];

    NSRectEdge prefEdge = CGRectMaxYEdge;
    
    [self.dashboardPopover showRelativeToRect:[self.theSearchField bounds] ofView:sender preferredEdge:prefEdge];

    //[self openDashboardView:DCTechnologyLTE];
}

//- (IBAction)popupSearchCellSelected:(NSToolbarItem *)sender {
//    NSLog(@"Popup selected!");
//}

+ (NSPopover*)createPopoverForDashboard:(DashboardSelectionPopoverViewController*) controller {
    
    // create and setup our popover
    NSPopover* cellGroupPopover = [[NSPopover alloc] init];
    cellGroupPopover.contentViewController = controller;
    cellGroupPopover.appearance = NSPopoverAppearanceMinimal;
    cellGroupPopover.animates = TRUE;
    
    // AppKit will close the popover when the user interacts with a user interface element outside the popover.
    // note that interacting with menus or panels that become key only when needed will not cause a transient popover to close.
    cellGroupPopover.behavior = NSPopoverBehaviorTransient;
    
    // so we can be notified when the popover appears or closes
    // self.myPopover.delegate = self;
    
    return cellGroupPopover;
}


- (void)displayCellsOnCoverage {
    self.cellsOnCoverage = [[CellsOnCoverageWindowController alloc] init];
    
    self.cellsOnCoverage.delegate = self;
    
    [self.cellsOnCoverage showWindow:self];
}

- (void) displayRoute {
    self.routeWindowController = [[NavigationWindowController alloc] init:self];
    [self.routeWindowController showWindow:self];
}

- (void) displayZones {
    self.zoneWindow = [[ZoneWindowController alloc] init:self];
    [self.zoneWindow showWindow:self];
}

- (void) openDashboardView:(DCTechnologyId) technoId {
    
    if (technoId != DCTechnologyLatestUsed) {
        [self loadDashboard:[_datasource getFilteredCellsForTechnoId:technoId] techno:technoId];
    }
//    else {
//        [self.iPadAroundMeViewController performSegueWithIdentifier:@"openDashboard" sender:self.lastWorstKPIs];
//    }
    
}
// Warning different than AroundMeViewController (not exist)
- (void) loadDashboard:(NSArray*) cells techno:(DCTechnologyId) technoId {
    self.lastWorstKPIs = [[WorstKPIDataSource alloc] init:self];
    [self.lastWorstKPIs initialize:cells techno:technoId centerCoordinate:self.theMapView.centerCoordinate];
    [self.lastWorstKPIs loadData:[MonitoringPeriodUtility sharedInstance].monitoringPeriod];
//    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.iPadAroundMeViewController.view animated:YES];
//    hud.labelText = [NSString stringWithFormat:@"Loading %d %@ cells", cells.count ,[BasicTypes getTechnoName:technoId] ];
}

#pragma mark - WorstKPIDataLoadingItf
- (void) worstDataIsLoaded:(NSError*) theError {
    if (theError != Nil) {
        NSLog(@"worstDataIsLoaded Failure");
    } else {
        NSLog(@"worstDataIsLoaded success");
        
//        self.simpleGraphic = [[SimpleGraphicWindowController alloc] init:self datasource:self.lastWorstKPIs];
//        [self.simpleGraphic showWindow:self];
        self.dashboardWorstCells = [[DashboardWorstCellWindowController alloc] init:self datasource:self.lastWorstKPIs];
        [self.dashboardWorstCells showWindow:self];
    }
}

- (void) reloadCellsFromServer:(CLLocationCoordinate2D) coordinate {
    
    [self.datasource loadCellsAroundCoordinate:coordinate.latitude
                                         longitude:coordinate.longitude
                                          distance:[UserPreferences sharedInstance].RangeInKilometers
                                          delegate:self];

    
}

- (void) reloadCellsFromServerWithRouteAndDirection:(RouteInformation*) theRoute direction:(MKRoute*) theDirection {
    // Request the list of cells located around this point
    
    //    [self dismissAllPopovers];
    
    self.currentMapMode = MapModeRoute;
    self.lastRoute = theRoute;
    self.lastDirection = theDirection;
    [self reloadCellsFromServer];
}



#pragma mark - CellDataSourceDelegate protocol
- (void) cellDataSourceLoaded:(CellMonitoring*) theSelectedCell cellGroups:(NSArray*) theCellGroups error:(NSError*) theError {
  
    if (theError != Nil) {
        NSLog(@"Failed to load cells");
    } else {
        NSLog(@"Cell loaded");
        [self.aroundMeMapVC refreshMapViewWithCellGroups:theCellGroups selectedCell:theSelectedCell];
        if (self.cellsOnCoverage != Nil) {
            [self.cellsOnCoverage refreshContent];
        }
    }
}

- (void) initiliazeWithNeighborsOf:(CellMonitoring*) theCell {
    
    self.neighborCenterCell = theCell;
    
    self.currentMapMode = MapModeNeighbors;
    [self reloadCellsFromServer];
}
- (void) initiliazeWithZone:(NSString*) zoneName {
    self.currentMapMode = MapModeZone;
    _zoneName = zoneName;
    
    [self reloadCellsFromServer];
}


#pragma mark - MapRefresh protocol
- (void) refreshMapWithFilter:(Boolean) refreshAnnotations overlays:(Boolean) refreshOverlays {


    
    NSArray* cellsToBeDisplayed = [self.datasource refreshFilteredCells];
    
    [self.aroundMeMapVC refreshMapAnnotationsAndOverlays:cellsToBeDisplayed annotations:refreshAnnotations overlays:refreshOverlays];
   
}
- (void) reloadCellsFromServer {
    
    switch (self.currentMapMode) {
        case MapModeZone: {
            [self.datasource loadCellsFromZone:self.zoneName delegate:self];
            break;
        }
        case MapModeRoute: {
            
            [self.datasource loadCellsAroundRoute:self.lastRoute direction:self.lastDirection delegate:self];
            break;
        }
        case MapModeNeighbors: {
            [self.datasource loadNeighborsCellsFrom:self.neighborCenterCell delegate:self];
            break;
        }
        case MapModeDefault: {
            [self.datasource loadCellsAroundCoordinate:self.theMapView.centerCoordinate.latitude
                                             longitude:self.theMapView.centerCoordinate.longitude
                                              distance:[UserPreferences sharedInstance].RangeInKilometers
                                              delegate:self];
        }
        default: {
            break;
        }
            
    }
    
}

- (void) displayCoverage {
    [self.aroundMeMapVC displayCoverage];    
}


// Configure the map to have the given cell at the center
- (void) showSelectedCellOnMap:(CellMonitoring*) cell {
    [self.aroundMeMapVC showCellInRegion:cell];
    
}


// Return the list currently displayed on the map
- (NSArray*) getCellsFromMap {
    return [self.datasource filteredCells];
}



#pragma mark - MapDelegate protocol

-(void) refreshMapContent {
    [self.datasource loadCellsAroundCoordinate:self.theMapView.centerCoordinate.latitude
                                     longitude:self.theMapView.centerCoordinate.longitude
                                      distance:[UserPreferences sharedInstance].RangeInKilometers
                                      delegate:self];
}

-(void) cellGroupSelectedOnMap:(CellMonitoringGroup*) cellGroup annotationView:(MKAnnotationView*) annotation {
    self.cellGroupPopover = [MainMapWindowController createPopoverForCellGroup:cellGroup];
    
    NSRectEdge prefEdge = NSMaxXEdge;

    [self.cellGroupPopover showRelativeToRect:[annotation bounds] ofView:annotation preferredEdge:prefEdge];
}


+ (NSPopover*)createPopoverForCellGroup:(CellMonitoringGroup*) cellGroup {
    
    // create and setup our popover
    NSPopover* cellGroupPopover = [[NSPopover alloc] init];
    cellGroupPopover.contentViewController = [[CellGroupPopoverViewController alloc] initWithCellGroup:cellGroup];
    cellGroupPopover.appearance = NSPopoverAppearanceMinimal;
    cellGroupPopover.animates = TRUE;
    
    // AppKit will close the popover when the user interacts with a user interface element outside the popover.
    // note that interacting with menus or panels that become key only when needed will not cause a transient popover to close.
    cellGroupPopover.behavior = NSPopoverBehaviorTransient;
    
    // so we can be notified when the popover appears or closes
    // self.myPopover.delegate = self;
    
    return cellGroupPopover;
}

#pragma mark - Utilities

-(void) showDetailsOfCell:(CellMonitoring*) theCell {
    CellDetailsWindowController* cellDetails = [[CellDetailsWindowController alloc] initWithCell:theCell mapWindowController:self];
    
    self.cellWindow = cellDetails;
    [cellDetails showWindow:self];

}


#pragma mark - Initialization
+(MainMapWindowController*)sharedInstance
{
    static dispatch_once_t pred;
    static MainMapWindowController *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[MainMapWindowController alloc] init];
    });
    return sharedInstance;
}


- (id)init
{
    self = [super initWithWindowNibName:@"MainMapWindow"];
    
    return self;
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.window center];

    
//    [UserPreferences sharedInstance].KPIDefaultMonitoringPeriod = last24HoursHourlyView;
    
    [UserPreferences sharedInstance].mapAnimation = TRUE;
    
    _datasource = [[cellDataSource alloc] init];
    self.aroundMeMapVC = [[AroundMeMapViewMgt alloc] init:self.theMapView aroundMe:self];

    // initalize MapMode
    _currentMapMode = MapModeDefault;
    
    self.mapDelegate = [[AroundMeMapViewDelegate alloc] init:self mapMode:self];
    
    [self initializeMapProperties];
    
    
    self.thelocateCellDatasource = [[LocateCellDataSource alloc] initWithCellDelegate:self];
    
    // Insert code here to initialize your application
    self.theLoginWindow = [[LoginWindowController alloc] init];
    
    
    [[NSApplication sharedApplication] runModalForWindow:self.theLoginWindow.window];
    
    self.mapConfUpdate = [[MapConfigurationUpdate alloc] init:self refresh:self map:self.theMapView];
    
}

-(void) initializeMapProperties {
    self.theMapView.delegate = self.mapDelegate;
    self.theMapView.showsBuildings = TRUE;
    self.theMapView.showsCompass = TRUE;
    self.theMapView.showsPointsOfInterest = FALSE;
    self.theMapView.showsZoomControls = TRUE;
    self.theMapView.showsUserLocation = TRUE;
}



@end
