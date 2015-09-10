//
//  DetailsCellKPIViewController.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 21/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailsCellWithChartViewController.h"
#import "KPI.h"
#import "CellDetailsCellKPIViewCell.h"
#import "CellDetailsPeriodCellKPIViewCell.h"
#import "CellMonitoring.h"
#import "DataCenter.h"
#import "DateUtility.h"
#import "KPIBarChart.h"
#import "KPIDataSource.h"
#import "KPIDictionary.h"
#import "MailCellDetailedKPI.h"
#import "UserPreferences.h"
#import "MailActivity.h"
#import "iMonNavigationDataActivity.h"
#import "CellKPIDatasource.h"
#import "UserHelp.h"

@interface DetailsCellWithChartViewController ()

@property(nonatomic) NSLayoutConstraint* addedConstraint;
@property(nonatomic) KPIBarChart* thePreviousChart;

@property(nonatomic) KPIBarChart* theChart;
@property(nonatomic) CellMonitoring* theCell;

@property(nonatomic) Boolean displayingPrimary;

@property(nonatomic) NSDate* dateOfKPIsValues;

@property (weak, nonatomic) IBOutlet UIToolbar *theToolbar;

@end

@implementation DetailsCellWithChartViewController

#pragma mark - barChartNotification protocol
- (void) selectedBar:(NSUInteger) index {
    [self.theKPITable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:TRUE];
}

#pragma mark - Manage buttons
- (IBAction)backButton:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:TRUE completion:Nil];
}


- (IBAction)previousKPI:(UIBarButtonItem *)sender {

    [self.datasource moveToPreviousKPI];
    
    [self resyncWithNewKPI];

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


- (IBAction)nextKPI:(UIBarButtonItem *)sender {
    
    [self.datasource moveToNextKPI];

    [self resyncWithNewKPI];

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
- (IBAction)sendMail:(UIBarButtonItem *)sender {
    
    KPI* theKPI = [self.datasource getKPI];
    
    MailCellDetailedKPI* mailbody = [[MailCellDetailedKPI alloc] init:self.theCell
                                                                  KPI:theKPI
                                                            KPIValues:[self.datasource getKPIValues]
                                                     monitoringPeriod:[self.datasource getMonitoringPeriod]
                                                          requestDate:self.dateOfKPIsValues];
    
    [mailbody setGraphImageAttachment:self.theChart.barChart title:theKPI.name];
    if (theKPI.theRelatedKPI != Nil) {
        mailbody.relatedKPIValues = [self.datasource getKPIValuesOf:theKPI.theRelatedKPI];
    }

    [self opendMail:sender mail:mailbody];
}


- (void) opendMail:(UIBarButtonItem *)sender mail:(MailAbstract*) theMail {
    
    [theMail presentActivityViewFrom:self];
    
}

-(void) resetHiddenViewChartCoordinate {
    UIView* hiddenView = [self hiddenViewChart];
    hiddenView.hidden = FALSE;
    CGRect hiddenViewFrameTarget = hiddenView.frame;
    hiddenViewFrameTarget.origin.x = 0;
    hiddenView.frame = hiddenViewFrameTarget;
}


- (IBAction)swipeToNextMonitoringPeriod:(UISwipeGestureRecognizer *)sender {

    UIView* displayedView = [self displayedViewChart];
    CGRect displayedViewFrameTarget = [self moveDisplayedViewFromLeft:FALSE];
    
    UIView* hiddenView = [self hiddenViewChart];
    CGRect hiddenViewFrame = [self moveHiddenViewFromLeft:FALSE];

    [self.datasource moveToNextMonitoringPeriod];
    [self updateChartWithMonitoringPeriod];
    
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


- (IBAction)swipeToPreviousMonitoringPeriod:(UISwipeGestureRecognizer *)sender {
    UIView* displayedView = [self displayedViewChart];
    CGRect displayedViewFrameTarget = [self moveDisplayedViewFromLeft:TRUE];
    
    UIView* hiddenView = [self hiddenViewChart];

    CGRect hiddenViewFrame = [self moveHiddenViewFromLeft:TRUE];
    
    [self.datasource moveToPreviousMonitoringPeriod];
    [self updateChartWithMonitoringPeriod];

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

-(CPTGraphHostingView *) displayedViewChart {
    return self.displayingPrimary ? self.theGraph : self.theSecondGraph;
}

-(CPTGraphHostingView *) hiddenViewChart {
    return !self.displayingPrimary ? self.theGraph : self.theSecondGraph;
}



#pragma mark - Others
- (void) updateChartWithMonitoringPeriod {
    
    // We don't display the time if not 15mn or hourly GP so the cell size is smaller
    if (([self.datasource getMonitoringPeriod] == last6Hours15MnView) ||
        ([self.datasource getMonitoringPeriod] == last24HoursHourlyView)) {
        self.theKPITable.rowHeight = [self getRowHeightForDetailedView];
    } else {
    //    self.theKPITable.rowHeight = [self getRowHeightForSimpleView];
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.theKPITable.estimatedRowHeight = [self getRowHeightForSimpleView];
    }
    
    // update the content of the table
    [self.theKPITable reloadData];
    [self.theKPITable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:TRUE];
    
    if (([self.datasource getMonitoringPeriod] == last6Hours15MnView) ||
        ([self.datasource getMonitoringPeriod] == last24HoursHourlyView)) {
        self.enableInfoPanel = TRUE;
    } else {
        self.enableInfoPanel = FALSE;
    }
    
    
    [self displayChart:FALSE];
    
}

- (float) getRowHeightForDetailedView {
    return 79.0;
}

- (float) getRowHeightForSimpleView {
    return 48.0;
}



- (void) resyncWithNewKPI {
    
    // update the content of the table
    [self.theKPITable reloadData];
    
    if ([self.datasource getKPIValues].count > 0) {
        [self.theKPITable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:TRUE];
    }

    // re-initialize the graph and update it
    [self displayChart:FALSE];
}

#pragma mark - Initialization

- (void) initialize:(CellKPIsDataSource*) cellDatasource initialMonitoringPeriod:(DCMonitoringPeriodView) monitoringPeriod initialIndex:(NSIndexPath*) index {
    _datasource = [[CellKPIDatasource alloc] init:cellDatasource initialMonitoringPeriod:monitoringPeriod initialIndex:index];

    self.theCell = cellDatasource.theCell;
    self.dateOfKPIsValues = cellDatasource.requestDate;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad {
    [self showToolbar];

    self.title = self.theCell.id;
    
    self.displayingPrimary = FALSE;
    
    
    self.theKPITable.delegate = self;
    self.theKPITable.dataSource = self;
    if (([self.datasource getMonitoringPeriod] == last6Hours15MnView) ||
        ([self.datasource getMonitoringPeriod] == last24HoursHourlyView)) {
        self.theKPITable.estimatedRowHeight = 78.0;
    } else {
        self.theKPITable.estimatedRowHeight = 48;
    }
    self.theKPITable.rowHeight = UITableViewAutomaticDimension;

    [self displayChart:TRUE];
    
    self.displayingPrimary = TRUE;
    
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    [self initializeConstraintsForOrientation:orientation];

    
    // We don't display the time if not 15mn or hourly GP so the cell size is smaller
    if (([self.datasource getMonitoringPeriod] == last6Hours15MnView) ||
        ([self.datasource getMonitoringPeriod] == last24HoursHourlyView)) {
        self.theKPITable.rowHeight = [self getRowHeightForDetailedView];
    } else {
     //   self.theKPITable.rowHeight = [self getRowHeightForSimpleView];
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.theKPITable.estimatedRowHeight = [self getRowHeightForSimpleView];
    }

	// Do any additional setup after loading the view.
    
    [super viewDidLoad];
    
    [[UserHelp sharedInstance] helpForGenericGraphicKPI:self];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self showToolbar];
}

-(void) showToolbar {
    [self.navigationController setToolbarHidden:FALSE animated:FALSE];
    self.navigationController.hidesBarsOnSwipe = FALSE;
    self.navigationController.hidesBarsOnTap = FALSE;
}


- (void) initializeConstraintsForOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        CGFloat heightPercentage = 0.0f;
        
        if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
            (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
            heightPercentage = 1.0f;
            self.theToolbar.hidden = TRUE;
        } else {
            heightPercentage = 0.45f;
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
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self initializeConstraintsForOrientation:toInterfaceOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Manage TableView
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return [MonitoringPeriodUtility getStringForMonitoringPeriod:[self.datasource getMonitoringPeriod]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.datasource getKPIValues].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (([self.datasource getMonitoringPeriod] == last6Hours15MnView) ||
        ([self.datasource getMonitoringPeriod] == last24HoursHourlyView)) {
        return [self configureDetailsCell:indexPath];
    } else {
        return [self configureDetailsCellPeriod:indexPath];
    }
     
}

// Display cell for hourly or 15mn GP
- (UITableViewCell*) configureDetailsCell:(NSIndexPath*) indexPath {
    static NSString *CellIdentifier = @"CellKPIHourlyValueId";
    
    CellDetailsCellKPIViewCell *cell = [self.theKPITable dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == Nil) {
        cell = [[CellDetailsCellKPIViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier]; 
    }
    
    cell.dateLocalTime.text = [DateUtility configureTimeDetailsCell:self.dateOfKPIsValues row:indexPath.row monitoringPeriod:[self.datasource getMonitoringPeriod]];
    cell.dateCellLocalTime.text = [DateUtility configureTimeDetailsCellWithTimezone:self.dateOfKPIsValues timezone:self.theCell.theTimezone row:indexPath.row monitoringPeriod:[self.datasource getMonitoringPeriod]];
    
    KPI* theKPI = [self.datasource getKPI];
    KPI* theRelatedKPI = theKPI.theRelatedKPI;
    NSArray* theKPIValues = [self.datasource getKPIValues];
    if (theRelatedKPI != Nil) {
        NSArray* relatedKPIValues = [self.datasource getKPIValuesOf:theRelatedKPI];
        
        NSString* theKPIValue = [theKPI getDisplayableValueFromNumber:theKPIValues[indexPath.row]];
        NSString* theRelatedKPIValue = [theRelatedKPI getDisplayableValueFromNumber:relatedKPIValues[indexPath.row]];
        
        cell.kpiValue.text = [NSString stringWithFormat:@"%@ vs %@",theKPIValue, theRelatedKPIValue];
    } else {
        cell.kpiValue.text = [theKPI getDisplayableValueFromNumber:theKPIValues[indexPath.row]];
    }

    cell.backgroundColor = [theKPI getBackgroundColorValueFromNumber:theKPIValues[indexPath.row]];
    
    return cell;
}


// Configure cell content but without time infos because for daily, weekly...
- (UITableViewCell*) configureDetailsCellPeriod:(NSIndexPath*) indexPath {
    static NSString *CellPeriodIdentifier = @"CellKPIPeriodValueId";

    CellDetailsPeriodCellKPIViewCell *cell = [self.theKPITable dequeueReusableCellWithIdentifier:CellPeriodIdentifier];
    if (cell == Nil) {
        cell = [[CellDetailsPeriodCellKPIViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellPeriodIdentifier]; 
    }

    cell.period.text = [DateUtility configureTimeDetailsCellPeriod:self.dateOfKPIsValues
                                                               row:indexPath.row
                                                  monitoringPeriod:[self.datasource getMonitoringPeriod]];
    
    KPI* theKPI = [self.datasource getKPI];
    KPI* theRelatedKPI = theKPI.theRelatedKPI;
    NSArray* theKPIValues = [self.datasource getKPIValues];
    if (theRelatedKPI != Nil) {
        NSArray* relatedKPIValues = [self.datasource getKPIValuesOf:theRelatedKPI];
        
        NSString* theKPIValue = [theKPI getDisplayableValueFromNumber:theKPIValues[indexPath.row]];
        NSString* theRelatedKPIValue = [theRelatedKPI getDisplayableValueFromNumber:relatedKPIValues[indexPath.row]];
        
        cell.kpiValue.text = [NSString stringWithFormat:@"%@ vs %@",theKPIValue, theRelatedKPIValue];
    } else {
        cell.kpiValue.text = [theKPI getDisplayableValueFromNumber:theKPIValues[indexPath.row]];
    }
    
    cell.backgroundColor = [theKPI getBackgroundColorValueFromNumber:theKPIValues[indexPath.row]];

    return cell;
}

#pragma mark - CPTPlotDataSource Protocol 

-(void) displayChart:(Boolean) animate {

    KPI* theKPI = [self.datasource getKPI];
    
    self.thePreviousChart = self.theChart; // keep a reference to avoid Exec exceptions when switching from on chart to another
    [self.thePreviousChart unregisterDelegates];
    
    self.theChart = [[KPIBarChart alloc] init:[self.datasource getKPIValues]
                                          KPI:theKPI
                                         date:self.dateOfKPIsValues
                             monitoringPeriod:[self.datasource getMonitoringPeriod]];
    
    [self customizeChartDisplayProperties:self.theChart];

    self.theChart.subscriber = self;
    self.theChart.fillWithGradient = [UserPreferences sharedInstance].isCellKPIDetailsGradiant;
    
    KPI* theRelatedKPI = theKPI.theRelatedKPI;
    if (theRelatedKPI != Nil) {
        NSArray* relatedKPIValues = [self.datasource getKPIValuesOf:theRelatedKPI];
        [self.theChart setRelatedKPI:theRelatedKPI KPIValues:relatedKPIValues];
    }
    
    CPTGraphHostingView *hostingView = [self hiddenViewChart];
    [self.theChart displayChart:hostingView withAnimate:animate];
}

-(void) customizeChartDisplayProperties:(KPIBarChart*) theChart {
    theChart.yTitleDisplacement = -5.0f;
    theChart.titleFontSize = 10.0f;
    theChart.xAxisFontSize = 12.0f;
    theChart.yAxisFontSize = 12.0f;
}


-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


#pragma mark - KNPathTableViewController customization
- (UITableView*) tableView {
    return self.theKPITable;
}

#warning SEB:check why KNPath doesn't display correctly when moving from day period to hourly perid
-(void)infoPanelDidScroll:(UIScrollView *)scrollView atPoint:(CGPoint)point {
    NSIndexPath * indexPath = [self.theKPITable indexPathForRowAtPoint:point];
    
    self.infoLabel.text = [self buildFinalStartDate:indexPath.row];
}

- (float) maxWidthInfoLabel {
    
    UIFont* theFont = [UIFont boldSystemFontOfSize:12];
    NSDictionary* myDico = @{NSFontAttributeName : theFont};
    
    CGSize initSize = CGSizeMake(10.0, 2.0);
    NSStringDrawingContext* drawingContext = [[NSStringDrawingContext alloc] init];
    
    float maxWidth = 0.0;
    
    for (NSUInteger i = 0; i < [self.theKPITable numberOfRowsInSection:0]; i++) {
        
        NSString* startDate = [self buildFinalStartDate:i];
        
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:startDate attributes:myDico];
        CGRect rect = [attrString boundingRectWithSize:initSize options:NSStringDrawingUsesDeviceMetrics context:drawingContext];
        
        maxWidth = rect.size.width > maxWidth ? rect.size.width : maxWidth;
    }
    
    return ceil(maxWidth);
}

- (NSString*) buildFinalStartDate:(NSUInteger) index {
    if (([self.datasource getMonitoringPeriod] == last6Hours15MnView) ||
        ([self.datasource getMonitoringPeriod] == last24HoursHourlyView)) {
        double durationToRemove;
        double durationToRemoveForEnd;
        DateDisplayOptions displayMinute = withHH00;
        
        NSDate* sourceDate = self.dateOfKPIsValues;
        
        if ([self.datasource getMonitoringPeriod] == last6Hours15MnView) {
            durationToRemove = ((24 - index) * 15.0) * 60.0; // duration to substract in second from the orginal date
            durationToRemoveForEnd = 15*60; // Adding 15 minutes
            sourceDate = [DateUtility getDateNear15mn:self.dateOfKPIsValues];
            displayMinute = withHHmm;
        } else {
            durationToRemove = ((24 - index) * 60.0) * 60.0; // duration to substract in second from the orginal date
            durationToRemoveForEnd = 3600; // adding 1 hour
            displayMinute = withHH00;
        }
        
        NSDate* from = [sourceDate dateByAddingTimeInterval:-durationToRemove];
        NSString* startDate = [DateUtility getDate:from option:displayMinute];
        
        if ([self.theCell hasTimezone]) {
            NSString* localStartDate = [DateUtility getDateWithRealTimeZone:from timezone:self.theCell.theTimezone option:displayMinute];
            return [NSString stringWithFormat:@"%@", localStartDate];
        } else {
            return [NSString stringWithFormat:@"%@ (LT)", startDate];
        }
        
        
    } else {
        return @"";
    }

}




@end
