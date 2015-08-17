//
//  iPadImonitoringViewController.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 18/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "iPadImonitoringViewController.h"
#import "DataCenter.h"
#import "MBProgressHUD.h"
#import "iPadCellDetailsAndKPIsViewControllerView.h"
#import "WorstViewSelection.h"
#import "iPadDashboardViewController.h"
#import "UserPreferences.h"
#import "iPadAroundMeImpl.h"
#import "AroundMeViewItf.h"
#import "MapConfigurationUpdate.h"
#import "CellGroupViewController.h"
#import "AroundMeViewItf.h"
#import "MapInformationViewController.h"
#import "MapFilteringViewController.h"

@interface iPadImonitoringViewController ()

@property (nonatomic) UIViewController* currentPopover;
@property (nonatomic) Boolean isMapOptionsPopover;

@property (nonatomic) WorstViewSelection* alertViewForWorstCell;

@property (nonatomic) Boolean connected;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *userMgtButton;



@end


@implementation iPadImonitoringViewController
@synthesize infoButton;
@synthesize refreshButton;


#pragma mark - Start and initializations 

- (void) connectionCompleted {
    DataCenter* dc = [DataCenter sharedInstance];
    if (dc.isAdminUser == FALSE) {
        self.userMgtButton.enabled = FALSE;
    }
}

#pragma mark - UIPopoverPresentationControllerDelegate protocol

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController * _Nonnull)popoverPresentationController {
    [self dismissAllPopovers];
}

#pragma mark - Popover Mgt

- (IBAction)searchButtonPressed:(UIBarButtonItem *)sender {
    [self presentViewControllerInPopover:[self.storyboard instantiateViewControllerWithIdentifier:@"PopoverSearchControllerId"]
                                    item:sender];
}

- (IBAction)bookmarkButtonPressed:(UIBarButtonItem *)sender {
    [self presentViewControllerInPopover:[self.storyboard instantiateViewControllerWithIdentifier:@"PopoverBookmarkControllerId"]
                                    item:sender];
}
- (IBAction)dashboardButtonPressed:(UIBarButtonItem *)sender {
    if (self.alertViewForWorstCell == Nil) {
        self.alertViewForWorstCell = [[WorstViewSelection alloc] init];
        [self.alertViewForWorstCell openView:sender viewController:self cancelButton:FALSE];
    }
}

- (IBAction)preferencesButtonPressed:(UIBarButtonItem *)sender {
    [self presentViewControllerInPopover:[self.storyboard instantiateViewControllerWithIdentifier:@"PopoverPreferencesControllerId"]
                                    item:sender];
}


- (IBAction)optionsButtonPressed:(UIBarButtonItem *)sender {
    UINavigationController* navc = [self.storyboard instantiateViewControllerWithIdentifier:@"PopoverMapConfigurationControllerId"];

    // Get the MapConfigurationViewController that is at the top of the NavigationController
    MapFilteringViewController* controller = (MapFilteringViewController*)navc.topViewController;
    [controller initFromPopover:self.mapConfUpdate];

    // 
    self.isMapOptionsPopover = TRUE;
    [self presentViewControllerInPopover:navc item:sender];
}

- (IBAction)aboutButtonPressed:(UIBarButtonItem *)sender {
    [self presentViewControllerInPopover:[self.storyboard instantiateViewControllerWithIdentifier:@"iPadAboutControllerId"]
                                    item:sender];
}
- (IBAction)userMgtButtonPressed:(UIBarButtonItem *)sender {
    [self presentViewControllerInPopover:[self.storyboard instantiateViewControllerWithIdentifier:@"PopoverUserMgtId"]
                                    item:sender];
}

-(void) presentViewControllerInPopover:(UIViewController*) contentController item:(UIBarButtonItem *)theItem {
    [self dismissAllPopovers];

    self.currentPopover = contentController;

    contentController.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController* popPC = contentController.popoverPresentationController;
    popPC.barButtonItem = theItem;
    popPC.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popPC.delegate = self;
    [self presentViewController:contentController animated:TRUE completion:Nil];
}

- (void) dismissAllPopovers{
    if (self.alertViewForWorstCell != Nil) {
        [self dismissDashboardView];
        return;
    }

    if (self.currentPopover != Nil) {
        [self.currentPopover dismissViewControllerAnimated:TRUE completion:Nil];
        self.currentPopover = Nil;
        if (self.isMapOptionsPopover) {
            self.isMapOptionsPopover = FALSE;
            [self.mapConfUpdate updateConfiguration];
        }
    }

}

- (void) dismissDashboardView {
    self.alertViewForWorstCell = Nil;
}

#pragma mark - Initialization
- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setToolbarHidden:YES animated:YES];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.isMapOptionsPopover = FALSE;

    if (self.connected == FALSE) {
        [self performSegueWithIdentifier:@"openConnectId" sender:self];
        self.connected = TRUE;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


-(id<configurationUpdated>) initializeMapConfigurationUpdate:(id<MapModeItf>) theMapMode
                                                     refresh:(id<MapRefreshItf>) theMapRefresh
                                                         map:(MKMapView*) theMapView {
    return [[MapConfigurationUpdate alloc] init:theMapMode refresh:theMapRefresh map:theMapView];
}

#pragma mark - Constructor

- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder])) {
        [DataCenter sharedInstance].aroundMeItf = [[iPadAroundMeImpl alloc] init:self];
        _connected = FALSE;
    }
    return self;
}



#pragma mark - Override

- (void) showCellGroupOnMap:(CellMonitoringGroup *)theSelectedCellGroup annotationView:(MKAnnotationView *)view {
    
    [self showToolbar];

    UINavigationController *detailsMap = [self.storyboard instantiateViewControllerWithIdentifier:@"PopoverCellGroupMenuId"];

    CellGroupViewController* topView = (CellGroupViewController* )detailsMap.topViewController;
    
    id<AroundMeViewItf> aroundMe = [DataCenter sharedInstance].aroundMeItf;
    [topView initialize:theSelectedCellGroup delegate:aroundMe];


    detailsMap.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController* popPC = detailsMap.popoverPresentationController;
    popPC.sourceView = view;
    popPC.sourceRect = view.bounds;
    popPC.permittedArrowDirections = UIPopoverArrowDirectionAny;
    [self presentViewController:detailsMap animated:TRUE completion:Nil];

    self.currentPopover = detailsMap;
}

#pragma mark - DashboardSelectionDelegate protocol

-(void) cancel {
}

-(void) showSelectedDashboard:(DCTechnologyId) selectedTechno {
    iPadAroundMeImpl* aroundMe = (iPadAroundMeImpl*) [DataCenter sharedInstance].aroundMeItf;
    [aroundMe cancelDashboardView];
    [aroundMe openDashboardView:selectedTechno];
}

-(UIViewController*) getViewController {
    return self;
}


#pragma mark - Others

-(void) showDetailsKPIs:(CellKPIsDataSource*) cellDatasource {
    [self performSegueWithIdentifier:@"iPadOpenDetailsKPIs" sender:cellDatasource];
}

-(void) showDashboard:(WorstKPIDataSource *)worstKPIs {
    [self performSegueWithIdentifier:@"openDashboard" sender:worstKPIs];
}



#pragma mark - Segue
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"iPadOpenDetailsKPIs"]) {
        iPadCellDetailsAndKPIsViewControllerView* controller = segue.destinationViewController;
        CellKPIsDataSource* cellDatasource = sender;
        controller.theCell = cellDatasource.theCell;
        controller.theDatasource = cellDatasource;
    } else if ([segue.identifier isEqualToString:@"openDashboard"]) {
        iPadDashboardViewController* controller = segue.destinationViewController;
        controller.theDatasource = sender;
    } else if ([segue.identifier isEqualToString:@"openMapInformation"]) {
        MapInformationViewController* controller = segue.destinationViewController;
        id<AroundMeViewItf> aroundMe = [DataCenter sharedInstance].aroundMeItf;
        controller.listOfCells = aroundMe.datasource.filteredCells;
    }
}

@end
