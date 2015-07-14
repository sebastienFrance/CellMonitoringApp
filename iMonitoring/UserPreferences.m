//
//  UserPreferences.m
//  iMonitoring
//
//  Created by sébastien brugalières on 23/03/13.
//
//

#import "UserPreferences.h"
#import "MonitoringPeriodUtility.h"
#import "BasicTypes.h"

@implementation UserPreferences


NSString *const kKPIDefaultMonitoringPeriod   = @"KPI.DefaultMonitoringPeriod";

NSString *const kNeighborsSatelliteView       = @"Neighbors.SatelliteView";
NSString *const kNeighborsBuildingView        = @"Neighbors.BuildingView";
NSString *const kNeighborsDisplaySectors      = @"Neighbors.DisplaySectors";
NSString *const kServerIPAddress              = @"Server.IPAddress";
NSString *const kServerPortNumber             = @"Server.PortNumber";
NSString *const kServerUserName               = @"Server.UserName";
NSString *const kServerPassword               = @"Server.Password";
NSString *const kTouchIdEnabled               = @"Authentication.touchIdEnabled";
NSString *const kFilterMarkedCells            = @"Cell.FilterMarkedCells";
NSString *const kFilterCellName               = @"Cell.FilterCellName";
NSString *const kFilterLTECells               = @"Cell.FilterLTECells";
NSString *const kFilterWCDMACells             = @"Cell.FilterWCDMACells";
NSString *const kFilterGSMCells               = @"Cell.FilterGSMCells";
NSString *const kFilterLTECellsFrequencies    = @"Cell.FilterLTECellsFrequencies";
NSString *const kFilterWCDMACellsFrequencies  = @"Cell.FilterWCDMACellsFrequencies";
NSString *const kFilterGSMCellsFrequencies    = @"Cell.FilterGSMCellsFrequencies";
NSString *const kFilterLTEReleases            = @"Cell.FilterLTEReleases";
NSString *const kFilterWCDMAReleases          = @"Cell.FilterWCDMAReleases";
NSString *const kFilterGSMReleases            = @"Cell.FilterGSMReleases";
NSString *const kFilterEmptySite              = @"Cell.FilterEmptySite";
NSString *const kSatelliteView                = @"Cell.SatelliteView";
NSString *const kBuildingView                 = @"Cell.BuildingView";
NSString *const kDisplayCoverage              = @"Cell.DisplayCoverage";
NSString *const kAutomaticRefresh             = @"Cell.AutomaticRefresh";
NSString *const kFollowUserPosition           = @"Cell.FollowUserPosition";
NSString *const kRange                        = @"Cell.Range";
NSString *const kDisplaySectors               = @"Cell.DisplaySectors";
NSString *const kDisplaySectorAngle           = @"Cell.DisplaySectorAngle";
NSString *const kSectorRadius                 = @"Cell.SectorRadius";
NSString *const kDisplayNeighborsIntraFreq    = @"Cell.DisplayNeighborsIntraFreq";
NSString *const kDisplayNeighborsInterFreq    = @"Cell.DisplayNeighborsInterFreq";
NSString *const kDisplayNeighborsInterRAT     = @"Cell.DisplayNeighborsInterRAT";
NSString *const kDisplayNeighborsWhiteListed     = @"Cell.DisplayNeighborsWhiteListed";
NSString *const kDisplayNeighborsBlackListed     = @"Cell.DisplayNeighborsBlackListed";
NSString *const kDisplayNeighborsNotBLNotWL     = @"Cell.DisplayNeighborsNotBLNotWL";
NSString *const kDisplayNeighborsByANR        = @"Cell.DisplayNeighborsByANR";
NSString *const kNeighborDistanceMin          = @"kNeighborDistanceMin";

NSString *const kCellDashboardCellWidth         = @"CellDashboard.CellWidth";
NSString *const kCellDashboardCellHeight        = @"CellDashboard.CellHeight";
NSString *const kCellDashboardNumberOfColumns   = @"CellDashboard.NumberOfColumns";
NSString *const kCellDashboardDefaultViewScope  = @"CellDashboard.DefaultViewScope";
NSString *const kZoneDashboardDefaultScope      = @"ZoneDashboard.DefaultScope";
NSString *const kZoneDashboardCellWidth         = @"ZoneDashboard.CellWidth";
NSString *const kZoneDashboardCellHeight        = @"ZoneDashboard.CellHeight";

// Graphics Options
NSString *const kCellKPIDetailsGradiant         = @"GraphicsOptions.CellKPIDetailsGradiant";
NSString *const kCellDashboardGradiant          = @"GraphicsOptions.CellDashboardGradiant";
NSString *const kZoneKPIDetailsGradiant         = @"GraphicsOptions.ZoneKPIDetailsGradiant";
NSString *const kZoneDashboardGradiant          = @"GraphicsOptions.ZoneDashboardGradiant";
NSString *const kMapAnimation                   = @"GraphicsOptions.MapAnimation";
NSString *const kGeoIndexLookup                 = @"lookUp.GeoIndex";

// image options
NSString *const kImageUploadQuality             = @"ImageOptions.ImageUploadQuality";

NSString *const kRouteFrom                      = @"Route.From";
NSString *const kRouteTo                        = @"Route.To";
NSString *const kRouteLookupDistance            = @"Route.LookupDistance";
NSString *const kRouteTransportType             = @"Route.TransportType";

// Help options
NSString *const kstartHelp                      = @"help.common.startHelp";
NSString *const kstartWithoutLicenseHelp        = @"help.common.startWithoutLicenseHelp";
NSString *const kiPadDashboardHelp              = @"help.iPad.DashboardHelp";
NSString *const kiPadCellDashboardHelp          = @"help.iPad.CellDashboardHelp";
NSString *const khelpForGenericGraphicKPI       = @"help.common.helpForGenericGraphicKPI";

+(UserPreferences*)sharedInstance
{
    static dispatch_once_t pred;
    static UserPreferences *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[UserPreferences alloc] init];
    });
    return sharedInstance;
}

- (id)init{
    if (self = [super init] ) {
        [self initUserDefaults];
    }
    
    return self;
}

- (void) initUserDefaults {
    
    NSString *testValue = [[NSUserDefaults standardUserDefaults] stringForKey:kFilterMarkedCells];
    if (testValue == nil) {
        // No default value, so initialize it
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:kFilterMarkedCells];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kFilterCellName];
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kFilterLTECells];

        [[NSUserDefaults standardUserDefaults] setObject:Nil forKey:kFilterLTECellsFrequencies];
        [[NSUserDefaults standardUserDefaults] setObject:Nil forKey:kFilterWCDMACellsFrequencies];
        [[NSUserDefaults standardUserDefaults] setObject:Nil forKey:kFilterGSMCellsFrequencies];

        [[NSUserDefaults standardUserDefaults] setObject:Nil forKey:kFilterLTEReleases];
        [[NSUserDefaults standardUserDefaults] setObject:Nil forKey:kFilterWCDMAReleases];
        [[NSUserDefaults standardUserDefaults] setObject:Nil forKey:kFilterGSMReleases];

        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kFilterWCDMACells];
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kFilterGSMCells];
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:kFilterEmptySite];
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:kSatelliteView];
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kBuildingView];
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:kDisplayCoverage];
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:kAutomaticRefresh];
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:kFollowUserPosition];
        [[NSUserDefaults standardUserDefaults] setInteger:10000 forKey:kRange];
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:kDisplaySectors];
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kDisplaySectorAngle];
        [[NSUserDefaults standardUserDefaults] setInteger:200 forKey:kSectorRadius];
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kDisplayNeighborsIntraFreq];
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kDisplayNeighborsInterFreq];
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kDisplayNeighborsInterRAT];
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kDisplayNeighborsWhiteListed];
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kDisplayNeighborsBlackListed];
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kDisplayNeighborsNotBLNotWL];

        
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:kDisplayNeighborsByANR];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kNeighborDistanceMin];
        
        [[NSUserDefaults standardUserDefaults] setInteger:8080 forKey:kServerPortNumber];
        [[NSUserDefaults standardUserDefaults] setObject:@"192.168.0.1" forKey:kServerIPAddress];
        [[NSUserDefaults standardUserDefaults] setObject:@"username" forKey:kServerUserName];
        [[NSUserDefaults standardUserDefaults] setObject:@"empty" forKey:kServerPassword];
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:kTouchIdEnabled];

        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:kNeighborsSatelliteView];
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kNeighborsBuildingView];
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:kNeighborsDisplaySectors];
        [[NSUserDefaults standardUserDefaults] setInteger:last6Hours15MnView forKey:kKPIDefaultMonitoringPeriod];
        [[NSUserDefaults standardUserDefaults] setInteger:last6Hours15MnView forKey:kCellDashboardDefaultViewScope];
        [[NSUserDefaults standardUserDefaults] setInteger:last6Hours15MnView forKey:kZoneDashboardDefaultScope];

    
        [[NSUserDefaults standardUserDefaults] setInteger:341 forKey:kCellDashboardCellWidth];
        [[NSUserDefaults standardUserDefaults] setInteger:212 forKey:kCellDashboardCellHeight];
        [[NSUserDefaults standardUserDefaults] setInteger:341 forKey:kZoneDashboardCellWidth];
        [[NSUserDefaults standardUserDefaults] setInteger:212 forKey:kZoneDashboardCellHeight];

        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kCellKPIDetailsGradiant];
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:kCellDashboardGradiant];
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kZoneKPIDetailsGradiant];
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:kZoneDashboardGradiant];
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kMapAnimation];
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kGeoIndexLookup];
        
        // image options
        [[NSUserDefaults standardUserDefaults] setFloat:0.8 forKey:kImageUploadQuality];
        
        
        // Route options
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kRouteFrom];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kRouteTo];
        [[NSUserDefaults standardUserDefaults] setInteger:500 forKey:kRouteLookupDistance];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kRouteTransportType];
        
        // Help options
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kstartHelp];
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kstartWithoutLicenseHelp];
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:khelpForGenericGraphicKPI];
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kiPadDashboardHelp];
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kiPadCellDashboardHelp];
    }
    
}



- (CGSize) cellKPISize {
    CGSize cellSize;
    cellSize.width = [[NSUserDefaults standardUserDefaults] integerForKey:kCellDashboardCellWidth];
    cellSize.height = [[NSUserDefaults standardUserDefaults] integerForKey:kCellDashboardCellHeight];
    
    return cellSize;
}

- (void) setCellKPISize:(CGSize)cellKPISize {
    [[NSUserDefaults standardUserDefaults] setInteger:cellKPISize.width forKey:kCellDashboardCellWidth];
    [[NSUserDefaults standardUserDefaults] setInteger:cellKPISize.height forKey:kCellDashboardCellHeight];
}

- (CGSize) zoneCellSize {
    CGSize cellSize;
    cellSize.width = [[NSUserDefaults standardUserDefaults] integerForKey:kZoneDashboardCellWidth];
    cellSize.height = [[NSUserDefaults standardUserDefaults] integerForKey:kZoneDashboardCellHeight];
    
    return cellSize;   
}

- (void) setZoneCellSize:(CGSize)ZoneCellSize {
    [[NSUserDefaults standardUserDefaults] setInteger:ZoneCellSize.width forKey:kZoneDashboardCellWidth];
    [[NSUserDefaults standardUserDefaults] setInteger:ZoneCellSize.height forKey:kZoneDashboardCellHeight];
}

- (void) setKPIDefaultMonitoringPeriod:(DCMonitoringPeriodView)KPIDefaultMonitoringPeriod {
    [[NSUserDefaults standardUserDefaults] setInteger:KPIDefaultMonitoringPeriod forKey:kKPIDefaultMonitoringPeriod];
}

- (DCMonitoringPeriodView) KPIDefaultMonitoringPeriod {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kKPIDefaultMonitoringPeriod];
}

- (void) setNeighborsSatelliteView:(Boolean)NeighborsSatelliteView {
    [[NSUserDefaults standardUserDefaults] setBool:NeighborsSatelliteView forKey:kNeighborsSatelliteView];
    
}

- (Boolean) isNeighborsSatelliteView {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kNeighborsSatelliteView];
}


- (void) setNeighborsBuildingView:(Boolean)BuildingView {
    [[NSUserDefaults standardUserDefaults] setBool:BuildingView forKey:kNeighborsBuildingView];
}

- (Boolean) isNeighborsBuildingView {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kNeighborsBuildingView];
}


- (void) setNeighborsDisplaySectors:(Boolean)NeighborsDisplaySectors {
    [[NSUserDefaults standardUserDefaults] setBool:NeighborsDisplaySectors forKey:kNeighborsDisplaySectors];
   
}

- (Boolean) isNeighborsDisplaySectors {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kNeighborsDisplaySectors];
}


- (void) setServerIPAddress:(NSString *)ServerIPAddress {
    [[NSUserDefaults standardUserDefaults] setObject:ServerIPAddress forKey:kServerIPAddress];
    
}

- (NSString*) ServerIPAddress {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kServerIPAddress];
}

- (void) setServerPortNumber:(NSUInteger)ServerPortNumber {
    [[NSUserDefaults standardUserDefaults] setInteger:ServerPortNumber forKey:kServerPortNumber];
}

- (NSUInteger) ServerPortNumber {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kServerPortNumber];
}

- (void) setServerUserName:(NSString *)ServerUserName {
    [[NSUserDefaults standardUserDefaults] setObject:ServerUserName forKey:kServerUserName];
}

- (NSString*) ServerUserName {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kServerUserName];
}

- (void) setServerPassword:(NSString *)ServerPassword {
    [[NSUserDefaults standardUserDefaults] setObject:ServerPassword forKey:kServerPassword];
}

- (NSString*) ServerPassword {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kServerPassword];
}

- (void) setTouchIdEnabled:(Boolean)touchIdEnabled {
    [[NSUserDefaults standardUserDefaults] setBool:touchIdEnabled forKey:kTouchIdEnabled];
}

- (Boolean) isTouchIdEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kTouchIdEnabled];
}


- (void) setFilterMarkedCells:(Boolean)FilterMarkedCells {
    [[NSUserDefaults standardUserDefaults] setBool:FilterMarkedCells forKey:kFilterMarkedCells];
}

- (Boolean) isFilterMarkedCells {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kFilterMarkedCells];
}


- (void) setFilterCellName:(NSString *)FilterCellName {
    [[NSUserDefaults standardUserDefaults] setObject:FilterCellName forKey:kFilterCellName];
}

- (void) setFilterLTECellsFrequencies:(NSSet*) frequencies {
    [[NSUserDefaults standardUserDefaults] setObject:[frequencies allObjects] forKey:kFilterLTECellsFrequencies];
}

- (NSSet*) FilterLTECellsFrequencies {
    NSArray* filterArray = [[NSUserDefaults standardUserDefaults] objectForKey:kFilterLTECellsFrequencies];
    return [[NSSet alloc] initWithArray:filterArray];
}

- (void) setFilterWCDMACellsFrequencies:(NSSet*) frequencies {
    [[NSUserDefaults standardUserDefaults] setObject:[frequencies allObjects] forKey:kFilterWCDMACellsFrequencies];
}

- (NSSet*) FilterWCDMACellsFrequencies {
    NSArray* filterArray = [[NSUserDefaults standardUserDefaults] objectForKey:kFilterWCDMACellsFrequencies];
    return [[NSSet alloc] initWithArray:filterArray];
}

- (void) setFilterGSMCellsFrequencies:(NSSet*) frequencies {
    [[NSUserDefaults standardUserDefaults] setObject:[frequencies allObjects] forKey:kFilterGSMCellsFrequencies];
}

- (NSSet*) FilterGSMCellsFrequencies {
    NSArray* filterArray = [[NSUserDefaults standardUserDefaults] objectForKey:kFilterGSMCellsFrequencies];
    return [[NSSet alloc] initWithArray:filterArray];
}

-(NSDictionary*) filterFrequenciesAllTechnos {
    return @{ @(DCTechnologyLTE)   : [self filterFrequenciesFor:DCTechnologyLTE],
              @(DCTechnologyWCDMA) : [self filterFrequenciesFor:DCTechnologyWCDMA],
              @(DCTechnologyGSM)   : [self filterFrequenciesFor:DCTechnologyGSM]};
}


-(NSSet*) filterFrequenciesFor:(DCTechnologyId) technology {
    NSSet* frequencies = Nil;

    switch (technology) {
        case DCTechnologyLTE: {
            frequencies = self.FilterLTECellsFrequencies;
            break;
        }
        case DCTechnologyWCDMA: {
            frequencies = self.FilterWCDMACellsFrequencies;
            break;
        }
        case DCTechnologyGSM: {
            frequencies = self.FilterGSMCellsFrequencies;
            break;
        }
        default: {
            return Nil;
        }
    }

    NSMutableSet* convertedFreq = [[NSMutableSet alloc] initWithCapacity:frequencies.count];
    for (NSString* currentFreq in frequencies) {
        float frequency = [currentFreq floatValue];
        [convertedFreq addObject:@(frequency)];
    }
    return convertedFreq;
}

-(void) setFilterFrequenciesFor:(DCTechnologyId) technology filter:(NSSet*) frequencies {
    // Convert all numbers into NSString
    NSMutableSet* convertedFreq = [[NSMutableSet alloc] initWithCapacity:frequencies.count];
    for (NSNumber* currentFreq in frequencies) {
        [convertedFreq addObject:[currentFreq stringValue]];
    }

    switch (technology) {
        case DCTechnologyLTE: {
            self.FilterLTECellsFrequencies = convertedFreq;
            break;
        }
        case DCTechnologyWCDMA: {
            self.FilterWCDMACellsFrequencies = convertedFreq;
            break;
        }
        case DCTechnologyGSM: {
            self.FilterGSMCellsFrequencies = convertedFreq;
            break;
        }
        default: {
            NSLog(@"%s Error: unknown case", __PRETTY_FUNCTION__);
        }
    }
}

- (void) setFilterLTEReleases:(NSSet*) releases {
    [[NSUserDefaults standardUserDefaults] setObject:[releases allObjects] forKey:kFilterLTEReleases];
}

- (NSSet*) FilterLTEReleases {
    NSArray* filterArray = [[NSUserDefaults standardUserDefaults] objectForKey:kFilterLTEReleases];
    return [[NSSet alloc] initWithArray:filterArray];
}

- (void) setFilterWCDMAReleases:(NSSet*) releases {
    [[NSUserDefaults standardUserDefaults] setObject:[releases allObjects] forKey:kFilterWCDMAReleases];
}

- (NSSet*) FilterWCDMAReleases {
    NSArray* filterArray = [[NSUserDefaults standardUserDefaults] objectForKey:kFilterWCDMAReleases];
    return [[NSSet alloc] initWithArray:filterArray];
}

- (void) setFilterGSMReleases:(NSSet*) releases {
    [[NSUserDefaults standardUserDefaults] setObject:[releases allObjects] forKey:kFilterGSMReleases];
}

- (NSSet*) FilterGSMReleases {
    NSArray* filterArray = [[NSUserDefaults standardUserDefaults] objectForKey:kFilterGSMReleases];
    return [[NSSet alloc] initWithArray:filterArray];
}

-(NSDictionary*) filterReleasesAllTechnos {
    return @{ @(DCTechnologyLTE)   : [self filterReleasesFor:DCTechnologyLTE],
              @(DCTechnologyWCDMA) : [self filterReleasesFor:DCTechnologyWCDMA],
              @(DCTechnologyGSM)   : [self filterReleasesFor:DCTechnologyGSM]};
}


-(NSSet*) filterReleasesFor:(DCTechnologyId) technology {
    NSSet* releases = Nil;

    switch (technology) {
        case DCTechnologyLTE: {
            releases = self.FilterLTEReleases;
            break;
        }
        case DCTechnologyWCDMA: {
            releases = self.FilterWCDMAReleases;
            break;
        }
        case DCTechnologyGSM: {
            releases = self.FilterGSMReleases;
            break;
        }
        default: {
            return Nil;
        }
    }

    return releases;
}

-(void) setFilterReleasesFor:(DCTechnologyId) technology filter:(NSSet*) releases {

    switch (technology) {
        case DCTechnologyLTE: {
            self.FilterLTEReleases = releases;
            break;
        }
        case DCTechnologyWCDMA: {
            self.FilterWCDMAReleases = releases;
            break;
        }
        case DCTechnologyGSM: {
            self.FilterGSMReleases = releases;
            break;
        }
        default: {
            NSLog(@"%s Error: unknown case", __PRETTY_FUNCTION__);
        }
    }
}


- (NSString*) FilterCellName {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kFilterCellName];
  
}

-(Boolean) isCellFiltered:(DCTechnologyId) technology {
    switch (technology) {
        case DCTechnologyLTE: {
            return [self isFilterLTECells];
            break;
        }
        case DCTechnologyWCDMA: {
            return [self isFilterWCDMACells];
            break;
        }
        case DCTechnologyGSM: {
            return [self isFilterGSMCells];
            break;
        }
        default: {
            // Nothing
            return FALSE;
        }
    }
}
-(void) setFilteredCell:(DCTechnologyId) technology filter:(Boolean) filterCells {
    switch (technology) {
        case DCTechnologyLTE: {
            [self setFilterLTECells:filterCells];
            break;
        }
        case DCTechnologyWCDMA: {
            [self setFilterWCDMACells:filterCells];
            break;
        }
        case DCTechnologyGSM: {
            [self setFilterGSMCells:filterCells];
            break;
        }
        default: {
            // Nothing
        }
    }

}


- (void) setFilterLTECells:(Boolean)FilterLTECells {
    [[NSUserDefaults standardUserDefaults] setBool:FilterLTECells forKey:kFilterLTECells];
}

- (Boolean) isFilterLTECells {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kFilterLTECells];
}

- (void) setFilterWCDMACells:(Boolean)FilterWCDMACells {
    [[NSUserDefaults standardUserDefaults] setBool:FilterWCDMACells forKey:kFilterWCDMACells];
}

- (Boolean) isFilterWCDMACells {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kFilterWCDMACells];
}

- (void) setFilterGSMCells:(Boolean)FilterGSMCells {
    [[NSUserDefaults standardUserDefaults] setBool:FilterGSMCells forKey:kFilterGSMCells];
}

- (Boolean) isFilterGSMCells  {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kFilterGSMCells];
}
- (void) setSatelliteView:(Boolean)SatelliteView {
    [[NSUserDefaults standardUserDefaults] setBool:SatelliteView forKey:kSatelliteView];
}

- (Boolean) isSatelliteView {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSatelliteView];
}

- (void) setBuildingView:(Boolean)BuildingView {
    [[NSUserDefaults standardUserDefaults] setBool:BuildingView forKey:kBuildingView];
}

- (Boolean) isBuildingView {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kBuildingView];
}

- (void) setDisplayCoverage:(Boolean)DisplayCoverage {
    [[NSUserDefaults standardUserDefaults] setBool:DisplayCoverage forKey:kDisplayCoverage];
}

- (Boolean) isDisplayCoverage {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kDisplayCoverage];
}
- (void) setAutomaticRefresh:(Boolean)AutomaticRefresh {
    [[NSUserDefaults standardUserDefaults] setBool:AutomaticRefresh forKey:kAutomaticRefresh];
}

- (Boolean) isAutomaticRefresh {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kAutomaticRefresh];
}
- (void) setFollowUserPosition:(Boolean)FollowUserPosition {
    [[NSUserDefaults standardUserDefaults] setBool:FollowUserPosition forKey:kFollowUserPosition];
}

- (Boolean) isFollowUserPosition {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kFollowUserPosition];
}

- (void) setDisplaySectors:(Boolean)DisplaySectors {
    [[NSUserDefaults standardUserDefaults] setBool:DisplaySectors forKey:kDisplaySectors];
}

- (Boolean) isDisplaySectors {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kDisplaySectors];
}

- (void) setDisplaySectorAngle:(Boolean)DisplaySectorAngle {
    [[NSUserDefaults standardUserDefaults] setBool:DisplaySectorAngle forKey:kDisplaySectorAngle];
}

- (Boolean) isDisplaySectorAngle {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kDisplaySectorAngle];
}

- (void) setDisplayNeighborsIntraFreq:(Boolean)DisplayNeighborsIntraFreq {
    [[NSUserDefaults standardUserDefaults] setBool:DisplayNeighborsIntraFreq forKey:kDisplayNeighborsIntraFreq];
}

- (Boolean) isDisplayNeighborsIntraFreq {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kDisplayNeighborsIntraFreq];
}

- (void) setDisplayNeighborsInterFreq:(Boolean)DisplayNeighborsInterFreq {
    [[NSUserDefaults standardUserDefaults] setBool:DisplayNeighborsInterFreq forKey:kDisplayNeighborsInterFreq];
}

- (Boolean) isDisplayNeighborsInterFreq {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kDisplayNeighborsInterFreq];
}
- (void) setDisplayNeighborsInterRAT:(Boolean)DisplayNeighborsInterRAT {
    [[NSUserDefaults standardUserDefaults] setBool:DisplayNeighborsInterRAT forKey:kDisplayNeighborsInterRAT];
}

- (Boolean) isDisplayNeighborsInterRAT {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kDisplayNeighborsInterRAT];
}

- (void) setDisplayNeighborsWhiteListed:(Boolean)DisplayNeighborsWhiteListed {
    [[NSUserDefaults standardUserDefaults] setBool:DisplayNeighborsWhiteListed forKey:kDisplayNeighborsWhiteListed];
}

- (Boolean) isDisplayNeighborsWhiteListed {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kDisplayNeighborsWhiteListed];
}

- (void) setDisplayNeighborsBlackListed:(Boolean)DisplayNeighborsBlackListed {
    [[NSUserDefaults standardUserDefaults] setBool:DisplayNeighborsBlackListed forKey:kDisplayNeighborsBlackListed];
}

- (Boolean) isDisplayNeighborsBlackListed {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kDisplayNeighborsBlackListed];
}

- (void) setDisplayNeighborsNotBLNotWL:(Boolean)DisplayNeighborsNotBLNotWL {
    [[NSUserDefaults standardUserDefaults] setBool:DisplayNeighborsNotBLNotWL forKey:kDisplayNeighborsNotBLNotWL];
}

- (Boolean) isDisplayNeighborsNotBLNotWL {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kDisplayNeighborsNotBLNotWL];
}

- (void) setDisplayNeighborsByANR:(Boolean)DisplayNeighborsByANR {
    [[NSUserDefaults standardUserDefaults] setBool:DisplayNeighborsByANR forKey:kDisplayNeighborsByANR];
}

- (Boolean) isDisplayNeighborsByANR {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kDisplayNeighborsByANR];
}


- (void) setRangeInMeters:(NSUInteger)Range {
    [[NSUserDefaults standardUserDefaults] setInteger:Range forKey:kRange];
}

- (NSUInteger) RangeInMeters {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kRange];
}

- (double) RangeInKilometers{
    return self.RangeInMeters / 1000.0;
}

- (void) setSectorRadius:(NSUInteger)Radius {
    [[NSUserDefaults standardUserDefaults] setInteger:Radius forKey:kSectorRadius];
}

- (NSUInteger) SectorRadius {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kSectorRadius];
}

- (void) setNeighborDistanceMinInMeters:(NSUInteger)NeighborDistanceMin {
    [[NSUserDefaults standardUserDefaults] setInteger:NeighborDistanceMin forKey:kNeighborDistanceMin];
}

- (NSUInteger) NeighborDistanceMinInMeters {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kNeighborDistanceMin];
}

- (double) NeighborDistanceMinInKilometers {
    return self.NeighborDistanceMinInMeters / 1000.0;
}

- (void) setCellDashboardDefaultViewScope:(NSUInteger)CellDashboardDefaultViewScope {
    [[NSUserDefaults standardUserDefaults] setInteger:CellDashboardDefaultViewScope forKey:kCellDashboardDefaultViewScope];
}

- (NSUInteger) CellDashboardDefaultViewScope {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kCellDashboardDefaultViewScope];
}

- (void) setZoneDashboardDefaultScope:(NSUInteger)ZoneDashboardDefaultScope {
    [[NSUserDefaults standardUserDefaults] setInteger:ZoneDashboardDefaultScope forKey:kZoneDashboardDefaultScope];
}

- (NSUInteger) ZoneDashboardDefaultScope {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kZoneDashboardDefaultScope];
}

- (void) setCellKPIDetailsGradiant:(Boolean)cellKPIDetailsGradiant {
    [[NSUserDefaults standardUserDefaults] setBool:cellKPIDetailsGradiant forKey:kCellKPIDetailsGradiant];
}

- (Boolean) isCellKPIDetailsGradiant {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kCellKPIDetailsGradiant];
}

- (void) setCellDashboardGradiant:(Boolean)cellDashboardGradiant {
    [[NSUserDefaults standardUserDefaults] setBool:cellDashboardGradiant forKey:kCellDashboardGradiant];
}

- (Boolean) isGeoIndexLookup {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kGeoIndexLookup];
}

-(void) setGeoIndexLookup:(Boolean)geoIndexLookup {
    [[NSUserDefaults standardUserDefaults] setBool:geoIndexLookup forKey:kGeoIndexLookup];
}

- (Boolean) isCellDashboardGradiant {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kCellDashboardGradiant];
}

- (void) setZoneKPIDetailsGradiant:(Boolean)zoneKPIDetailsGradiant {
    [[NSUserDefaults standardUserDefaults] setBool:zoneKPIDetailsGradiant forKey:kZoneKPIDetailsGradiant];
}

- (Boolean) isZoneKPIDetailsGradiant {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kZoneKPIDetailsGradiant];
}

- (void) setZoneDashboardGradiant:(Boolean)zoneDashboardGradiant {
    [[NSUserDefaults standardUserDefaults] setBool:zoneDashboardGradiant forKey:kZoneDashboardGradiant];
}

- (Boolean) isZoneDashboardGradiant {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kZoneDashboardGradiant];
}

- (void) setMapAnimation:(Boolean)mapAnimation {
    [[NSUserDefaults standardUserDefaults] setBool:mapAnimation forKey:kMapAnimation];
}

- (Boolean) isMapAnimation {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kMapAnimation];
}
#pragma mark - Image options

-(float) imageUploadQuality {
    return [[NSUserDefaults standardUserDefaults] floatForKey:kImageUploadQuality];
}

-(void) setImageUploadQuality:(float)imageUploadQuality {
    [[NSUserDefaults standardUserDefaults] setFloat:imageUploadQuality forKey:kImageUploadQuality];
}


#pragma mark - Route options

- (void) setRouteFrom:(NSString *) routeFrom {
    [[NSUserDefaults standardUserDefaults] setObject:routeFrom forKey:kRouteFrom];
}

- (NSString*) RouteFrom {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kRouteFrom];
    
}

- (void) setRouteTo:(NSString *) routeTo {
    [[NSUserDefaults standardUserDefaults] setObject:routeTo forKey:kRouteTo];
}

- (NSString*) RouteTo {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kRouteTo];
    
}


- (void) setRouteLookupInMeters:(NSUInteger) lookupInMeters {
    [[NSUserDefaults standardUserDefaults] setInteger:lookupInMeters forKey:kRouteLookupDistance];
}

- (NSUInteger) RouteLookupInMeters {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kRouteLookupDistance];
}

- (void) setRouteTransportType:(NSUInteger) transportType {
    [[NSUserDefaults standardUserDefaults] setInteger:transportType forKey:kRouteTransportType];
}

- (NSUInteger) RouteTransportType {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kRouteTransportType];
}

#pragma mark - Help options
- (void) setStartHelp:(Boolean)startHelp {
    [[NSUserDefaults standardUserDefaults] setBool:startHelp forKey:kstartHelp];
}

- (Boolean) startHelp {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kstartHelp];
}

- (void) setStartWithoutLicenseHelp:(Boolean)startWithoutLicenseHelp {
    [[NSUserDefaults standardUserDefaults] setBool:startWithoutLicenseHelp forKey:kstartWithoutLicenseHelp];
}

- (Boolean) startWithoutLicenseHelp {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kstartWithoutLicenseHelp];
}


- (void) setIPadDashboardHelp:(Boolean)iPadDashboardHelp {
    [[NSUserDefaults standardUserDefaults] setBool:iPadDashboardHelp forKey:kiPadDashboardHelp];
}

- (Boolean) iPadDashboardHelp {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kiPadDashboardHelp];
}

- (void) setIPadCellDashboardHelp:(Boolean)iPadCellDashboardHelp {
    [[NSUserDefaults standardUserDefaults] setBool:iPadCellDashboardHelp forKey:kiPadCellDashboardHelp];
}

- (Boolean) iPadCellDashboardHelp {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kiPadCellDashboardHelp];
}

- (void) setHelpForGenericGraphicKPI:(Boolean)helpForGenericGraphicKPI {
    [[NSUserDefaults standardUserDefaults] setBool:helpForGenericGraphicKPI forKey:khelpForGenericGraphicKPI];
}

- (Boolean) helpForGenericGraphicKPI {
    return [[NSUserDefaults standardUserDefaults] boolForKey:khelpForGenericGraphicKPI];
}

@end
