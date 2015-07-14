//
//  CellDetailsKPIWindowController.m
//  iMonitoring
//
//  Created by sébastien brugalières on 16/01/2014.
//
//

#import "CellDetailsKPIWindowController.h"
#import "CellKPIsDataSource.h"
#import "KPIBarChart.h"
#import "CellKPIDatasource.h"
#import "UserPreferences.h"
#import "KPI.h"
#import "CellDetailsKPICellWindow.h"
#import "CellDetailsKPIPeriodCellWindow.h"
#import "DateUtility.h"
#import "CellMonitoring.h"
#import "MainMapWindowController.h"

@interface CellDetailsKPIWindowController ()

@property (weak) IBOutlet NSTableView *theKPITableView;
@property (weak) IBOutlet CPTGraphHostingView *hostingGraph;

@property (nonatomic) KPIBarChart* theChart;

@property (nonatomic) CellKPIDatasource* datasource;

@property (nonatomic) NSDate* dateOfKPIs;
@property (nonatomic) CellMonitoring* theCell;

@end

@implementation CellDetailsKPIWindowController

- (id)init:(CellKPIsDataSource*) cellDatasource
        initialIndex:(NSIndexPath*) index
        initialMonitoringPeriod:(DCMonitoringPeriodView) monitoringPeriod;
{
    self = [super initWithWindowNibName:@"CellDetailsKPIWindow"];
    
    
    _dateOfKPIs = cellDatasource.requestDate;
    _theCell = cellDatasource.theCell;
    
    _datasource = [[CellKPIDatasource alloc] init:cellDatasource initialMonitoringPeriod:monitoringPeriod initialIndex:index];
    
    return self;
}


- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.window setLevel: NSStatusWindowLevel];
    
    NSString* periodTitle = [MonitoringPeriodUtility getStringForMonitoringPeriod:[self.datasource getMonitoringPeriod]];
    
    NSString* fullTitle = [NSString stringWithFormat:@"%@ / %@" , self.theCell.id, periodTitle];
    
    [self.window setTitle:fullTitle];
    
    NSArray* tableColumns = self.theKPITableView.tableColumns;
    NSTableColumn* firstColumn = tableColumns[0];
    [[firstColumn headerCell] setStringValue:periodTitle];
    
    [self displayChart:TRUE];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


- (IBAction)previousButtonPushed:(NSButton *)sender {
    [self.datasource moveToPreviousKPI];
    
    [self resyncWithNewKPI];

}
- (IBAction)nextButtonPushed:(NSButton *)sender {
    [self.datasource moveToNextKPI];
    
    [self resyncWithNewKPI];

}
- (IBAction)showOnMapButtonPushed:(NSButton *)sender {
    [[MainMapWindowController sharedInstance] showSelectedCellOnMap:self.theCell];
}

- (void) resyncWithNewKPI {
    // update the content of the table
    [self.theKPITableView reloadData];
    
    [self.theKPITableView scrollRowToVisible:0];

    [self displayChart:FALSE];
}


-(void) displayChart:(Boolean) animate {
    
    self.theChart = [[KPIBarChart alloc] init:[self.datasource getKPIValues]
                                          KPI:[self.datasource getKPI]
                                         date:self.dateOfKPIs
                             monitoringPeriod:[self.datasource getMonitoringPeriod]];
    self.theChart.yTitleDisplacement = -5.0f;
    self.theChart.titleFontSize = 14.0f;
    self.theChart.titleWithKPIDomain = TRUE;
    self.theChart.subscriber = self;
    self.theChart.fillWithGradient = [UserPreferences sharedInstance].isCellKPIDetailsGradiant;
    
    KPI* theRelatedKPI = [self.datasource getKPI].theRelatedKPI;
    if (theRelatedKPI != Nil) {
        NSArray* relatedKPIValues = [self.datasource getKPIValuesOf:theRelatedKPI];
        [self.theChart setRelatedKPI:theRelatedKPI KPIValues:relatedKPIValues];
    }
    
    [self.theChart displayChart:self.hostingGraph withAnimate:animate];
}

#pragma mark - barChartNotification protocol
- (void) selectedBar:(NSUInteger) index {
    [self.theKPITableView scrollRowToVisible:index];
}

#pragma mark - NSTableViewDataSource

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    
    if (([self.datasource getMonitoringPeriod] == last6Hours15MnView) ||
        ([self.datasource getMonitoringPeriod] == last24HoursHourlyView)) {
        return 53;
    } else {
        return 43;
    }
  
}
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.datasource getKPIValues].count;
    
}

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
    [rowView setBackgroundColor:[[self.datasource getKPI] getBackgroundColorValueFromNumber:[self.datasource getKPIValues][row]]];
}

// This method is optional if you use bindings to provide the data
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    
    if (([self.datasource getMonitoringPeriod] == last6Hours15MnView) ||
        ([self.datasource getMonitoringPeriod] == last24HoursHourlyView)) {
        return [self configureDetailsCell:row tableView:tableView];
    } else {
        return [self configureDetailsCellPeriod:row tableView:tableView];
    }
}

- (CellDetailsKPICellWindow*) configureDetailsCell:(NSUInteger) row tableView:(NSTableView *)tableView {
   
    CellDetailsKPICellWindow *cellView = [tableView makeViewWithIdentifier:@"CellDetails" owner:self];
   
    cellView.dateInCellTimezone.stringValue = [DateUtility configureTimeDetailsCellWithTimezone:self.dateOfKPIs
                                                                                       timezone:self.theCell.timezone
                                                                                            row:row
                                                                               monitoringPeriod:[self.datasource getMonitoringPeriod]];

    cellView.dateInLocalTime.stringValue = [DateUtility configureTimeDetailsCell:self.dateOfKPIs
                                                                             row:row
                                                                monitoringPeriod:[self.datasource getMonitoringPeriod]];
    
    KPI* theRelatedKPI = [self.datasource getKPI].theRelatedKPI;
    if (theRelatedKPI != Nil) {
        NSArray* relatedKPIValues = [self.datasource getKPIValuesOf:theRelatedKPI];
        
        NSString* theKPIValue = [[self.datasource getKPI] getDisplayableValueFromNumber:[self.datasource getKPIValues][row]];
        NSString* theRelatedKPIValue = [theRelatedKPI getDisplayableValueFromNumber:relatedKPIValues[row]];
        
        cellView.KPIValue.stringValue = [NSString stringWithFormat:@"%@ vs %@",theKPIValue, theRelatedKPIValue];
        
    } else {
        cellView.KPIValue.stringValue = [[self.datasource getKPI] getDisplayableValueFromNumber:[self.datasource getKPIValues][row]];
    }
    
    cellView.severity.backgroundColor = [[self.datasource getKPI] getColorValueFromNumber:[self.datasource getKPIValues][row]];
    
    return cellView;
}

// Configure cell content but without time infos because for daily, weekly...
- (CellDetailsKPIPeriodCellWindow*) configureDetailsCellPeriod:(NSUInteger) row tableView:(NSTableView *)tableView  {
    
    CellDetailsKPIPeriodCellWindow *cellView = [tableView makeViewWithIdentifier:@"CellPeriod" owner:self];

    cellView.dateInLocalTime.stringValue = [DateUtility configureTimeDetailsCellPeriod:self.dateOfKPIs row:row monitoringPeriod:[self.datasource getMonitoringPeriod]];
    
    
    KPI* theRelatedKPI = [self.datasource getKPI].theRelatedKPI;
    if (theRelatedKPI != Nil) {
        NSArray* relatedKPIValues = [self.datasource getKPIValuesOf:theRelatedKPI];
        
        NSString* theKPIValue = [[self.datasource getKPI] getDisplayableValueFromNumber:[self.datasource getKPIValues][row]];
        NSString* theRelatedKPIValue = [theRelatedKPI getDisplayableValueFromNumber:relatedKPIValues[row]];
        
        cellView.KPIValue.stringValue = [NSString stringWithFormat:@"%@ vs %@",theKPIValue, theRelatedKPIValue];
    } else {
        cellView.KPIValue.stringValue = [[self.datasource getKPI] getDisplayableValueFromNumber:[self.datasource getKPIValues][row]];
    }
    
    cellView.severity.backgroundColor = [[self.datasource getKPI] getColorValueFromNumber:[self.datasource getKPIValues][row]];
    
    return cellView;
}


@end
