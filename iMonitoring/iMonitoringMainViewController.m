//
//  iMonitoringMainViewController.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 06/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "iMonitoringMainViewController.h"
#import "AroundMeViewController.h"
#import "Utility.h"
#import "UserPreferencesViewController.h"
#import "DataCenter.h"
#import "MarkedCellsViewController.h"
#import "ConfigViewController.h"
#import "SWRevealViewController.h"
#import "UserPreferences.h"
#import "DataCenter.h"

@interface iMonitoringMainViewController ()


@property (weak, nonatomic) IBOutlet UISwitch *displayCoverageSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *displayStandardSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *displayFlyoverSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *displaySatelliteSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *automaticRefresh;
@property (weak, nonatomic) IBOutlet UISwitch *displaySectors;
@property (weak, nonatomic) IBOutlet UISlider *configureRadius;
@property (weak, nonatomic) IBOutlet UILabel *radiusDisplayValue;
@property (weak, nonatomic) IBOutlet UISwitch *displayBuildingSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *displaySectorAngle;


// Warning : the NavigationController must never be deallocated else we cannot return to the main Map view!!!
@property(nonatomic, strong) UINavigationController* mapNavigationController;

@end

@implementation iMonitoringMainViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
   [super viewDidLoad];
    self.mapNavigationController = (UINavigationController *)self.revealViewController.frontViewController;

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.15f alpha:0.2f];

    [self initializeMapOptions];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:FALSE withAnimation:UIStatusBarAnimationSlide];

    [self saveMapOption];

}


// Workaround for iPad else the cell colors are white instead of dark gray
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    } else {
        if ([DataCenter sharedInstance].isAdminUser) {
            return 3;
        } else {
            return 2;
        }
    }

}


- (void) nagivateToMap {
    [self.revealViewController pushFrontViewController:self.mapNavigationController animated:TRUE];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.section == 0) && (indexPath.row == 0)) {
        [self.revealViewController pushFrontViewController:self.mapNavigationController animated:TRUE];
    }
}

#pragma mark - MapOptions

-(void) initializeMapOptions {
    [self.configureRadius addTarget:self action:@selector(radiusValueChange) forControlEvents:UIControlEventAllEvents];
    self.configureRadius.continuous = TRUE;

    UserPreferences* userPrefs = [UserPreferences sharedInstance];

    self.configureRadius.value = userPrefs.SectorRadius;
    self.radiusDisplayValue.text = [NSString stringWithFormat:@"%lu m", (unsigned long)userPrefs.SectorRadius];

    self.displayCoverageSwitch.on    = userPrefs.isDisplayCoverage;
    self.displayBuildingSwitch.on    = userPrefs.isBuildingView;
    self.automaticRefresh.on         = userPrefs.isAutomaticRefresh;
    self.displaySectors.on           = userPrefs.isDisplaySectors;
    self.displaySectorAngle.on       = userPrefs.isDisplaySectorAngle;

    [self initMapSwitchesFrom:userPrefs.MapType];


    MapModeEnabled currentMapMode = [[[DataCenter sharedInstance] aroundMeItf] currentMapMode];

    if ((currentMapMode == MapModeZone) ||
        (currentMapMode == MapModeNeighbors) ||
        (currentMapMode == MapModeNavMultiCell) ||
        (currentMapMode == MapModeRoute)) {
        self.automaticRefresh.enabled = FALSE;
    }

    if ((currentMapMode == MapModeZone) ||
        (currentMapMode == MapModeNavMultiCell) ||
        (currentMapMode == MapModeRoute)) {
        self.displayCoverageSwitch.enabled = FALSE;
    }

    if (self.displaySectors.on == FALSE) {
        self.displaySectorAngle.enabled = FALSE;
        self.configureRadius.enabled = FALSE;
    }

}

-(void) saveMapOption {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];

    userPrefs.DisplayCoverage   = self.displayCoverageSwitch.on;
    userPrefs.MapType           = [self getMapType];
    userPrefs.BuildingView      = self.displayBuildingSwitch.on;
    userPrefs.AutomaticRefresh  = self.automaticRefresh.on;
    userPrefs.DisplaySectors    = self.displaySectors.on;
    userPrefs.SectorRadius      = [self getSectorCoverageValue];
    userPrefs.DisplaySectorAngle= self.displaySectorAngle.on;

    [[[DataCenter sharedInstance] aroundMeItf] refreshMapDisplayOptions];

}

- (void) radiusValueChange {
    NSUInteger value = [self getSectorCoverageValue];
    self.radiusDisplayValue.text = [NSString stringWithFormat:@"%lu m", (unsigned long)value];
}

- (NSUInteger) getSectorCoverageValue {
    NSUInteger value = self.configureRadius.value;
    NSUInteger reste = value % 50;
    value = value - reste;
    return value;

}
- (IBAction)displayMapTypeSwitchPushed:(UISwitch *)sender {
    if (sender == self.displayStandardSwitch) {
        if (self.displayStandardSwitch.on) {
            self.displayFlyoverSwitch.on = FALSE;
            self.displaySatelliteSwitch.on = FALSE;
        }
    } else if (sender == self.displayFlyoverSwitch) {
        if (self.displayFlyoverSwitch.on) {
            self.displayStandardSwitch.on = FALSE;
            self.displaySatelliteSwitch.on = FALSE;
        }
    } else {
        if (self.displaySatelliteSwitch.on) {
            self.displayStandardSwitch.on = FALSE;
            self.displayFlyoverSwitch.on = FALSE;
        }
    }
}

- (MKMapType) getMapType {
    if (self.displayStandardSwitch.on) {
        return MKMapTypeStandard;
    } else if (self.displayFlyoverSwitch.on) {
        return MKMapTypeHybridFlyover;
    } else {
        return MKMapTypeSatellite;
    }
}

-(void) initMapSwitchesFrom:(MKMapType) mapType {
    if (mapType == MKMapTypeStandard) {
        self.displayStandardSwitch.on = TRUE;
        self.displayFlyoverSwitch.on = FALSE;
        self.displaySatelliteSwitch.on = FALSE;
    } else if (mapType == MKMapTypeHybridFlyover) {
        self.displayStandardSwitch.on = FALSE;
        self.displayFlyoverSwitch.on = TRUE;
        self.displaySatelliteSwitch.on = FALSE;
    } else {
        self.displayStandardSwitch.on = FALSE;
        self.displayFlyoverSwitch.on = FALSE;
        self.displaySatelliteSwitch.on = TRUE;
    }
}

- (IBAction)displaySectorsPushed:(UISwitch *)sender {
    if (self.displaySectors.on == TRUE) {
        self.displaySectorAngle.enabled = TRUE;
        self.configureRadius.enabled = TRUE;
    } else {
        self.displaySectorAngle.enabled = FALSE;
        self.configureRadius.enabled = FALSE;
    }
}




@end
