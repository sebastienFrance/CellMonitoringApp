//
//  CellParametersValueViewController.m
//  iMonitoring
//
//  Created by sébastien brugalières on 07/01/13.
//
//

#import "CellParametersValueViewController.h"
#import "ParametersValueCell.h"
#import "CellMonitoring.h"
#import "AttributeNameValue.h"
#import "HistoricalOverviewParametersViewController.h"

@interface CellParametersValueViewController ()

@property (nonatomic) NSArray* sections;

@end

@implementation CellParametersValueViewController



- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self showToolbar];
	// Do any additional setup after loading the view.
    self.theTable.delegate = self;
    self.theTable.dataSource = self;
    
    self.theTable.estimatedRowHeight = 66.0;
    self.theTable.rowHeight = UITableViewAutomaticDimension;
    

    // Do any additional setup after loading the view.
    self.title = self.theCell.id;
    
    self.sections = self.theCell.parametersBySection.sections;
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self showToolbar];
}

-(void) showToolbar {
    [self.navigationController setToolbarHidden:TRUE animated:FALSE];
    self.navigationController.hidesBarsOnSwipe = FALSE;
    self.navigationController.hidesBarsOnTap = FALSE;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self attributesForSection:section].count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray* theAttrNameValues = [self attributesForSection:indexPath.section];
    AttributeNameValue* attrValue = theAttrNameValues[indexPath.row];

    return [ParametersValueCell createCellSimpleParameter:tableView ParameterNameValue:attrValue forIndexPath:indexPath];
}

-(NSArray*) attributesForSection:(NSInteger) sectionIndex {
    return [self.theCell.parametersBySection parametersFromSection:self.sections[sectionIndex]];
}

#pragma mark - Segue
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"pushHistoricalParameters"]) {
        HistoricalOverviewParametersViewController* theControlller = segue.destinationViewController;
        [theControlller initWithCell:self.theCell];
     }
}


@end
