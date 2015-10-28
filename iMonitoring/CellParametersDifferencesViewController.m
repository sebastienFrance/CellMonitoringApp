//
//  CellParametersDifferencesViewController.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 15/03/2015.
//
//

#import "CellParametersDifferencesViewController.h"
#import "HistoricalParameters.h"
#import "DateUtility.h"
#import "CellParametersDifferencesViewCell.h"
#import "Parameters.h"
#import "AttributeNameValue.h"
#import "ParametersValueCell.h"
#import "MailCellParametersWithDiffs.h"
#import "CellMonitoring.h"


@interface CellParametersDifferencesViewController ()

@property (weak, nonatomic) IBOutlet UITableView *theTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *displayModeSegmentedControl;

@property (nonatomic) HistoricalParameters* cellParametersDifferences;
@property (nonatomic) CellMonitoring* theSourceCell;

@property (nonatomic) NSUInteger displayMode;

@property (nonatomic) NSArray* indexedSectionName;

@end

@implementation CellParametersDifferencesViewController

-(void) initializeWith:(HistoricalParameters*) cellParametersWithDifferences forCell:(CellMonitoring*) sourceCell {
    self.cellParametersDifferences = cellParametersWithDifferences;
    self.theSourceCell = sourceCell;

    self.title = [DateUtility getSimpleLocalizedDate:cellParametersWithDifferences.theDate];
}
- (IBAction)actionButtonPushed:(UIBarButtonItem *)sender {
    MailAbstract* theMail = theMail = [[MailCellParametersWithDiffs alloc] init:self.cellParametersDifferences cell:self.theSourceCell];
    
    [theMail presentActivityViewFrom:self];
}

static const NSUInteger PARAMETERS_DISPLAY_ALL = 0;
static const NSUInteger PARAMETERS_DISPLAY_DIFFERENCES_ONLY = 1;

- (IBAction)SegmentedPushed:(UISegmentedControl *)sender {
    self.displayMode = sender.selectedSegmentIndex;
    [self initializeDataBasedOnDisplayMode];
    [self.theTableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showToolbar];

    self.theTableView.dataSource = self;
    self.theTableView.delegate = self;

    self.theTableView.estimatedRowHeight = 59.0;
    self.theTableView.rowHeight = UITableViewAutomaticDimension;
    

    self.displayMode = PARAMETERS_DISPLAY_ALL;
    [self initializeDataBasedOnDisplayMode];
    
    if (self.cellParametersDifferences.theDifferences.count == 0) {
        self.displayModeSegmentedControl.enabled = FALSE;
    }
    
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self showToolbar];
}

-(void) showToolbar {
    [self.navigationController setToolbarHidden:TRUE animated:FALSE];
}


-(void) initializeDataBasedOnDisplayMode {
    switch (self.displayMode) {
        case PARAMETERS_DISPLAY_ALL: {
            self.indexedSectionName = self.cellParametersDifferences.theParameters.sections;
            break;
        }
        case PARAMETERS_DISPLAY_DIFFERENCES_ONLY: {
            self.indexedSectionName =  self.cellParametersDifferences.theDifferences.allKeys;
            break;
        }
        default: {
            NSLog(@"%s, warning unknown case!", __PRETTY_FUNCTION__);
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.indexedSectionName.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.indexedSectionName[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString* sectionName = self.indexedSectionName[section];
    switch (self.displayMode) {
        case PARAMETERS_DISPLAY_ALL: {
            return [self.cellParametersDifferences.theParameters parametersFromSection:sectionName].count;
        }
        case PARAMETERS_DISPLAY_DIFFERENCES_ONLY: {
            NSArray* parameters = self.cellParametersDifferences.theDifferences[sectionName];
            return parameters.count;
        }
        default: {
            NSLog(@"%s, warning unknown case!", __PRETTY_FUNCTION__);
            return 0;
        }
    }
}

/*
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (self.displayMode) {
        case PARAMETERS_DISPLAY_ALL: {
            NSString* sectionName = self.indexedSectionName[indexPath.section];
            NSArray* allParametersOfSection = [self.cellParametersDifferences.theParameters parametersFromSection:sectionName];
            AttributeNameValue* parameter = allParametersOfSection[indexPath.row];
            
            if ([self.cellParametersDifferences hasParameterInDifferences:sectionName parameterName:parameter.name]) {
                return CELL_HEIGHT_WITH_DIFFERENCES;
            } else {
                return CELL_HEIGHT_WITHOUT_DIFFERENCES;
            }
        }
        case PARAMETERS_DISPLAY_DIFFERENCES_ONLY: {
            return CELL_HEIGHT_WITH_DIFFERENCES;
        }
        default: {
            NSLog(@"%s, warning unknown case!", __PRETTY_FUNCTION__);
            return CELL_HEIGHT_WITH_DIFFERENCES;
        }
    }
}*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     switch (self.displayMode) {
        case PARAMETERS_DISPLAY_ALL: {
            return [self cellForDisplayAllParameters:tableView cellForRowAtIndexPath:indexPath];
        }
        case PARAMETERS_DISPLAY_DIFFERENCES_ONLY: {
            return [self cellForDisplayDifferencesOnly:tableView cellForRowAtIndexPath:indexPath];
        }
        default: {
            NSLog(@"%s, warning unknown case!", __PRETTY_FUNCTION__);
            return Nil;
        }
    }
}


-(UITableViewCell*) cellForDisplayAllParameters:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*) indexPath {
    NSString* sectionName = self.indexedSectionName[indexPath.section];
    NSArray* allParametersOfSection = [self.cellParametersDifferences.theParameters parametersFromSection:sectionName];
    AttributeNameValue* parameter = allParametersOfSection[indexPath.row];
    
    if ([self.cellParametersDifferences hasParameterInDifferences:sectionName parameterName:parameter.name]) {
        CellParametersDifferencesViewCell *cell = [CellParametersDifferencesViewController getCellForDifferences:tableView cellForRowAtIndexPath:indexPath];
        [cell initializeWith:self.cellParametersDifferences sectionName:sectionName parameterName:parameter.name highlightDifferences:TRUE];
        return cell;
    } else {
        return [ParametersValueCell createCellSimpleParameter:tableView ParameterNameValue:parameter forIndexPath:indexPath];
    }
}

-(UITableViewCell*) cellForDisplayDifferencesOnly:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*) indexPath {
    NSString* theSectionName = self.indexedSectionName[indexPath.section];
    
    NSString* parameterName = self.cellParametersDifferences.theDifferences[theSectionName][indexPath.row];
    
    CellParametersDifferencesViewCell *cell = [CellParametersDifferencesViewController getCellForDifferences:tableView cellForRowAtIndexPath:indexPath];
    [cell initializeWith:self.cellParametersDifferences sectionName:theSectionName parameterName:parameterName highlightDifferences:FALSE];
    return cell;
}

+(CellParametersDifferencesViewCell*) getCellForDifferences:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*) indexPath {
    static NSString *cellParamDiffId = @"cellParameterDiffId";
    
    CellParametersDifferencesViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellParamDiffId forIndexPath:indexPath];
    return cell;
}


@end
