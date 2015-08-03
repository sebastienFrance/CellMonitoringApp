//
//  iPadCellGroupPopoverViewController.m
//  iMonitoring
//
//  Created by sébastien brugalières on 12/04/13.
//
//

#import "CellGroupViewController.h"
#import "CellMonitoringGroup.h"
#import "CellMonitoring.h"
#import "CellGroupViewCell.h"
#import "CellDetailsAndKPIsViewController.h"
#import "VisitedCells+History.h"
#import "DataCenter.h"
#import "AroundMeViewItf.h"
#import "iPadCellDetailsPopoverMenuViewController.h"

@interface CellGroupViewController ()

@property(nonatomic, weak) id<AroundMeViewItf> delegate;

@property(nonatomic) NSArray* displayCells;

@property(nonatomic) NSArray* allCells;
@property(nonatomic) NSArray* LTECells;
@property(nonatomic) NSArray* WCDMACells;
@property(nonatomic) NSArray* GSMCells;

@end

@implementation CellGroupViewController

@synthesize theTableView;
@synthesize theSegment;

-(void) initialize:(CellMonitoringGroup*) cellGroup delegate:(id<AroundMeViewItf>) theDelegate {
    _delegate = theDelegate;
    
    NSMutableArray* theAllCells = [[NSMutableArray alloc] initWithArray:cellGroup.filteredCells];
    NSMutableArray* theLTECells = [[NSMutableArray alloc] init];
    NSMutableArray* theWCDMACells = [[NSMutableArray alloc] init];
    NSMutableArray* theGSMCells = [[NSMutableArray alloc] init];
    
    for (CellMonitoring* currentCell in theAllCells) {
        switch (currentCell.cellTechnology) {
            case DCTechnologyLTE: {
                [theLTECells addObject:currentCell];
                break;
            }
            case DCTechnologyWCDMA: {
                [theWCDMACells addObject:currentCell];
                break;
            }
            case DCTechnologyGSM: {
                [theGSMCells addObject:currentCell];
                break;
            }
            default: {
                
            }
        }
    }
    
    [theAllCells sortUsingSelector:@selector(compareByName:)];
    [theLTECells sortUsingSelector:@selector(compareByName:)];
    [theWCDMACells sortUsingSelector:@selector(compareByName:)];
    [theGSMCells sortUsingSelector:@selector(compareByName:)];
    
    _allCells = theAllCells;
    _LTECells = theLTECells;
    _WCDMACells = theWCDMACells;
    _GSMCells = theGSMCells;
    
    _displayCells = _allCells;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    theTableView.dataSource = self;
    theTableView.delegate = self;
    
    self.theTableView.estimatedRowHeight = 131.0;
    self.theTableView.rowHeight = UITableViewAutomaticDimension;
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.theTableView reloadData];
    
    [self.navigationController setToolbarHidden:FALSE];
    self.navigationController.hidesBarsOnTap = false;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)segmentValueHasChanged:(UISegmentedControl *)sender {
    
    switch (sender.selectedSegmentIndex) {
        case 0: {
           self.displayCells = self.allCells;
            break;
        }
        case 1: {
            self.displayCells = self.LTECells;
            break;
        }
        case 2: {
            self.displayCells = self.WCDMACells;
            break;
        }
        case 3: {
            self.displayCells = self.GSMCells;
            break;
        }
        default: {
            NSLog(@"%s Error, unknown selected segment", __PRETTY_FUNCTION__);
            break;
        }
    }
    [self.theTableView reloadData];
    
    // protect again empty tables!
    if (self.displayCells.count > 0) {
        [theTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:TRUE];
    }
}

- (IBAction)neighborsButtonSelected:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:TRUE];
    
    DataCenter* dc = [DataCenter sharedInstance];
    [dc.aroundMeItf initiliazeWithNeighborsOf:self.displayCells[sender.tag]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.displayCells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellGroupId";
    
    CellGroupViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    [cell initializeWithCell:self.displayCells[indexPath.row] index:indexPath.row];
    
    return cell;
}

#pragma mark - segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    CellMonitoring* selectedCell = self.displayCells[self.theTableView.indexPathForSelectedRow.row];
    [VisitedCells createVisitedCells:selectedCell];
    
    // Segue for iPad
    if ([segue.identifier isEqualToString:@"CellGroupToCellId"]) {
 
         iPadCellDetailsPopoverMenuViewController* details = segue.destinationViewController;

        [details initialize:selectedCell delegate:self.delegate];
    // Segue for iPhone
    } else if ([segue.identifier isEqualToString:@"pushCellDetails"]) {
        
        CellDetailsAndKPIsViewController *details = segue.destinationViewController;
        [details initialize:selectedCell delegate:self.delegate];
    }
}
@end
