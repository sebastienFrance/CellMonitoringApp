//
//  DetailsWorstKPIsViewController.m
//  iMonitoring
//
//  Created by sébastien brugalières on 06/10/12.
//
//

#import "iPadDashboardWorstDetailsViewController.h"
#import "CellKPIsDataSource.h"
#import "MBProgressHUD.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "CellMonitoring.h"
#import "KPIDictionary.h"
#import "KPI.h"
#import "DateUtility.h"
#import "WorstKPIChart.h"
#import "DetailsWorstKPIsViewController.h"
#import "CellWithKPIValues.h"
#import "WorstKPIItf.h"
#import "MailWorstCellsKPI.h"
#import "DetailsWorstKPIViewCell.h"
#import "AroundMeViewMgt.h"
#import "AroundMeImpl.h"
#import "UserPreferences.h"
#import "AroundMeViewController.h"
#import "CellKPIsDataSource.h"
#import "DataCenter.h"
#import "WorstCellSource.h"
#import "CellDetailsInfoBasicViewController.h"

@interface DetailsWorstKPIsViewController()

@property(nonatomic) NSArray* KPIValuesPerCell;
@property(nonatomic) NSString* KPIName;
@property(nonatomic) Boolean isAverageKPIs;
@property(nonatomic) Boolean displayingPrimary;

@property(nonatomic) WorstKPIChart* theChart;

@property(nonatomic) CellKPIsDataSource* cellDatasource;

@property(nonatomic) NSLayoutConstraint* addedConstraint;

@property(nonatomic) WorstKPIChart* thePreviousChart;


@end


@implementation DetailsWorstKPIsViewController

#pragma mark - pieChartNotification protocol
- (void) selectedSlice:(NSUInteger) index {
    if ((self.theSegment.selectedSegmentIndex == 0) || (self.theSegment.selectedSegmentIndex == 1)) {
        // look for the first cell with the selected slice
        NSUInteger targetIndex = 0;
        for (CellWithKPIValues* currentCellKPis in self.KPIValuesPerCell) {
            
            NSNumber* valueToBeDisplayed;
            if (self.isAverageKPIs == FALSE) {
                valueToBeDisplayed = currentCellKPis.lastKPIValue;
            } else {
                valueToBeDisplayed = currentCellKPis.averageValue;
            }
            
            if (index == [currentCellKPis.theKPI getColorIdFromNumber:valueToBeDisplayed]) {
                break;
            }
            
            targetIndex++;
            
        }
        if (targetIndex < self.KPIValuesPerCell.count) {
            NSIndexPath* newIndex= [NSIndexPath indexPathForRow:targetIndex inSection:0];
            [self.theKPITable scrollToRowAtIndexPath:newIndex atScrollPosition:UITableViewScrollPositionTop animated:TRUE];
        } else {
            // No row to be displayed
        }
        
    }
    
    
}

#pragma mark - Manage buttons

- (IBAction)closeButtonPushed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:TRUE completion:Nil];
}


- (IBAction)NextKPI:(UIButton *)sender {
    [_delegate moveToNextKPI];
    [self resyncAndDisplayWithNewKPI];
}
- (IBAction)PreviousKPI:(UIButton *)sender {
    [_delegate moveToPreviousKPI];
    [self resyncAndDisplayWithNewKPI];
}

- (IBAction)goToNextKPI:(UIBarButtonItem *)sender {
    [_delegate moveToNextKPI];
    [self resyncAndDisplayWithNewKPI];
}
- (IBAction)goToPreviousKPI:(UIBarButtonItem *)sender {
    [_delegate moveToPreviousKPI];
    [self resyncAndDisplayWithNewKPI];
}

- (IBAction)swipeToPrevious:(id)sender {
    UIView* displayedView = [self displayedViewChart];
    CGRect displayedViewFrameTarget = [self moveDisplayedViewFromLeft:TRUE];
    
    UIView* hiddenView = [self hiddenViewChart];
    CGRect hiddenViewFrame = [self moveHiddenViewFromLeft:TRUE];

    [self resyncViewWithNewPeriod];
    
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        displayedView.frame = displayedViewFrameTarget;
        hiddenView.frame = hiddenViewFrame;
    } completion:^(BOOL finished){
        if (finished) {
            self.displayingPrimary = !self.displayingPrimary;
            displayedView.hidden = TRUE;
        }
    }];
}

- (IBAction)swipeToNext:(id)sender {
    
    UIView* displayedView = [self displayedViewChart];
    CGRect displayedViewFrameTarget = [self moveDisplayedViewFromLeft:FALSE];
    
    UIView* hiddenView = [self hiddenViewChart];
    CGRect hiddenViewFrame = [self moveHiddenViewFromLeft:FALSE];

    [self resyncViewWithNewPeriod];

    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        displayedView.frame = displayedViewFrameTarget;
        hiddenView.frame = hiddenViewFrame;
    } completion:^(BOOL finished){
        if (finished) {
            self.displayingPrimary = !self.displayingPrimary;
            displayedView.hidden = TRUE;
        }
    }];
}

-(CGRect) moveHiddenViewFromLeft:(Boolean) fromLeft {
    UIView* hiddenView = [self hiddenViewChart];
    CGRect hiddenViewFrame = hiddenView.frame;
    
    CGRect originViewFrame = hiddenViewFrame;
    
    if (fromLeft) {
        originViewFrame.origin.x = -hiddenView.frame.size.width;
    } else {
        originViewFrame.origin.x = hiddenView.frame.size.width;
    }
    
    hiddenView.frame = originViewFrame;
    hiddenView.hidden = FALSE;
    
    hiddenViewFrame.origin.x = 0;
    
    return hiddenViewFrame;
}

-(CGRect) moveDisplayedViewFromLeft:(Boolean) fromLeft {
    UIView* displayedView = [self displayedViewChart];
    CGRect displayedViewFrameTarget = displayedView.frame;
    
    displayedViewFrameTarget.origin.x = fromLeft ? displayedViewFrameTarget.size.width : -displayedViewFrameTarget.size.width;
    
    return displayedViewFrameTarget;
}


- (void) resyncViewWithNewPeriod {
    self.isAverageKPIs = !self.isAverageKPIs;
    
    // reorder the current table depending on the active segment
    NSInteger theSelectedSegment = self.theSegment.selectedSegmentIndex;
    [self reorderTableForSegment:theSelectedSegment];
    
    // re-initialize the graph and update it
    [self displayChart:FALSE];
    
}

-(CPTGraphHostingView *) displayedViewChart {
    return self.displayingPrimary ? self.theGraph : self.theSecondGraph;
}

-(CPTGraphHostingView *) hiddenViewChart {
    return !self.displayingPrimary ? self.theGraph : self.theSecondGraph;
}



- (IBAction)sendMail:(UIBarButtonItem *)sender {
    
    MailWorstCellsKPI* mailWorst = [[MailWorstCellsKPI alloc] init:self.KPIValuesPerCell isAverageKPIs:self.isAverageKPIs worstItf:_delegate KPIName:self.KPIName];
    [mailWorst setGraphImageAttachment:self.theChart.pieGraph title:self.KPIName];
    [self openMail:sender mail:mailWorst];
}

- (void) openMail:(UIBarButtonItem *)sender mail:(MailAbstract*) theMail {
    [theMail presentActivityViewFrom:self];
}

- (void) resyncAndDisplayWithNewKPI {
    self.KPIValuesPerCell = [_delegate getKPIValues];
    
    if (self.KPIValuesPerCell != Nil) {
        CellWithKPIValues* firstCell = self.KPIValuesPerCell[0];
        self.KPIName = firstCell.theKPI.name;
    }
    self.navigationItem.title = self.KPIName;
    
    // reorder the current table depending on the active segment
    NSInteger theSelectedSegment = self.theSegment.selectedSegmentIndex;
    [self reorderTableForSegment:theSelectedSegment];
    
    //#warning maybe some object to be cleanup before to display the new graph?
    [self displayChart:FALSE];
    
    [self resetHiddenViewChartCoordinate];
    
    [UIView transitionFromView:[self displayedViewChart]
                        toView:[self hiddenViewChart]
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionShowHideTransitionViews
                    completion:^(BOOL finished) {
                        if (finished) {
                            [self displayedViewChart].hidden = TRUE;
                            self.displayingPrimary = !self.displayingPrimary;
                        }
                    }];
}


-(void) resetHiddenViewChartCoordinate {
    UIView* hiddenView = [self hiddenViewChart];
    hiddenView.hidden = FALSE;
    CGRect hiddenViewFrameTarget = hiddenView.frame;
    hiddenViewFrameTarget.origin.x = 0;
    hiddenView.frame = hiddenViewFrameTarget;
}

- (IBAction)changeTableOrder:(UISegmentedControl *)sender {
    [self reorderTableForSegment:sender.selectedSegmentIndex];
    
}

- (void) reorderTableForSegment:(NSInteger) selectedSegment {
    
    self.enableInfoPanel = TRUE;
    
    switch(selectedSegment) {
        case 0: {
            if (self.isAverageKPIs) {
                self.KPIValuesPerCell = [self.KPIValuesPerCell sortedArrayUsingSelector:@selector(compareWithAverageKPIValue:)];
            } else {
                self.KPIValuesPerCell = [self.KPIValuesPerCell sortedArrayUsingSelector:@selector(compareWithLastKPIValue:)];
            }
            
            break;
        }
        case 1: {
            if (self.isAverageKPIs) {
                self.KPIValuesPerCell = [self.KPIValuesPerCell sortedArrayUsingSelector:@selector(compareReverseWithAverageKPIValue:)];
            } else {
                self.KPIValuesPerCell = [self.KPIValuesPerCell sortedArrayUsingSelector:@selector(compareReverseWithLastKPIValue:)];
            }
            break;
        }
        case 2: {
            self.enableInfoPanel = FALSE;
            self.KPIValuesPerCell = [self.KPIValuesPerCell sortedArrayUsingSelector:@selector(compareWithCellName:)];
            break;
        }
    }
    [self.theKPITable reloadData];
    [self.theKPITable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:TRUE];
    
}

#pragma mark - Initialization 
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void) initialize:(WorstKPIDataSource*) datasource initialIndex:(NSUInteger) index isAverage:(Boolean) isAverageKPIs {
    _isAverageKPIs = isAverageKPIs;
    
    _delegate = [[WorstCellSource alloc] init:datasource initialIndex:index isAverage:isAverageKPIs];

    self.KPIValuesPerCell = [_delegate getKPIValues];
    
    if (self.KPIValuesPerCell != Nil) {
        CellWithKPIValues* firstCell = self.KPIValuesPerCell[0];
        self.KPIName = firstCell.theKPI.name;
    }
}


- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [self showToolbar];
    
    self.theKPITable.delegate = self;
    self.theKPITable.dataSource = self;
    self.displayingPrimary = FALSE;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    [self initializeConstraintsForOrientation:orientation];

    
    [self displayChart:TRUE];
    
    self.displayingPrimary = TRUE;

    [super viewDidLoad];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self showToolbar];
}

-(void) showToolbar {
//    [self.navigationController setToolbarHidden:FALSE animated:FALSE];
//    self.navigationController.hidesBarsOnSwipe = FALSE;
//    self.navigationController.hidesBarsOnTap = FALSE;
}


- (void) initializeConstraintsForOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        CGFloat heightPercentage = 0.0f;
        if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
            (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
            heightPercentage = 1.0f;
            self.theToolbar.hidden = TRUE;
        } else {
            heightPercentage = 0.40f;
            self.theToolbar.hidden = FALSE;
        }
        
        [self.view removeConstraint:self.addedConstraint];
        self.addedConstraint = [NSLayoutConstraint constraintWithItem:self.theGraphContainer
                                                            attribute:NSLayoutAttributeBottom
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.view
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:heightPercentage
                                                             constant:0];
        
        [self.view addConstraint:self.addedConstraint];
       
        [self setGraphicPropertiesBasedOnOrientation:toInterfaceOrientation chart:self.theChart];
    }
}



- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self initializeConstraintsForOrientation:toInterfaceOrientation];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (void) displayChart:(Boolean) animate {
    CellWithKPIValues* firstCell = self.KPIValuesPerCell[0];
    KPI* theKPI = firstCell.theKPI;
    
    self.thePreviousChart = self.theChart; // keep a reference to avoid Exec exceptions when switching from on chart to another
    [self.thePreviousChart unregisterDelegates];

    self.theChart = [WorstKPIChart instantiateChart:self.KPIValuesPerCell isLastWorst:!self.isAverageKPIs];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    [self setGraphicPropertiesBasedOnOrientation:orientation chart:self.theChart];
    
    self.theChart.title = [NSString stringWithFormat:@"%@ / %@", theKPI.domain, theKPI.name];
    self.theChart.subscriber = self;
    self.theChart.fillWithGradient = [UserPreferences sharedInstance].isZoneKPIDetailsGradiant;
    
    CPTGraphHostingView *hostingView = [self hiddenViewChart];

    [self.theChart displayChart:hostingView withAnimate:animate];
}

- (void) setGraphicPropertiesBasedOnOrientation:(UIInterfaceOrientation) orientation chart:(WorstKPIChart*) theChart {
    if ((orientation == UIInterfaceOrientationLandscapeLeft) ||
        (orientation == UIInterfaceOrientationLandscapeRight)) {
        theChart.titleFontSize = 14.0f;
        theChart.yTitleDisplacement = -10.0f;
        theChart.pieRadius = 130.0;
        theChart.legendXDisplacement = 170.0;
        theChart.legendYDisplacement = 80.0;
    } else {
        theChart.titleFontSize = 14.0f;
        theChart.yTitleDisplacement = -10.0f;
        theChart.pieRadius = 90.0;
        theChart.legendXDisplacement = 100.0;
        theChart.legendYDisplacement = 30.0;
    }
   
}


#pragma mark - Table view delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    MonitoringPeriodUtility* dc = [MonitoringPeriodUtility sharedInstance];
    if (self.isAverageKPIs == TRUE) {
        return [MonitoringPeriodUtility getStringForGranularityPeriodDuration:dc.monitoringPeriod];
    } else {
        return [MonitoringPeriodUtility getStringForGranularityPeriodName:dc.monitoringPeriod];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.KPIValuesPerCell.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DetailsWorstKPIViewCellId";
    DetailsWorstKPIViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == Nil) {
        cell = [[DetailsWorstKPIViewCell alloc] init];
    }
    
    CellWithKPIValues* cellData = self.KPIValuesPerCell[indexPath.row];
    [cell initWithCellKPIValues:cellData isWithAverage:self.isAverageKPIs index:indexPath.row];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}
- (IBAction)MapButtonPressed:(UIButton *)sender {
    CellWithKPIValues* selectedCell = self.KPIValuesPerCell[sender.tag];
    
    CellMonitoring* theCell = [_delegate getCellbyName:selectedCell.cellName];
    AroundMeImpl* aroundMe = (AroundMeImpl*)[DataCenter sharedInstance].aroundMeItf;
    
    [self.navigationController popToViewController:aroundMe.aroundMeViewController animated:TRUE];

    [aroundMe showSelectedCellOnMap:theCell];
}
- (IBAction)KPIsButtonPressed:(UIButton *)sender {
    CellWithKPIValues* selectedCell = self.KPIValuesPerCell[sender.tag];
    
    CellMonitoring* theCell = [_delegate getCellbyName:selectedCell.cellName];
    
    [self performSegueWithIdentifier:@"DashboardToCellKPIs" sender:theCell];
}

// DashboardToCellKPIs
#pragma mark - segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DashboardToCellKPIs"]) {
        
        CellDetailsInfoBasicViewController *details = segue.destinationViewController;
        [details initialize:sender delegate:[DataCenter sharedInstance].aroundMeItf];
    }
}

#pragma mark - KNPathTableViewController customization

- (UITableView*) tableView {
    return self.theKPITable;
}

-(void)infoPanelDidScroll:(UIScrollView *)scrollView atPoint:(CGPoint)point {
    NSIndexPath * indexPath = [self.theKPITable indexPathForRowAtPoint:point];
    
    CellWithKPIValues* cellData = self.KPIValuesPerCell[indexPath.row];
    
    NSNumber* valueToBeDisplayed;
    if (self.isAverageKPIs == FALSE) {
        valueToBeDisplayed = cellData.lastKPIValue;
    } else {
        valueToBeDisplayed = cellData.averageValue;
    }
    
    self.infoLabel.text = [NSString stringWithFormat:@"%@", [cellData.theKPI getDisplayableValueFromNumber:valueToBeDisplayed]];
}


- (float) maxWidthInfoLabel {
    
    UIFont* theFont = [UIFont boldSystemFontOfSize:12];
    NSDictionary* myDico = @{NSFontAttributeName : theFont};
    
    CGSize initSize = CGSizeMake(10.0, 2.0);
    NSStringDrawingContext* drawingContext = [[NSStringDrawingContext alloc] init];
  
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"100.00%" attributes:myDico];
    CGRect rect = [attrString boundingRectWithSize:initSize options:NSStringDrawingUsesDeviceMetrics context:drawingContext];
  
    return ceil(rect.size.width);
}


@end
