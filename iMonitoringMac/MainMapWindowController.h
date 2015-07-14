//
//  MainMapWindowController.h
//  iMonitoring
//
//  Created by sébastien brugalières on 12/12/2013.
//
//

#import <Foundation/Foundation.h>

#import "LocateCellDataSource.h"
#import "cellDataSource.h"
#import "MapModeItf.h"
#import "MapDelegateItf.h"
#import "MapRefreshItf.h"
#import "WorstKPIDataSource.h"
#import "AroundMeMapViewDelegate.h"
#import "CellDetailsWindowController.h"

@class AroundMeMapViewMgt;

@interface MainMapWindowController : NSWindowController<MapModeItf, MapRefreshItf, MapDelegateItf, LocateCellDelegate, CellDataSourceDelegate, WorstKPIDataLoadingItf, NSPopoverDelegate>

@property (nonatomic) AroundMeMapViewMgt* aroundMeMapVC;
@property (nonatomic) CellDetailsWindowController* cellWindow;

- (void) initiliazeWithNeighborsOf:(CellMonitoring*) theCell;
- (void) initiliazeWithZone:(NSString*) zoneName;

-(void) showDetailsOfCell:(CellMonitoring*) theCell;
- (void)goToAddress:(NSString *) address;
- (void) goToCell:(CellMonitoring*) theCell;

+(MainMapWindowController*)sharedInstance;

- (void) displayCellsOnCoverage;
- (void) displayZones;
- (void) displayRoute;
- (void) openDashboardView:(DCTechnologyId) technoId;


- (void) reloadCellsFromServerWithRouteAndDirection:(RouteInformation*) theRoute direction:(MKRoute*) theDirection;
@end
