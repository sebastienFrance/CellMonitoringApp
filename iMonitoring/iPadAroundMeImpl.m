//
//  iPadAroundMeImpl.m
//  iMonitoring
//
//  Created by sébastien brugalières on 26/03/13.
//
//

#import "iPadAroundMeImpl.h"
#import "iPadImonitoringViewController.h"
#import "cellDataSource.h"
#import "AroundMeViewMgt.h"
#import "AroundMeMapViewMgt.h"
#import "CellMonitoring.h"
#import "MBProgressHUD.h"
#import "UserPreferences.h"
#import "RegionBookmark+MarkedRegion.h"
#import "CellGroupViewController.h"
#import "DataCenter.h"
#import "RouteInformation.h"
#import "EndDemoSessionViewController.h"
#import "RequestURLUtilities.h"
#import "Utility.h"

@interface iPadAroundMeImpl()

@property (nonatomic) CellKPIsDataSource* cellDatasource;
@property (nonatomic) EndDemoSessionViewController* endDemoVC;

@end

@implementation iPadAroundMeImpl


- (id) init:(BasicAroundMeViewController*) theViewController {
    if (self = [super init:theViewController]) {
        // WORKAROUND: Force the initialization of Datacenter else NSUserDefault is not initialized!
        if ([[DataCenter sharedInstance] isAppStarting]) {
            NSLog(@"App is starting");
        }
    }
    return self;
}

#pragma mark - AroundMeViewItf protocol
- (void) stopDemoSession {
    UIWindow* theWindow = [UIApplication sharedApplication].windows[0];
    UINavigationController* navController = (UINavigationController*)theWindow.rootViewController;
    UIViewController* currentViewController= navController.visibleViewController;
    
    [MBProgressHUD hideAllHUDsForView:currentViewController.view animated:FALSE];
    
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:Nil];
    
    self.endDemoVC = [storyboard instantiateViewControllerWithIdentifier:@"EndDemoSession"];
    
    [currentViewController presentViewController:self.endDemoVC animated:TRUE completion:Nil];

}


#pragma mark - Override
- (void) loadViewContent {
    [RequestURLUtilities setDetaultTimeoutForRequest:180.0];

    DataCenter* dc = [DataCenter sharedInstance];
    dc.aroundMeItf = self;
    
    [super loadViewContent];
}

#pragma mark - Load cell KPIs

// if the Cell KPIs are in cache then display them immediately
// else KPIs are loaded from the server
- (void) openDetailedKPIsView:(CellMonitoring*) theSelectedCell {
    
    [self dismissAllPopovers];

    CellKPIsDataSource* cache = [theSelectedCell getCache];
    if (cache != Nil) {
        self.cellDatasource = cache;
        
        [(iPadImonitoringViewController*) self.aroundMeViewController showDetailsKPIs:self.cellDatasource];
    } else {
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.aroundMeViewController.view animated:YES];
        hud.labelText = @"Loading KPIs";
        self.cellDatasource = [[CellKPIsDataSource alloc] init:self];
        
        [self.cellDatasource loadData:theSelectedCell];
    }
}


#pragma mark - CellDetailsItf protocol
- (void) dataIsLoaded {
    [MBProgressHUD hideHUDForView:self.aroundMeViewController.view animated:YES];
    [(iPadImonitoringViewController*) self.aroundMeViewController showDetailsKPIs:self.cellDatasource];
}

- (void) dataLoadingFailure {
    [MBProgressHUD hideHUDForView:self.aroundMeViewController.view animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Communication Error" message:@"Cannot get KPIs from the server" delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alert show];
}

- (void) timezoneIsLoaded:(NSString*) theTimeZone {
    // Nothing has to be done
}

#pragma mark - data loading for WorstKPIs
- (void) openDashboardView:(DCTechnologyId) technoId {
    
    if (technoId != DCTechnologyLatestUsed) {
        [self loadDashboard:[self.datasource getFilteredCellsForTechnoId:technoId] techno:technoId];
    } else {
        [(iPadImonitoringViewController*) self.aroundMeViewController showDashboard:self.lastWorstKPIs];
    }
    
}
// Warning different than AroundMeViewController (not exist)
- (void) loadDashboard:(NSArray*) cells techno:(DCTechnologyId) technoId {
    self.lastWorstKPIs = [[WorstKPIDataSource alloc] init:self];
    [self.lastWorstKPIs initialize:cells techno:technoId centerCoordinate:[self getMapView].centerCoordinate];
    [self.lastWorstKPIs loadData:[MonitoringPeriodUtility sharedInstance].monitoringPeriod];
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.aroundMeViewController.view animated:YES];
    hud.labelText = [NSString stringWithFormat:@"Loading %lu %@ cells", (unsigned long)cells.count ,[BasicTypes getTechnoName:technoId] ];
}

- (void) cancelDashboardView {
    [(iPadImonitoringViewController*) self.aroundMeViewController dismissDashboardView];
}


#pragma mark - WorstKPIDataLoadingItf
- (void) worstDataIsLoaded:(NSError*) theError {
    [MBProgressHUD hideHUDForView:self.aroundMeViewController.view animated:YES];

    if (theError != Nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Communication Error" message:@"Cannot get KPIs from the server" delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    } else {
        [(iPadImonitoringViewController*) self.aroundMeViewController showDashboard:self.lastWorstKPIs];
    }
}


@end
