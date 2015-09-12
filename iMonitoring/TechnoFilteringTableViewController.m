//
//  TechnoFilteringTableViewController.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 30/08/2014.
//
//

#import "TechnoFilteringTableViewController.h"
#import "TechnoFilterViewCell.h"
#import "MapInfoTechnoDatasource.h"
#import "Utility.h"
#import "UserPreferences.h"

@interface TechnoFilteringTableViewController()

@property(nonatomic) MapInfoTechnoDatasource* infoCells;

@property(nonatomic) NSMutableSet<NSNumber*>* frequenciesCheckmark;
@property(nonatomic) NSMutableSet<NSString*>* releasesCheckmark;

@end

static const NSUInteger FILTER_SECTION_FREQUENCIES  = 0;
static const NSUInteger FILTER_SECTION_RELEASES     = 1;

static const NSUInteger FILTER_SECTION_NUMBER = 2;

@implementation TechnoFilteringTableViewController


+(Boolean) hasSubFilter:(DCTechnologyId) theTechno {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];

    if ([userPrefs filterFrequenciesFor:theTechno].count > 0) {
        return TRUE;
    }

    if ([userPrefs filterReleasesFor:theTechno].count > 0) {
        return TRUE;
    }

    return FALSE;
}

#pragma mark - Initializations

-(void) initializeWith:(NSArray*) theCells techno:(DCTechnologyId) theTechno {
    self.infoCells = [[MapInfoTechnoDatasource alloc] init:theTechno];
    [self.infoCells addCells:theCells];

    [self initializeFrequencies];
    [self initializeReleases];
}

-(void) initializeFrequencies {

    NSSet<NSNumber*>* userFilter = [[UserPreferences sharedInstance] filterFrequenciesFor:self.infoCells.theTechno];
    self.frequenciesCheckmark = [userFilter mutableCopy];
}

-(void) initializeReleases {
    NSSet<NSString*>* userFilter = [[UserPreferences sharedInstance] filterReleasesFor:self.infoCells.theTechno];
    self.releasesCheckmark = [userFilter mutableCopy];
}

-(void) viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"%@ Filtering", [BasicTypes getTechnoName:self.infoCells.theTechno]];

    self.tableView.estimatedRowHeight = 62.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return FILTER_SECTION_NUMBER;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case FILTER_SECTION_FREQUENCIES: {
            return @"Frequencies";
        }
        case FILTER_SECTION_RELEASES: {
            return @"Releases";
        }
        default: {
            return @"Unknown";
        }
    }
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case FILTER_SECTION_FREQUENCIES: {
            return self.infoCells.allFrequencies.count;
        }
        case FILTER_SECTION_RELEASES: {
            return self.infoCells.allReleases.count;
        }
        default: {
            NSLog(@"%s Error unknown section number", __PRETTY_FUNCTION__);
            return 0;
        }
    }
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *searchIdentifier = @"TechnoFilterCellId";
    TechnoFilterViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:searchIdentifier];

    NSArray* cells  = Nil;
    NSString* freqOrReleaseName = Nil;
    Boolean currentSelectionStatus = TRUE;

    switch (indexPath.section) {
        case FILTER_SECTION_FREQUENCIES: {
            NSNumber* frequency = self.infoCells.allFrequencies[indexPath.row];
            cells = self.infoCells.cellsPerFrequencies[frequency];
            freqOrReleaseName = [Utility displayShortDLFrequency:[frequency floatValue]];

            currentSelectionStatus = [self.frequenciesCheckmark containsObject:frequency] ? FALSE : TRUE;

            break;
        }
        case FILTER_SECTION_RELEASES: {
            freqOrReleaseName = self.infoCells.allReleases[indexPath.row];
            cells = self.infoCells.cellsPerReleases[freqOrReleaseName];

            currentSelectionStatus = [self.releasesCheckmark containsObject:freqOrReleaseName] ? FALSE : TRUE;
            break;
        }
        default: {
            NSLog(@"%s Error unknown section number", __PRETTY_FUNCTION__);
            return Nil;
        }
    }

    [TechnoFilteringTableViewController updateCellAccessoryFor:cell newValue:currentSelectionStatus];

    [cell initializeWith:cells.count freqOrRelease:freqOrReleaseName];

    return cell;
}

+ (void) updateCellAccessoryFor:(UITableViewCell*) cell newValue:(Boolean) theNewValue {
    if (theNewValue) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    switch (indexPath.section) {
        case FILTER_SECTION_FREQUENCIES: {
            NSNumber* frequency = self.infoCells.allFrequencies[indexPath.row];

            if ([self.frequenciesCheckmark containsObject:frequency]) {
                [self.frequenciesCheckmark removeObject:frequency];
            } else {
                [self.frequenciesCheckmark addObject:frequency];
            }

            [[UserPreferences sharedInstance] setFilterFrequenciesFor:self.infoCells.theTechno filter:self.frequenciesCheckmark];

            break;
        }
        case FILTER_SECTION_RELEASES: {
            NSString* currentRelease = self.infoCells.allReleases[indexPath.row];

            if ([self.releasesCheckmark containsObject:currentRelease]) {
                [self.releasesCheckmark removeObject:currentRelease];
            } else {
                [self.releasesCheckmark addObject:currentRelease];
            }

            [[UserPreferences sharedInstance] setFilterReleasesFor:self.infoCells.theTechno filter:self.releasesCheckmark];

            break;
        }
        default: {
            NSLog(@"%s Error: case unknown", __PRETTY_FUNCTION__);
        }
    }


    [tableView reloadData];
}

@end
