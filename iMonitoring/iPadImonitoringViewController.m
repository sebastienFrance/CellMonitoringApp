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

@property (nonatomic) UIViewController* thePreferencesPopover;
@property (nonatomic) UIViewController* theBookmarkPopover;
@property (nonatomic) UIViewController* theSearchPopover;
@property (nonatomic) UIViewController* theOptionsPopover;
@property (nonatomic) UIViewController* theAboutPopover;
@property (nonatomic) UIPopoverController* theCellPopover;
@property (nonatomic) UIViewController* theUserMgtPopover;

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


#pragma mark - Popover Mgt

- (IBAction)searchButtonPressed:(UIBarButtonItem *)sender {
    [self dismissAllPopovers];
    self.theSearchPopover = [self.storyboard instantiateViewControllerWithIdentifier:@"PopoverSearchControllerId"];
    [self presentInPopover:self.theSearchPopover item:sender];
}

- (IBAction)bookmarkButtonPressed:(UIBarButtonItem *)sender {
    [self dismissAllPopovers];
    self.theBookmarkPopover = [self.storyboard instantiateViewControllerWithIdentifier:@"PopoverBookmarkControllerId"];
    [self presentInPopover:self.theBookmarkPopover item:sender];
}
- (IBAction)dashboardButtonPressed:(UIBarButtonItem *)sender {
    
    [self dismissAllPopovers];
    if (self.alertViewForWorstCell == Nil) {
        self.alertViewForWorstCell = [[WorstViewSelection alloc] init];
        [self.alertViewForWorstCell openView:sender viewController:self cancelButton:FALSE];
    }
}



- (IBAction)preferencesButtonPressed:(UIBarButtonItem *)sender {
    [self dismissAllPopovers];

    self.thePreferencesPopover = [self.storyboard instantiateViewControllerWithIdentifier:@"PopoverPreferencesControllerId"];
    [self presentInPopover:self.thePreferencesPopover item:sender];
}

-(void) presentInPopover:(UIViewController*) contentController item:(UIBarButtonItem *)theItem {
    contentController.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController* popPC = contentController.popoverPresentationController;
    popPC.barButtonItem = theItem;
    popPC.permittedArrowDirections = UIPopoverArrowDirectionAny;
    [self presentViewController:contentController animated:TRUE completion:Nil];

}

- (IBAction)optionsButtonPressed:(UIBarButtonItem *)sender {
    [self dismissAllPopovers];
//    if (self.theOptionsPopover == Nil) {
//        self.theOptionsPopover = [self initializePopoverWithId:@"PopoverMapConfigurationControllerId" sender:sender];
//
//        // Get the NavigationController from the Popover
//        UINavigationController* navc = (UINavigationController*)((UIPopoverController*)self.theOptionsPopover).contentViewController;
//
//        // Get the MapConfigurationViewController that is at the top of the NavigationController
//        MapFilteringViewController* controller = (MapFilteringViewController*)navc.topViewController;
//        [controller initFromPopover:self.mapConfUpdate];
//    }
#warning SEB: doesn't work correctly when the poposer is dismissed!
    self.theOptionsPopover = [self.storyboard instantiateViewControllerWithIdentifier:@"PopoverMapConfigurationControllerId"];
    [self presentInPopover:self.theOptionsPopover item:sender];
}

- (IBAction)aboutButtonPressed:(UIBarButtonItem *)sender {
    [self dismissAllPopovers];
    self.theAboutPopover = [self.storyboard instantiateViewControllerWithIdentifier:@"iPadAboutControllerId"];
    [self presentInPopover:self.theAboutPopover item:sender];
}
- (IBAction)userMgtButtonPressed:(UIBarButtonItem *)sender {
    [self dismissAllPopovers];
    self.theUserMgtPopover = [self.storyboard instantiateViewControllerWithIdentifier:@"PopoverUserMgtId"];
    [self presentInPopover:self.theUserMgtPopover item:sender];
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
        [self.theSearchPopover dismissViewControllerAnimated:TRUE completion:Nil];
        self.theSearchPopover = Nil;
    } else if (self.theBookmarkPopover != Nil) {
        [self.theBookmarkPopover dismissViewControllerAnimated:TRUE completion:Nil];
        self.theBookmarkPopover = Nil;
    } else if (self.theOptionsPopover != nil) {
//        [self.theOptionsPopover dismissPopoverAnimated:TRUE];
//        self.theOptionsPopover = Nil;
//        [self.mapConfUpdate updateConfiguration];
        [self.theOptionsPopover dismissViewControllerAnimated:TRUE completion:Nil];
        self.theOptionsPopover = Nil;
        [self.mapConfUpdate updateConfiguration];
    } else if (self.theAboutPopover != nil) {
        [self.theAboutPopover dismissViewControllerAnimated:TRUE completion:Nil];
        self.theAboutPopover = Nil;
    } else if (self.alertViewForWorstCell != Nil) {
        [self dismissDashboardView];
    } else if (self.theCellPopover != Nil) {
        [self.theCellPopover dismissPopoverAnimated:TRUE];
        self.theCellPopover = Nil;
    }  else if (self.theUserMgtPopover != Nil) {
        [self.theUserMgtPopover dismissViewControllerAnimated:TRUE completion:Nil];
        self.theUserMgtPopover = Nil;
    } else if (self.thePreferencesPopover != Nil) {
        [self.thePreferencesPopover dismissViewControllerAnimated:TRUE completion:Nil];
        self.thePreferencesPopover = Nil;
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
    
    [poc presentPopoverFromRect:view.bounds
                         inView:view
       permittedArrowDirections:UIPopoverArrowDirectionAny
                       animated:YES];

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
