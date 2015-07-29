//
//  VisitedCellsViewController.m
//  iMonitoring
//
//  Created by sébastien brugalières on 29/04/13.
//
//

#import "VisitedCellsViewController.h"
#import "VisitedCellViewCell.h"
#import "CellMonitoring.h"
#import "DataCenter.h"
#import "AroundMeViewItf.h"
#import "AroundMeViewMgt.h"
#import "VisitedCells+History.h"
#import "DateUtility.h"
#import <Foundation/Foundation.h>

@interface VisitedCellsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *theTable;

@property (nonatomic) NSArray* lastVisitedCells;
@property (weak, nonatomic) IBOutlet UISegmentedControl *theSegmentForOrdering;

@end

@implementation VisitedCellsViewController


- (void)viewDidLoad
{
    self.theTable.delegate = self;
    self.theTable.dataSource = self;
    
    self.lastVisitedCells = [VisitedCells loadVisitedCells];
    self.lastVisitedCells = [self.lastVisitedCells sortedArrayUsingSelector:@selector(compareByLastVisited:)];

    [super viewDidLoad];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.navigationController setToolbarHidden:FALSE];
        self.navigationController.hidesBarsOnTap = FALSE;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)segmentPushed:(UISegmentedControl *)sender {

    self.enableInfoPanel = FALSE;
    switch (sender.selectedSegmentIndex) {
        case 0: {
            // order by Date
            self.lastVisitedCells = [self.lastVisitedCells sortedArrayUsingSelector:@selector(compareByLastVisited:)];
            self.enableInfoPanel = TRUE;
            break;
        }
        case 1: {
            // order by Most Visited
            self.lastVisitedCells = [self.lastVisitedCells sortedArrayUsingSelector:@selector(compareByMostVisited:)];
            break;
        }
        case 2: {
            // order by Techno
            self.lastVisitedCells = [self.lastVisitedCells sortedArrayUsingSelector:@selector(compareByTechnology:)];
            break;
        }
       case 3: {
            // order by Name
            self.lastVisitedCells = [self.lastVisitedCells sortedArrayUsingSelector:@selector(compareByName:)];
            break;
        }
        default: {
            NSLog(@"%s Error, unknown selected segment", __PRETTY_FUNCTION__);
            break;
        }
    }
    [self.theTable reloadData];
    
    // protect again empty tables!
    if (self.lastVisitedCells.count > 0) {
        [self.theTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:TRUE];
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.lastVisitedCells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"VisitedCellViewCellId";
    VisitedCellViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == Nil) {
        cell = [[VisitedCellViewCell alloc] init];
    }
    
    [cell initializeWithVisitedCell:self.lastVisitedCells[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.navigationController popViewControllerAnimated:TRUE];
    } else {
        // it's the iPad
        [self dismissViewControllerAnimated:TRUE completion:Nil];
    }
    
    VisitedCells* theVisitedCell = self.lastVisitedCells[indexPath.row];
    CLLocationCoordinate2D newCoordinate = theVisitedCell.theCellCoordinate;
    id<AroundMeViewItf> vc = [[DataCenter sharedInstance] aroundMeItf];
    [vc.viewMgt showRegionFromSelectedCell:newCoordinate withSelectedCell:theVisitedCell.cellInternalName];

}

#pragma mark - KNPathTableViewController customization
- (UITableView*) tableView {
    return self.theTable;
}

-(void)infoPanelDidScroll:(UIScrollView *)scrollView atPoint:(CGPoint)point {
    NSIndexPath * indexPath = [self.theTable indexPathForRowAtPoint:point];
    
    VisitedCells* theVisitedCell = self.lastVisitedCells[indexPath.row];
    
    self.infoLabel.text = [DateUtility getDate:theVisitedCell.lastVisitedDate option:withHHmm];
}


- (float) maxWidthInfoLabel {
    float maxWidth = 0.0;
    
    UIFont* theFont = [UIFont boldSystemFontOfSize:12];
    NSDictionary* myDico = @{NSFontAttributeName : theFont};

    for (VisitedCells* currentVisitedCells in self.lastVisitedCells) {
        NSString* currentCellDate = [DateUtility getDate:currentVisitedCells.lastVisitedDate option:withHHmm];
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:currentCellDate attributes:myDico];
        
        CGSize initSize = CGSizeMake(10.0, 2.0);
        NSStringDrawingContext* drawingContext = [[NSStringDrawingContext alloc] init];
        
        CGRect rect = [attrString boundingRectWithSize:initSize options:NSStringDrawingUsesDeviceMetrics context:drawingContext];
        
        maxWidth = rect.size.width > maxWidth ? rect.size.width : maxWidth;
    }
    
    return ceil(maxWidth);
}


@end
