//
//  HistoricalNRsOverviewViewController.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 25/01/2015.
//
//

#import "HistoricalNRsOverviewViewController.h"
#import "HistoricalNRsOverviewCell.h"
#import "NeighborsDataSourceUtility.h"
#import "HistoricalCellNeighborsData.h"
#import "NeighborsLocateViewController.h"
#import "MailCellNeighborsRelationsWithAllHistoricalDiffs.h"
#import "MBProgressHUD.h"

@interface HistoricalNRsOverviewViewController ()

@property (weak, nonatomic) IBOutlet UITableView *theTable;

@property (nonatomic) CellMonitoring* theCell;

@property(nonatomic) NeighborsHistoricalDataSource* nrHistoricalDataSource;

@property(nonatomic) Boolean isLoading;

@end

@implementation HistoricalNRsOverviewViewController

-(void) initWithCell:(CellMonitoring*) theCell {
    self.theCell = theCell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.theTable.delegate = self;
    self.theTable.dataSource = self;
    
    self.isLoading = TRUE;
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading data";
    
    self.nrHistoricalDataSource = [[NeighborsHistoricalDataSource alloc] init:self];
    [self.nrHistoricalDataSource loadData:self.theCell];

    self.title = self.theCell.id;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) neighborsHistoricalDataIsLoaded:(CellMonitoring*) centerCell {
    [MBProgressHUD hideAllHUDsForView:self.view animated:TRUE];
    self.isLoading = FALSE;
    
    [self.theTable reloadData];
}

- (void) neighborsHistoricalDataLoadingFailure {
    [MBProgressHUD hideAllHUDsForView:self.view animated:TRUE];
    self.isLoading = FALSE;
}
- (IBAction)sendMail:(UIBarButtonItem *)sender {
    MailAbstract* theMail = [[MailCellNeighborsRelationsWithAllHistoricalDiffs alloc] init:self.nrHistoricalDataSource.theHistoricalData];
    [theMail presentActivityViewFrom:self];
}

- (IBAction)buttonDisplayAllPushed:(UIButton *)sender {
    HistoricalCellNeighborsData* historicalNeighbors = self.nrHistoricalDataSource.theHistoricalData[sender.tag];
    [self performSegueWithIdentifier:@"showAllHistoricalNRs" sender:historicalNeighbors];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isLoading) {
        return 0;
    } else {
        return self.nrHistoricalDataSource.theHistoricalData.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"HistoricalNRsOverviewCellId";
    HistoricalNRsOverviewCell *cell = [self.theTable dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == Nil) {
        cell = [[HistoricalNRsOverviewCell alloc] init];
        
    }
    
    HistoricalCellNeighborsData* historicalNeighbors = self.nrHistoricalDataSource.theHistoricalData[indexPath.row];
    
    [cell initializeWith:historicalNeighbors index:indexPath.row];
    
    return cell;
}


#pragma mark - Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"showAllHistoricalNRs"]) {
        NeighborsLocateViewController* controller = segue.destinationViewController;
        HistoricalCellNeighborsData* historicalNeighbors = sender;
        [controller initiliazeWith:historicalNeighbors.currentNeighbors delegate:Nil];
    } else if ([segue.identifier isEqualToString:@"openNREventsView"]) {
        NeighborsLocateViewController* controller = segue.destinationViewController;
        NSIndexPath* theIndexPath = self.theTable.indexPathForSelectedRow;
        HistoricalCellNeighborsData* historicalNeighbors = self.nrHistoricalDataSource.theHistoricalData[theIndexPath.row];
        [controller initializeWith:historicalNeighbors];
    }
}

@end
