//
//  AroundMeViewController.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 07/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AroundMeViewController.h"
#import "DataCenter.h"
#import "WorstViewSelection.h"
#import "ZoneKPIsEntryPointViewController.h"
#import "UserPreferences.h"
#import "AroundMeImpl.h"
#import "AroundMeViewItf.h"
#import "CellGroupViewController.h"
#import "SearchEverywhereEntryPoint.h"
#import "AroundMeViewItf.h"
#import "MapFilteringViewController.h"
#import "AroundMeViewMgt.h"
#import "MapInformationViewController.h"

@interface AroundMeViewController ()
// Must keep a reference on it else it crashes because deallocated 
@property (nonatomic) WorstViewSelection* alertViewForWorstCell;

@property (nonatomic) Boolean connected;

@end

@implementation AroundMeViewController

#pragma mark - Callbacks


- (IBAction)wortButton:(UIBarButtonItem *)sender {
    id<AroundMeViewItf> aroundMe = [DataCenter sharedInstance].aroundMeItf;
    _alertViewForWorstCell = [[WorstViewSelection alloc] init:aroundMe viewController:self];

    [_alertViewForWorstCell openView:aroundMe.lastWorstKPIs];
}

#pragma mark - Constructor

- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder])) {
        DataCenter* dc = [DataCenter sharedInstance];
        dc.aroundMeItf = [[AroundMeImpl alloc] init:self];
    }
    return self;
}

#pragma mark - View initialization

- (void)viewWillAppear:(BOOL)animated
{
 //   [self.navigationController setToolbarHidden:YES animated:YES];
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.connected == FALSE) {
        [self performSegueWithIdentifier:@"openConnectId" sender:self];
        self.connected = TRUE;
    }
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
   [super viewDidLoad];
}


#pragma mark - Override
- (void) showCellGroupOnMap:(CellMonitoringGroup *)theSelectedCellGroup annotationView:(MKAnnotationView *)view {
    [self showToolbar];
    [self performSegueWithIdentifier:@"pushCellGroup" sender:theSelectedCellGroup];
}

- (void) connectionCompleted {
//    DataCenter* dc = [DataCenter sharedInstance];
//    if (dc.isAdminUser == FALSE) {
//        self.userMgtButton.enabled = FALSE;
//    }
}


#pragma mark - Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    // show again NavigationBar and Toolbar before to move to the next view
    [self.navigationController setNavigationBarHidden:FALSE animated:FALSE];
    
    id<AroundMeViewItf> theAroundMeImpl = [DataCenter sharedInstance].aroundMeItf;
    if ([segue.identifier isEqualToString:@"openConfigiPhone"]) {
        MapFilteringViewController* controller = segue.destinationViewController;
        controller.delegate = self.mapConfUpdate;
    } else if ([segue.identifier isEqualToString:@"searchEntryPoint"]) {
        SearchEverywhereEntryPoint* controller = segue.destinationViewController;
        controller.delegateRegion = theAroundMeImpl.viewMgt;
    }  else if ([segue.identifier isEqualToString:@"openCellsKPIs"]) {
        ZoneKPIsEntryPointViewController* controller = segue.destinationViewController;
                 
        DCTechnologyId  technoId = [(NSNumber*) sender shortValue];
        if (technoId != DCTechnologyLatestUsed) {
            [controller initialize:[theAroundMeImpl.datasource getFilteredCellsForTechnoId:technoId] techno:technoId centerCoordinate:self.theMapView.centerCoordinate];
        } else {
            [controller initialize:theAroundMeImpl.lastWorstKPIs];           
        }
        
    } else if (([segue.identifier isEqualToString:@"pushCellGroup"]) ) {
        CellGroupViewController* controller = segue.destinationViewController;
        AroundMeImpl* aroundMe = (AroundMeImpl*)[DataCenter sharedInstance].aroundMeItf;

        [controller initialize:sender delegate:aroundMe];
    } else if (([segue.identifier isEqualToString:@"openMapInformation"])) {
        MapInformationViewController* mapInfoVC = segue.destinationViewController;
        
        mapInfoVC.listOfCells = theAroundMeImpl.datasource.filteredCells;

    }
}


@end
