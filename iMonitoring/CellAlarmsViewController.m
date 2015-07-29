//
//  CellAlarmsViewController.m
//  iMonitoring
//
//  Created by sébastien brugalières on 04/09/13.
//
//

#import "CellAlarmsViewController.h"
#import "AlarmViewCell.h"
#import "RequestUtilities.h"
#import "CellAlarm.h"
#import "CellAlarmDatasource.h"
#import "MailCellAlarms.h"
#import "DateUtility.h"

@interface CellAlarmsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *theTable;
@property (weak, nonatomic) IBOutlet UISegmentedControl *theSwitch;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *theActivityButton; // only for iPad
@property (nonatomic) UIPopoverController* theActivityPopover;

@property (nonatomic) UIRefreshControl* refreshControl;
@property (nonatomic, readonly) NSArray* cellAlarms;

@end

@implementation CellAlarmsViewController


#pragma mark - CellAlarmListener Callbacks

- (void) alarmLoadingFailure {
    [self.refreshControl endRefreshing];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Communication failure" message:@"Alarms cannot be loaded" delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alert show];
}
- (void) alarmLoaded {
    [self.theTable reloadData];
    [self.refreshControl endRefreshing];
}

#pragma mark - Initialization


- (void)viewDidLoad
{
    [self showToolbar];

    
    self.theTable.delegate = self;
    self.theTable.dataSource = self;
    self.title = [NSString stringWithFormat:@"%@", self.alarmDatasource.theCell.id];
	// Do any additional setup after loading the view.
    
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.theTable;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reloadAlarms) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
    
    [self.alarmDatasource subscribe:self];
    
    [super viewDidLoad];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self showToolbar];
}

-(void) showToolbar {
    [self.navigationController setToolbarHidden:FALSE animated:FALSE];
    self.navigationController.hidesBarsOnSwipe = TRUE;
    self.navigationController.hidesBarsOnTap = FALSE;
}


-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // whatever the reason of the view disapearing we can unsubscribe
    [self.alarmDatasource unsubscribe:self];
}

- (void)reloadAlarms {
    [self.alarmDatasource loadAlarms];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)sendMail:(UIBarButtonItem *)sender {
    MailCellAlarms* mailbody = [[MailCellAlarms alloc] init:self.alarmDatasource.theCell alarms:self.alarmDatasource.alarmsOrderedByDate];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [mailbody presentActivityViewFrom:self];
    } else {
        self.theActivityPopover = [mailbody presentActivityViewFromPopover:self.theActivityButton];
    }
}


- (IBAction)switchButtonPushed:(UISegmentedControl *)sender {
    [self.theTable reloadData];
    [self.theTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:TRUE];
}

- (NSArray*) cellAlarms {
    if (self.theSwitch.selectedSegmentIndex == 0) {
        return self.alarmDatasource.alarmsOrderedBySeverity;
    } else {
        return self.alarmDatasource.alarmsOrderedByDate;
    }
}


#pragma mark - Table view data source



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellAlarms.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellParamId = @"AlarmCellId";
    AlarmViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellParamId];
    
    if (cell == Nil) {
        cell = [[AlarmViewCell alloc] init];
        
    }
    
    [cell initializeWithAlarm:self.cellAlarms[indexPath.row] cell:self.alarmDatasource.theCell];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - KNPathTableViewController customization
- (UITableView*) tableView {
    return self.theTable;
}

-(void)infoPanelDidScroll:(UIScrollView *)scrollView atPoint:(CGPoint)point {
    NSIndexPath * indexPath = [self.theTable indexPathForRowAtPoint:point];
    
    CellAlarm* theAlarm = self.cellAlarms[indexPath.row];
    
    if (self.theSwitch.selectedSegmentIndex == 0) {
        self.infoLabel.text = theAlarm.severityString;
    } else {
        self.infoLabel.text = [theAlarm getAlarmDate:self.alarmDatasource.theCell];
    }
    
}

- (float) maxWidthInfoLabel {
    
    NSString* datePattern;
    // The longest string will be the alarm date
    if (self.alarmDatasource.theCell.hasTimezone) {
        datePattern = @"2013-01-01 23:59:59";
    } else {
        datePattern = @"2013-01-01 23:59:59 (LT)";
    }
    
    UIFont* theFont = [UIFont boldSystemFontOfSize:12];
    NSDictionary* myDico = @{NSFontAttributeName : theFont};
    CGSize initSize = CGSizeMake(10.0, 2.0);
   
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:datePattern attributes:myDico];
    
    NSStringDrawingContext* drawingContext = [[NSStringDrawingContext alloc] init];
    
    CGRect rect = [attrString boundingRectWithSize:initSize options:NSStringDrawingUsesDeviceMetrics context:drawingContext];
    
    return ceil(rect.size.width);
    
}


@end
