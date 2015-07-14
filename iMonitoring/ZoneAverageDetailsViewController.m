//
//  ZoneAverageDetailsViewController.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 26/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ZoneAverageDetailsViewController.h"
#import "DataCenter.h"
#import "ZoneAverageDetailsCell.h"
#import "ZoneAveragePeriodDetailsCell.h"
#import "KPI.h"
#import "KPIBarChart.h"
#import "DataCenter.h"
#import "DateUtility.h"
#import "WorstKPIDataSource.h"
#import "MailZoneKPIDetails.h"
#import "UserPreferences.h"
#import "ZoneKPISource.h"

@interface ZoneAverageDetailsViewController ()

@property(nonatomic) KPIBarChart* theChart;
@property(nonatomic) KPIBarChart* thePreviousChart;

@property(nonatomic) NSDate* requestDate;
@property(nonatomic) Boolean displayingPrimary;
@property(nonatomic) NSString* timezone;
@property(nonatomic) ZoneKPISource* dataSource;

@property(nonatomic) NSLayoutConstraint* addedConstraint;


@end

@implementation ZoneAverageDetailsViewController
@synthesize theTable;
@synthesize FirstChart;
@synthesize SecondChart;

#pragma mark - barChartNotification protocol
- (void) selectedBar:(NSUInteger) index {
    [theTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:TRUE];
}

#pragma mark - Manage buttons

- (IBAction)goToNextKPI:(UIBarButtonItem *)sender {
    [self.dataSource moveToNextZoneKPI];
    [self resyncAndDisplayWithNewKPI];
}

- (IBAction)goToPreviousKPI:(UIBarButtonItem *)sender {
    [self.dataSource moveToPreviousZoneKPI];
    [self resyncAndDisplayWithNewKPI];
}

#pragma mark - Manage buttons
- (IBAction)sendMail:(UIBarButtonItem *)sender {
    // build the mail body that contains cell info and values for all KPIs
    MailZoneKPIDetails* mailbody = [[MailZoneKPIDetails alloc] init:_dataSource];
    [mailbody setGraphImageAttachment:self.theChart.barChart title:[_dataSource getZoneKPI].name];

    [self openMail:sender mail:mailbody];
}

- (void) openMail:(UIBarButtonItem *)sender mail:(MailAbstract*) theMail {
    [theMail presentActivityViewFrom:self];
}

- (void) resyncAndDisplayWithNewKPI {
    [self displayChart:FALSE];

    [UIView transitionFromView:(_displayingPrimary ? self.FirstChart : self.SecondChart)
                        toView:(_displayingPrimary ? self.SecondChart : self.FirstChart)
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionShowHideTransitionViews
                    completion:^(BOOL finished) {
                        if (finished) {
                            _displayingPrimary = !_displayingPrimary;
                        }
                    }];
    
    [theTable reloadData];
    [theTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:TRUE];
}

- (void) displayChart:(Boolean) animate {
    CPTGraphHostingView *hostingView = Nil;
    if (_displayingPrimary == FALSE) {
        hostingView = self.FirstChart;
    } else {
        hostingView = self.SecondChart;
    }

    MonitoringPeriodUtility* dc = [MonitoringPeriodUtility sharedInstance];
    
    self.thePreviousChart = self.theChart; // keep a reference to avoid Exec exceptions when switching from one chart to another
    [self.thePreviousChart unregisterDelegates];
    
    self.theChart = [[KPIBarChart alloc] init:[_dataSource getZoneKPIValues] KPI:[_dataSource getZoneKPI] date:_requestDate  monitoringPeriod:dc.monitoringPeriod ];
    
    
    self.theChart.yTitleDisplacement = -5.0f;
    self.theChart.titleFontSize = 14.0f;
    self.theChart.xAxisFontSize = 12.0f;
    self.theChart.yAxisFontSize = 12.0f;
    self.theChart.subscriber = self;
    self.theChart.fillWithGradient = [UserPreferences sharedInstance].isZoneKPIDetailsGradiant;

    [self.theChart displayChart:hostingView withAnimate:animate];
}

#pragma mark - Initializations

- (void) initialize:(WorstKPIDataSource*) theDatasource initialIndex:(NSUInteger) index {
    
    _dataSource = [[ZoneKPISource alloc] init:theDatasource initialIndex:index];
    _requestDate = theDatasource.requestDate;
    _timezone = theDatasource.timezone;
}

- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];
 }

- (void)viewDidLoad
{
    [self showToolbar];
    
    _displayingPrimary = FALSE;
    theTable.delegate = self;
    theTable.dataSource = self;

    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    [self initializeConstraintsForOrientation:orientation];

    [self displayChart:TRUE];

    [super viewDidLoad];
  
    DCMonitoringPeriodView monitoringPeriodView = [[MonitoringPeriodUtility sharedInstance] monitoringPeriod];
    if ((monitoringPeriodView != last6Hours15MnView) &&
        (monitoringPeriodView != last24HoursHourlyView)) {
        self.enableInfoPanel = FALSE;
    }
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
          //  self.navigationController.theToolbar.hidden = TRUE;
          //  [self.navigationController setToolbarHidden:TRUE];
        } else {
            heightPercentage = 0.40f;
         //   self.theToolbar.hidden = FALSE;
         //   [self.navigationController setToolbarHidden:FALSE];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view 
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    MonitoringPeriodUtility* dc = [MonitoringPeriodUtility sharedInstance];
    return [MonitoringPeriodUtility getStringForGranularityPeriodDuration:dc.monitoringPeriod];  
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataSource getZoneKPIValues].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    DCMonitoringPeriodView monitoringPeriodView = [[MonitoringPeriodUtility sharedInstance] monitoringPeriod];
    if ((monitoringPeriodView == last6Hours15MnView) ||
        (monitoringPeriodView == last24HoursHourlyView)) {
        return [self configureDetailsCell:indexPath];
    } else {
        return [self configureDetailsCellPeriod:indexPath];
    }

    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DCMonitoringPeriodView monitoringPeriodView = [[MonitoringPeriodUtility sharedInstance] monitoringPeriod];
    if ((monitoringPeriodView == last6Hours15MnView) ||
        (monitoringPeriodView == last24HoursHourlyView)) {
        return 60.0;
    } else {
        return 32.0;
    }
  
}

- (UITableViewCell *) configureDetailsCell:(NSIndexPath*) indexPath {
    // 
    static NSString *CellIdentifier = @"ZoneAverageEvolutionId";
    ZoneAverageDetailsCell *cell = [theTable dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == Nil) {
        cell = [[ZoneAverageDetailsCell alloc] init]; 
    }
    
    NSArray* theValues = [_dataSource getZoneKPIValues];
    NSNumber* KPIValue = theValues[indexPath.row];

    KPI* theKPI = [_dataSource getZoneKPI];

    cell.KPIValue.text = [theKPI getDisplayableValueFromNumber:KPIValue];

    cell.backgroundColor = [theKPI getBackgroundColorValueFromNumber:KPIValue];
    
    cell.dateCellLocalTime.text = [DateUtility configureTimeDetailsCellWithTimezone:self.requestDate
                                                                           timezone:self.timezone
                                                                                row:indexPath.row
                                                                   monitoringPeriod:[[MonitoringPeriodUtility sharedInstance] monitoringPeriod]];
    cell.dateLocalTime.text = [DateUtility configureTimeDetailsCell:self.requestDate
                                                                row:indexPath.row
                                                   monitoringPeriod:[[MonitoringPeriodUtility sharedInstance] monitoringPeriod]];

    return cell;
  
}

- (UITableViewCell *) configureDetailsCellPeriod:(NSIndexPath*) indexPath {
    // 
    static NSString *CellIdentifier = @"ZoneAveragePeriodDetailsCellId";
    ZoneAveragePeriodDetailsCell *cell = [theTable dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == Nil) {
        cell = [[ZoneAveragePeriodDetailsCell alloc] init]; 
    }
    
    NSArray* theValues = [_dataSource getZoneKPIValues];
    NSNumber* KPIValue = theValues[indexPath.row];

    KPI* theKPI = [_dataSource getZoneKPI];
    
    
    cell.kpiValue.text = [theKPI getDisplayableValueFromNumber:KPIValue];
    cell.period.text = [DateUtility configureTimeDetailsCellPeriod:self.requestDate
                                                               row:indexPath.row
                                                  monitoringPeriod:[[MonitoringPeriodUtility sharedInstance] monitoringPeriod]];
    
    cell.backgroundColor = [theKPI getBackgroundColorValueFromNumber:KPIValue];

    return cell;
}


#pragma mark - KNPathTableViewController customization

- (UITableView*) tableView {
    return self.theTable;
}



-(void)infoPanelDidScroll:(UIScrollView *)scrollView atPoint:(CGPoint)point {
    NSIndexPath * indexPath = [self.theTable indexPathForRowAtPoint:point];
    
    self.infoLabel.text = [self buildFinalStartDate:indexPath.row];
}


- (float) maxWidthInfoLabel {
    float maxWidth = 0.0;
    
    UIFont* theFont = [UIFont boldSystemFontOfSize:12];
    NSDictionary* myDico = @{NSFontAttributeName : theFont};
    CGSize initSize = CGSizeMake(10.0, 2.0);

    for (NSUInteger i = 0; i < [self.theTable numberOfRowsInSection:0]; i++) {
        // Specific for this class
        NSString* finalDateString = [self buildFinalStartDate:i];
        
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:finalDateString attributes:myDico];
        
        NSStringDrawingContext* drawingContext = [[NSStringDrawingContext alloc] init];
        
        CGRect rect = [attrString boundingRectWithSize:initSize options:NSStringDrawingUsesDeviceMetrics context:drawingContext];
        
        maxWidth = rect.size.width > maxWidth ? rect.size.width : maxWidth;
    }    
    
    return ceil(maxWidth);
}

- (NSString*) buildFinalStartDate:(NSUInteger) index {
    double durationToRemove;
    double durationToRemoveForEnd;
    DateDisplayOptions displayMinute = withHH00;

    NSDate* sourceDate = _requestDate;
    
    DCMonitoringPeriodView monitoringPeriodView = [[MonitoringPeriodUtility sharedInstance] monitoringPeriod];
    
    if (monitoringPeriodView == last6Hours15MnView) {
        durationToRemove = ((24 - index) * 15.0) * 60.0; // duration to substract in second from the orginal date
        durationToRemoveForEnd = 15*60; // Adding 15 minutes
        sourceDate = [DateUtility getDateNear15mn:_requestDate];
        displayMinute = withHHmm;
    } else {
        durationToRemove = ((24 - index) * 60.0) * 60.0; // duration to substract in second from the orginal date
        durationToRemoveForEnd = 3600; // adding 1 hour
        displayMinute = withHH00;
    }
    
    NSDate* from = [sourceDate dateByAddingTimeInterval:-durationToRemove];
    // adding duration of Monitoring Period
    NSString* startDate = [DateUtility getDate:from option:displayMinute];
    
    NSString* finalDateString = Nil;
    if (_timezone != nil) {
        NSString* localStartDate = [DateUtility getDateWithTimeZone:from timezone:_timezone option:displayMinute];
        finalDateString = [NSString stringWithFormat:@"%@", localStartDate];
    } else {
        finalDateString = [NSString stringWithFormat:@"%@ (LT)", startDate];
    }

    return finalDateString;
}


@end
