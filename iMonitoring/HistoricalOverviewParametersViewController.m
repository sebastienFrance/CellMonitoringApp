//
//  HistoricalParametersViewController.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 08/03/2015.
//
//

#import "HistoricalOverviewParametersViewController.h"
#import "MBProgressHUD.h"
#import "HistoricalParameterCell.h"
#import "HistoricalParameters.h"
#import "DateUtility.h"
#import "CellParametersDifferencesViewController.h"
#import "CellMonitoring.h"
#import "MailCellParametersWithAllHistoricalDiffs.h"

@interface HistoricalOverviewParametersViewController()

@property (weak, nonatomic) IBOutlet UITableView *theTableView;

@property (nonatomic) CellParametersHistoricalDataSource* datasource;
@property (weak, nonatomic) CellMonitoring* theSourceCell;

@property(nonatomic) Boolean isLoading;

@end


@implementation HistoricalOverviewParametersViewController

-(void) initWithCell:(CellMonitoring*) theCell {
    self.theSourceCell = theCell;
    self.isLoading = FALSE;
}

- (IBAction)actionButtonPushed:(UIBarButtonItem *)sender {
    MailAbstract* theMail = theMail = [[MailCellParametersWithAllHistoricalDiffs alloc] init:self.datasource.theHistoricalData cell:self.theSourceCell];
    
    [theMail presentActivityViewFrom:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    [self showToolbar];

    // Do any additional setup after loading the view.
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    
    self.title = self.theSourceCell.id;
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"loading historical parameters";

    self.datasource = [[CellParametersHistoricalDataSource alloc] init:self];
    [self.datasource loadData:self.theSourceCell];
    
    self.isLoading = TRUE;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isLoading == TRUE) {
        return 0;
    } else {
        return self.datasource.theHistoricalData.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellParamId = @"historicalParameterCellId";
    
    HistoricalParameterCell *cell = [tableView dequeueReusableCellWithIdentifier:cellParamId forIndexPath:indexPath];
    
    HistoricalParameters* currentData = self.datasource.theHistoricalData[indexPath.row];
    [cell initializeWith:currentData];

    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoricalParameters* currentData = self.datasource.theHistoricalData[indexPath.row];

    if (currentData.hasParameters == FALSE) {
        return Nil;
    } else {
        return indexPath;
    }
}

#pragma mark - CellParametersHistoricalDataSourceDelegate

-(void) cellParametersHistoricalResponse:(CellMonitoring *)cell error:(NSError *)theError {
    [MBProgressHUD hideAllHUDsForView:self.view animated:TRUE];
    if (theError != Nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Execution error" message:@"Cannot get historical parameters" delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    } else {
        self.isLoading = FALSE;
        
        [self.theTableView reloadData];
    }
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"pushCellParametersDifferences"]) {
        NSInteger selectedIndex = self.theTableView.indexPathForSelectedRow.row;
        HistoricalParameters* currentData = self.datasource.theHistoricalData[selectedIndex];

        CellParametersDifferencesViewController* viewController = segue.destinationViewController;
        [viewController initializeWith:currentData forCell:(CellMonitoring*) self.theSourceCell];
    }
}


@end
