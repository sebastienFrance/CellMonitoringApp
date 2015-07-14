//
//  MapPreferencesController.m
//  iMonitoring
//
//  Created by sébastien brugalières on 16/12/2013.
//
//

#import "MapPreferencesController.h"
#import "UserPreferences.h"

@interface MapPreferencesController()
@property (weak) IBOutlet NSButton *LTECellCheckBox;
@property (weak) IBOutlet NSButton *WCDMACellCheckBox;
@property (weak) IBOutlet NSButton *GSMCellCheckBox;
@property (weak) IBOutlet NSButton *emptyCellCheckBox;
@property (weak) IBOutlet NSButton *markedCellsCheckBox;
@property (weak) IBOutlet NSTextField *cellNameFilter;
@property (weak) IBOutlet NSButton *stalliteViewCheckBox;
@property (weak) IBOutlet NSButton *buildingsCheckBox;
@property (weak) IBOutlet NSButton *displayCoverageCheckBox;
@property (weak) IBOutlet NSButton *automaticRefreshCheckBox;
@property (weak) IBOutlet NSButton *followUserPositionCheckBox;
@property (weak) IBOutlet NSSlider *rangeSlider;
@property (weak) IBOutlet NSTextField *rangeTextField;
@property (weak) IBOutlet NSButton *displaySectorCheckBox;
@property (weak) IBOutlet NSTextField *radiusTextField;
@property (weak) IBOutlet NSSlider *radiusSlider;
@property (weak) IBOutlet NSButton *intraFrequencyCheckBox;
@property (weak) IBOutlet NSButton *interFrequencyCheckBox;
@property (weak) IBOutlet NSButton *interRATCheckBox;
@property (weak) IBOutlet NSButton *measuredByANRCheckBox;
@property (weak) IBOutlet NSTextField *distanceNRTextField;
@property (weak) IBOutlet NSSlider *distanceNRSlider;
@property (weak) IBOutlet NSButton *whiteListedCheckBox;
@property (weak) IBOutlet NSButton *blackListedCheckBox;
@property (weak) IBOutlet NSButton *notBLAndNotWLCheckBox;


@end

@implementation MapPreferencesController

- (id)init
{
    self = [super initWithWindowNibName:@"MapPreferencesWindow"];
    
    // userClickedCloseOrOk= FALSE;  // Removed based on answer.
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.window setLevel:NSStatusWindowLevel];

    
//    [configureCoverage addTarget:self action:@selector(coverageValueChange) forControlEvents:UIControlEventAllEvents];
//    configureCoverage.continuous = TRUE;
//    
//    [configureRadius addTarget:self action:@selector(radiusValueChange) forControlEvents:UIControlEventAllEvents];
//    configureRadius.continuous = TRUE;
    
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    
    self.rangeSlider.integerValue = userPrefs.RangeInMeters;
    self.rangeTextField.stringValue = [NSString stringWithFormat:@"%lu m", (unsigned long)userPrefs.RangeInMeters];
    
    self.radiusSlider.integerValue = userPrefs.SectorRadius;
    self.radiusTextField.stringValue = [NSString stringWithFormat:@"%lu", (unsigned long)userPrefs.SectorRadius];
    
    self.markedCellsCheckBox.state = userPrefs.isFilterMarkedCells;
    self.cellNameFilter.stringValue = userPrefs.FilterCellName;
    self.LTECellCheckBox.state = userPrefs.isFilterLTECells;
    self.WCDMACellCheckBox.state = userPrefs.isFilterWCDMACells;
    self.GSMCellCheckBox.state = userPrefs.isFilterGSMCells;
    self.emptyCellCheckBox.state = userPrefs.isFilterEmptySite;
    
    self.displayCoverageCheckBox.state = userPrefs.isDisplayCoverage;
    self.stalliteViewCheckBox.state = userPrefs.isSatelliteView;
    self.buildingsCheckBox.state = userPrefs.isBuildingView;
    self.automaticRefreshCheckBox.state = userPrefs.isAutomaticRefresh;
    self.displaySectorCheckBox.state = userPrefs.isDisplaySectors;
    
    self.intraFrequencyCheckBox.state = userPrefs.isDisplayNeighborsIntraFreq;
    self.interFrequencyCheckBox.state = userPrefs.isDisplayNeighborsInterFreq;
    self.interRATCheckBox.state = userPrefs.isDisplayNeighborsInterRAT;

    self.whiteListedCheckBox.state = userPrefs.isDisplayNeighborsWhiteListed;
    self.blackListedCheckBox.state = userPrefs.isDisplayNeighborsBlackListed;
    self.notBLAndNotWLCheckBox.state = userPrefs.isDisplayNeighborsNotBLNotWL;
    self.measuredByANRCheckBox.state = userPrefs.isDisplayNeighborsByANR;
    
    self.distanceNRSlider.integerValue = userPrefs.NeighborDistanceMinInMeters;
//    self.distanceNRSlider.stringValue = [NSString stringWithFormat:@"%lu", (unsigned long)userPrefs.NeighborDistanceMinInMeters];

    self.distanceNRTextField.stringValue = [NSString stringWithFormat:@"%lu m", (unsigned long)userPrefs.NeighborDistanceMinInMeters];


//    if ([delegate isZoneMode] || [delegate isNeighborMode] || [delegate isMultiCellNavMode]) {
//        automaticRefresh.enabled = FALSE;
//    }
//    
//    if ([delegate isZoneMode] || [delegate isMultiCellNavMode]) {
//        configureCoverage.enabled = FALSE;
//        displayCoverageSwitch.enabled = FALSE;
//    }

}
- (IBAction)LTECellCheckBox:(NSButton *)sender {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    userPrefs.filterLTECells = self.LTECellCheckBox.state;
    [self.delegate updateConfiguration];
}

- (IBAction)WCMDACellCheckBox:(NSButton *)sender {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    userPrefs.filterWCDMACells = self.WCDMACellCheckBox.state;
    [self.delegate updateConfiguration];
}
- (IBAction)GSMCellCheckBox:(NSButton *)sender {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    userPrefs.filterGSMCells = self.GSMCellCheckBox.state;
    [self.delegate updateConfiguration];
}
- (IBAction)emptyCellCheckBox:(NSButton *)sender {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    userPrefs.filterEmptySite = self.emptyCellCheckBox.state;
    [self.delegate updateConfiguration];
}
- (IBAction)markedCellCheckBox:(NSButton *)sender {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    userPrefs.FilterMarkedCells = self.markedCellsCheckBox.state;
    [self.delegate updateConfiguration];
}
- (IBAction)cellNameFilterTextField:(NSTextField *)sender {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    userPrefs.FilterCellName = self.cellNameFilter.stringValue;
    [self.delegate updateConfiguration];
}

- (IBAction)satelliteViewCheckBox:(NSButton *)sender {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    userPrefs.SatelliteView = self.stalliteViewCheckBox.state;
    [self.delegate updateConfiguration];
}
- (IBAction)buildingsCheckBox:(NSButton *)sender {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    userPrefs.BuildingView = self.buildingsCheckBox.state;
    [self.delegate updateConfiguration];
}
- (IBAction)displayCoverageCheckBox:(NSButton *)sender {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    userPrefs.DisplayCoverage = self.displayCoverageCheckBox.state;
    [self.delegate updateConfiguration];
}
- (IBAction)automaticRefreshCheckBox:(NSButton *)sender {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    userPrefs.AutomaticRefresh = self.automaticRefreshCheckBox.state;
    [self.delegate updateConfiguration];
}
- (IBAction)followUserPositionCheckBox:(id)sender {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    userPrefs.FollowUserPosition = self.followUserPositionCheckBox.state;
    [self.delegate updateConfiguration];
}
- (IBAction)rangeSlider:(NSSlider *)sender {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    userPrefs.RangeInMeters  = self.rangeSlider.integerValue;
    self.rangeTextField.stringValue = [NSString stringWithFormat:@"%lu m", (unsigned long)userPrefs.RangeInMeters];
    [self.delegate updateConfiguration];
}
- (IBAction)displaySectorCheckBox:(NSButton *)sender {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    userPrefs.DisplaySectors = self.displaySectorCheckBox.state;
    [self.delegate updateConfiguration];
}
- (IBAction)radiusSliderTextField:(NSSlider *)sender {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    userPrefs.SectorRadius  = self.radiusSlider.integerValue;
    self.radiusTextField.stringValue = [NSString stringWithFormat:@"%lu", (unsigned long)userPrefs.SectorRadius];
    [self.delegate updateConfiguration];
}
- (IBAction)intraFrequencyCheckBox:(NSButton *)sender {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    userPrefs.displayNeighborsIntraFreq = self.intraFrequencyCheckBox.state;
    [self.delegate updateConfiguration];
}
- (IBAction)interFrequencyCheckBox:(NSButton *)sender {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    userPrefs.displayNeighborsInterFreq = self.interFrequencyCheckBox.state;
    [self.delegate updateConfiguration];
}
- (IBAction)interRATCheckBox:(NSButton *)sender {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    userPrefs.DisplayNeighborsInterRAT = self.interRATCheckBox.state;
    [self.delegate updateConfiguration];
}
- (IBAction)measuredByANRCheckBox:(NSButton *)sender {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    userPrefs.DisplayNeighborsByANR = self.measuredByANRCheckBox.state;
    [self.delegate updateConfiguration];
}
- (IBAction)NRDistanceSlider:(NSSlider *)sender {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    userPrefs.NeighborDistanceMinInMeters  = self.distanceNRSlider.integerValue;
    self.distanceNRTextField.stringValue = [NSString stringWithFormat:@"%lu m", (unsigned long)userPrefs.NeighborDistanceMinInMeters];
    [self.delegate updateConfiguration];
}
- (IBAction)whiteListCheckBox:(NSButton *)sender {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    userPrefs.DisplayNeighborsWhiteListed = self.whiteListedCheckBox.state;
    [self.delegate updateConfiguration];
}
- (IBAction)blackListedCheckBox:(NSButton *)sender {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    userPrefs.DisplayNeighborsBlackListed = self.blackListedCheckBox.state;
    [self.delegate updateConfiguration];
}
- (IBAction)notBLAndNotWLCheckBox:(NSButton *)sender {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    userPrefs.DisplayNeighborsNotBLNotWL = self.notBLAndNotWLCheckBox.state;
    [self.delegate updateConfiguration];
}

@end
