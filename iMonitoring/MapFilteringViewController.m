//
//  MapFilteringViewController.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 14/09/2014.
//
//

#import "MapFilteringViewController.h"
#import "DataCenter.h"
#import "UserPreferences.h"
#import "AroundMeViewMgt.h"
#import "TechnoFilteringTableViewController.h"


@interface MapFilteringViewController() 

@property (weak, nonatomic) IBOutlet UISwitch *markedCellsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *LTECellsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *WCDMACellsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *GSMCellsSwitch;
@property (weak, nonatomic) IBOutlet UISlider *configureCoverage;
@property (weak, nonatomic) IBOutlet UILabel *coverageDisplayValue;
@property (weak, nonatomic) IBOutlet UISwitch *emptySiteSwitch;
@property (weak, nonatomic) IBOutlet UITextField *cellNameFilter;
@property (weak, nonatomic) IBOutlet UILabel *LTECellsSubFilterLabel;
@property (weak, nonatomic) IBOutlet UILabel *WCDMACellsSubFilterLabel;
@property (weak, nonatomic) IBOutlet UILabel *GSMCellsSubFilterLabel;


@property (weak, nonatomic) IBOutlet UISwitch *displayNeighborsIntraFreq;
@property (weak, nonatomic) IBOutlet UISwitch *displayNeighborsInterFreq;
@property (weak, nonatomic) IBOutlet UISwitch *displayNeighborsMeasuredByANR;
@property (weak, nonatomic) IBOutlet UISlider *configureNeighborDistanceMin;
@property (weak, nonatomic) IBOutlet UILabel *neighborDistanceMinDisplayValue;
@property (weak, nonatomic) IBOutlet UISwitch *displayNeighborsInterRAT;
@property (weak, nonatomic) IBOutlet UISwitch *displayNeighborsWhiteListed;
@property (weak, nonatomic) IBOutlet UISwitch *displayNeighborsBlackListed;
@property (weak, nonatomic) IBOutlet UISwitch *displayNeighborsNotBLNotWL;



@property(nonatomic) NSArray* listOfCellForFiltering;
@property(nonatomic) DCTechnologyId technoForFiltering;

@end

@implementation MapFilteringViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.navigationController setToolbarHidden:TRUE animated:FALSE];
    self.navigationController.hidesBarsOnTap = FALSE;

    
    [self.configureCoverage addTarget:self action:@selector(coverageValueChange) forControlEvents:UIControlEventAllEvents];
    self.configureCoverage.continuous = TRUE;


    UserPreferences* userPrefs = [UserPreferences sharedInstance];

    self.configureCoverage.value = userPrefs.RangeInMeters;
    self.coverageDisplayValue.text = [NSString stringWithFormat:@"%lu m", (unsigned long)userPrefs.RangeInMeters];

    self.markedCellsSwitch.on        = userPrefs.isFilterMarkedCells;
    self.cellNameFilter.text         = userPrefs.FilterCellName;
    self.LTECellsSwitch.on           = [userPrefs isCellFiltered:DCTechnologyLTE];
    self.WCDMACellsSwitch.on         = [userPrefs isCellFiltered:DCTechnologyWCDMA];
    self.GSMCellsSwitch.on           = [userPrefs isCellFiltered:DCTechnologyGSM];
    self.emptySiteSwitch.on          = userPrefs.isFilterEmptySite;

    [self configureAllSubFilterLabel];

    MapModeEnabled currentMapMode = self.delegate.currentMapMode;


    if ((currentMapMode == MapModeZone) ||
        (currentMapMode == MapModeNavMultiCell) ||
        (currentMapMode == MapModeRoute)) {
        self.configureCoverage.enabled = FALSE;
    }

    self.displayNeighborsIntraFreq.on    = userPrefs.isDisplayNeighborsIntraFreq;
    self.displayNeighborsInterFreq.on    = userPrefs.isDisplayNeighborsInterFreq;
    self.displayNeighborsInterRAT.on     = userPrefs.isDisplayNeighborsInterRAT;
    self.displayNeighborsWhiteListed.on  = userPrefs.isDisplayNeighborsWhiteListed;
    self.displayNeighborsBlackListed.on  = userPrefs.isDisplayNeighborsBlackListed;
    self.displayNeighborsNotBLNotWL.on   = userPrefs.isDisplayNeighborsNotBLNotWL;
    
    self.displayNeighborsMeasuredByANR.on    = userPrefs.isDisplayNeighborsByANR;
    
    [self.configureNeighborDistanceMin addTarget:self action:@selector(neighborDistanceMinValueChange) forControlEvents:UIControlEventAllEvents];
    self.configureNeighborDistanceMin.continuous = TRUE;
    
    self.configureNeighborDistanceMin.value = userPrefs.NeighborDistanceMinInMeters;
    self.neighborDistanceMinDisplayValue.text = [NSString stringWithFormat:@"%lu m", (unsigned long)userPrefs.NeighborDistanceMinInMeters];

}
-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.navigationController setToolbarHidden:TRUE animated:FALSE];
    self.navigationController.hidesBarsOnTap = FALSE;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self configureAllSubFilterLabel];
}

- (void) configureAllSubFilterLabel {
    [MapFilteringViewController configureSubFilterLabel:[TechnoFilteringTableViewController hasSubFilter:DCTechnologyLTE]
                                                  label:self.LTECellsSubFilterLabel];
    [MapFilteringViewController configureSubFilterLabel:[TechnoFilteringTableViewController hasSubFilter:DCTechnologyWCDMA]
                                                  label:self.WCDMACellsSubFilterLabel];
    [MapFilteringViewController configureSubFilterLabel:[TechnoFilteringTableViewController hasSubFilter:DCTechnologyGSM]
                                                  label:self.GSMCellsSubFilterLabel];
}

+ (void) configureSubFilterLabel:(Boolean) hasFilter label:(UILabel*) theLabel {
    static NSString* hasFilterString = @"has sub-filter configured";
    static NSString* noFilterString = @"no sub-filter";

    if (hasFilter) {
        theLabel.text = hasFilterString;
        theLabel.textColor = [UIColor redColor];
    } else {
        theLabel.text = noFilterString;
        theLabel.textColor = [UIColor lightGrayColor];
    }

}

- (void) initFromPopover:(id<configurationUpdated>) theDelegate {
    self.delegate = theDelegate;

    self.configureCoverage.value = [UserPreferences sharedInstance].RangeInMeters;

    MapModeEnabled currentMapMode = self.delegate.currentMapMode;

    if ((currentMapMode == MapModeZone) ||
        (currentMapMode == MapModeNavMultiCell) ||
        (currentMapMode == MapModeRoute)) {
        self.configureCoverage.enabled = FALSE;
    }
}


- (void) coverageValueChange {
    NSUInteger value = [self getCoverageValue];
    self.coverageDisplayValue.text = [NSString stringWithFormat:@"%lu m", (unsigned long)value];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    
    userPrefs.DisplayNeighborsIntraFreq     = self.displayNeighborsIntraFreq.on;
    userPrefs.DisplayNeighborsInterFreq     = self.displayNeighborsInterFreq.on;
    userPrefs.DisplayNeighborsInterRAT      = self.displayNeighborsInterRAT.on;
    userPrefs.DisplayNeighborsWhiteListed   = self.displayNeighborsWhiteListed.on;
    userPrefs.DisplayNeighborsBlackListed   = self.displayNeighborsBlackListed.on;
    userPrefs.DisplayNeighborsNotBLNotWL    = self.displayNeighborsNotBLNotWL.on;
    userPrefs.DisplayNeighborsByANR         = self.displayNeighborsMeasuredByANR.on;
    userPrefs.NeighborDistanceMinInMeters   = [self getNeighborDistanceMin];

    userPrefs.FilterMarkedCells = self.markedCellsSwitch.on;
    userPrefs.FilterCellName    = self.cellNameFilter.text;

    [userPrefs setFilteredCell:DCTechnologyLTE filter:self.LTECellsSwitch.on];
    [userPrefs setFilteredCell:DCTechnologyWCDMA filter:self.WCDMACellsSwitch.on];
    [userPrefs setFilteredCell:DCTechnologyGSM filter:self.GSMCellsSwitch.on];

    userPrefs.FilterEmptySite   = self.emptySiteSwitch.on;
    userPrefs.RangeInMeters     = [self getCoverageValue];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.delegate updateConfiguration];
    }
}


- (NSUInteger) getCoverageValue {
    NSUInteger value = self.configureCoverage.value;
    NSUInteger reste = value % 50;
    value = value - reste;
    return value;

}

- (void) neighborDistanceMinValueChange {
    NSUInteger value = [self getNeighborDistanceMin];
    self.neighborDistanceMinDisplayValue.text = [NSString stringWithFormat:@"%lu m", (unsigned long)value];
}

- (NSUInteger) getNeighborDistanceMin {
    NSUInteger value = self.configureNeighborDistanceMin.value;
    NSUInteger reste = value % 200;
    value = value - reste;
    return value;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if ((indexPath.row >= 2) || (indexPath.row <= 4)) {
            id<AroundMeViewItf> aroundMe = [DataCenter sharedInstance].aroundMeItf;

            self.listOfCellForFiltering = Nil;

            switch (indexPath.row) {
                case 2: {
                    self.listOfCellForFiltering = [aroundMe.datasource getAllCellsForTechnoId:DCTechnologyLTE];
                    self.technoForFiltering = DCTechnologyLTE;
                    break;
                }
                case 3: {
                    self.listOfCellForFiltering = [aroundMe.datasource getAllCellsForTechnoId:DCTechnologyWCDMA];
                    self.technoForFiltering = DCTechnologyWCDMA;
                    break;
                }
                case 4: {
                    self.listOfCellForFiltering = [aroundMe.datasource getAllCellsForTechnoId:DCTechnologyGSM];
                    self.technoForFiltering = DCTechnologyGSM;
                    break;
                }
            }

            [self performSegueWithIdentifier:@"openTechnoFilter" sender:Nil];

        }
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"openTechnoFilter"]) {
        TechnoFilteringTableViewController* controller = segue.destinationViewController;
        [controller initializeWith:self.listOfCellForFiltering techno:self.technoForFiltering];
    }
}


@end
