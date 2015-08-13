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
#import "DashboardViewSelection.h"
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

@property (nonatomic) UIPopoverController* thePreferencesPopover;
@property (nonatomic) UIPopoverController* theBookmarkPopover;
@property (nonatomic) UIPopoverController* theSearchPopover;
@property (nonatomic) UIPopoverController* theOptionsPopover;
@property (nonatomic) UIPopoverController* theAboutPopover;
@property (nonatomic) UIPopoverController* theCellPopover;
@property (nonatomic) UIPopoverController* theUserMgtPopover;

@property (nonatomic) DashboardViewSelection* alertViewForWorstCell;

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


#pragma mark - Popover Mgt

- (IBAction)searchButtonPressed:(UIBarButtonItem *)sender {
    [self dismissAllPopovers];
    if (self.theSearchPopover == Nil) {
        self.theSearchPopover = [self initializePopoverWithId:@"PopoverSearchControllerId" sender:sender];
        
    }
}

- (IBAction)bookmarkButtonPressed:(UIBarButtonItem *)sender {
    [self dismissAllPopovers];
   if (self.theBookmarkPopover == Nil) {
        self.theBookmarkPopover = [self initializePopoverWithId:@"PopoverBookmarkControllerId" sender:sender];

    }
}
- (IBAction)dashboardButtonPressed:(UIBarButtonItem *)sender {
    
    [self dismissAllPopovers];
    if (self.alertViewForWorstCell == Nil) {
        self.alertViewForWorstCell = [[DashboardViewSelection alloc] init];
        [self.alertViewForWorstCell openView:sender viewController:self];
    }
}
- (IBAction)preferencesButtonPressed:(UIBarButtonItem *)sender {
    [self dismissAllPopovers];
    if (self.thePreferencesPopover == Nil) {
        self.thePreferencesPopover= [self initializePopoverWithId:@"PopoverPreferencesControllerId" sender:sender];
    }
}
- (IBAction)optionsButtonPressed:(UIBarButtonItem *)sender {
    [self dismissAllPopovers];
    if (self.theOptionsPopover == Nil) {
        self.theOptionsPopover = [self initializePopoverWithId:@"PopoverMapConfigurationControllerId" sender:sender];

        // Get the NavigationController from the Popover
        UINavigationController* navc = (UINavigationController*)((UIPopoverController*)self.theOptionsPopover).contentViewController;

        // Get the MapConfigurationViewController that is at the top of the NavigationController
        MapFilteringViewController* controller = (MapFilteringViewController*)navc.topViewController;
        [controller initFromPopover:self.mapConfUpdate];
    }
}

- (IBAction)aboutButtonPressed:(UIBarButtonItem *)sender {
    [self dismissAllPopovers];
    if (self.theAboutPopover == Nil) {
        self.theAboutPopover = [self initializePopoverWithId:@"iPadAboutControllerId" sender:sender];
    }
}
- (IBAction)userMgtButtonPressed:(UIBarButtonItem *)sender {
    [self dismissAllPopovers];
    if (self.theUserMgtPopover == Nil) {
        self.theUserMgtPopover = [self initializePopoverWithId:@"PopoverUserMgtId" sender:sender];
    }
}

- (UIPopoverController*) initializePopoverWithId:(NSString*) controllerId sender:(UIBarButtonItem *) theSender {
    UIViewController *viewControllerForPopover = [self.storyboard instantiateViewControllerWithIdentifier:controllerId];
    return [self initialiazePopoverController:viewControllerForPopover sender:theSender];
}

- (UIPopoverController*) initialiazePopoverController:(UIViewController*) theViewController sender:(UIBarButtonItem *) theSender{
    UIPopoverController* thePopover = [[UIPopoverController alloc] initWithContentViewController:theViewController];
    thePopover.delegate = self;
    [thePopover presentPopoverFromBarButtonItem:theSender permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    return thePopover;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [self dismissAllPopovers];
}

- (void) dismissAllPopovers{
    if (self.theSearchPopover != Nil) {
        [self.theSearchPopover dismissPopoverAnimated:TRUE];
        self.theSearchPopover = Nil;
    } else if (self.theBookmarkPopover != Nil) {
        [self.theBookmarkPopover dismissPopoverAnimated:TRUE];
        self.theBookmarkPopover = Nil;
    } else if (self.thePreferencesPopover != nil) {
        [self.thePreferencesPopover dismissPopoverAnimated:TRUE];
        self.thePreferencesPopover = Nil;
    } else if (self.theOptionsPopover != nil) {
        [self.theOptionsPopover dismissPopoverAnimated:TRUE];
        self.theOptionsPopover = Nil;
        [self.mapConfUpdate updateConfiguration];
    } else if (self.theAboutPopover != nil) {
        [self.theAboutPopover dismissPopoverAnimated:TRUE];
        self.theAboutPopover = Nil;
    } else if (self.alertViewForWorstCell != Nil) {
        [self.alertViewForWorstCell dismiss];
    } else if (self.theCellPopover != Nil) {
        [self.theCellPopover dismissPopoverAnimated:TRUE];
        self.theCellPopover = Nil;
    }  else if (self.theUserMgtPopover != Nil) {
        [self.theUserMgtPopover dismissPopoverAnimated:TRUE];
        self.theUserMgtPopover = Nil;
    }
}

- (void) dismissDashboardView {
    self.alertViewForWorstCell = Nil;
}

#pragma mark - Initialization
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:YES animated:YES];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.connected == FALSE) {
        [self performSegueWithIdentifier:@"openConnectId" sender:self];
        self.connected = TRUE;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}


-(id<configurationUpdated>) initializeMapConfigurationUpdate:(id<MapModeItf>) theMapMode refresh:(id<MapRefreshItf>) theMapRefresh map:(MKMapView*) theMapView {
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
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    UINavigationController *detailsMap = [sb instantiateViewControllerWithIdentifier:@"PopoverCellGroupMenuId"];
    
    CellGroupViewController* topView = (CellGroupViewController* )detailsMap.topViewController;
    
    id<AroundMeViewItf> aroundMe = [DataCenter sharedInstance].aroundMeItf;
    [topView initialize:theSelectedCellGroup delegate:aroundMe];
    
    UIPopoverController* poc = [[UIPopoverController alloc] initWithContentViewController:detailsMap];
    
    [self setTheCellPopover:poc];
    
    [poc presentPopoverFromRect:view.bounds inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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
