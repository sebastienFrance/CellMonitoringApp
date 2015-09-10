//
//  ZoneAverageDetailsWindowController.m
//  iMonitoring
//
//  Created by sébastien brugalières on 09/01/2014.
//
//

#import "ZoneAverageDetailsWindowController.h"
#import "ZoneKPIDataSource.h"
#import "UserPreferences.h"
#import "DateUtility.h"
#import "ZoneAverageDetailsCellWindow.h"
#import "ZoneKPISource.h"
#import "WorstKPIDataSource.h"

@interface ZoneAverageDetailsWindowController()

@property (nonatomic, weak) IBOutlet CPTGraphHostingView *hostView;
@property (weak) IBOutlet NSTableView *theKPITable;


@property(nonatomic) KPIBarChart* theChart;

@property(nonatomic) NSDate* requestDate;
@property(nonatomic) NSTimeZone* timezone;
@property(nonatomic) id<ZoneKPIDataSource> dataSource;

@end

@implementation ZoneAverageDetailsWindowController

- (id)init:(WorstKPIDataSource*) dataSource initialIndex:(NSUInteger) index {
    self = [super initWithWindowNibName:@"ZoneAverageCellsDetailsWindow"];
    
    _dataSource = [[ZoneKPISource alloc] init:dataSource initialIndex:index];

    _requestDate = dataSource.requestDate;
    _timezone = dataSource.timezone;
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.window setLevel:NSStatusWindowLevel];
    
    MonitoringPeriodUtility* dc = [MonitoringPeriodUtility sharedInstance];
    self.window.title =  [MonitoringPeriodUtility getStringForGranularityPeriodDuration:dc.monitoringPeriod];

    
    [self displayChart:TRUE];
}

- (void) displayChart:(Boolean) animate {
    
    MonitoringPeriodUtility* dc = [MonitoringPeriodUtility sharedInstance];
    self.theChart = [[KPIBarChart alloc] init:[self.dataSource getZoneKPIValues] KPI:[self.dataSource getZoneKPI] date:self.requestDate  monitoringPeriod:dc.monitoringPeriod ];
    
    
    self.theChart.yTitleDisplacement = -5.0f;
    self.theChart.titleFontSize = 12.0f;
    self.theChart.xAxisFontSize = 12.0f;
    self.theChart.yAxisFontSize = 12.0f;
    self.theChart.subscriber = self;
    self.theChart.fillWithGradient = [UserPreferences sharedInstance].isZoneKPIDetailsGradiant;
    
    [self.theChart displayChart:self.hostView withAnimate:animate];

}
- (IBAction)previousKPIButtonPushed:(NSButton *)sender {
    [self.dataSource moveToPreviousZoneKPI];
    [self resyncAndDisplayWithNewKPI];
}
- (IBAction)nextKPIButtonPushed:(NSButton *)sender {
    [self.dataSource moveToNextZoneKPI];
    [self resyncAndDisplayWithNewKPI];
}

- (void) resyncAndDisplayWithNewKPI {
    [self displayChart:FALSE];
    [self.theKPITable reloadData];
    [self.theKPITable scrollRowToVisible:0];
}

-(void) refresh:(NSUInteger) index {
    [self.dataSource goToIndex:index];
    [self resyncAndDisplayWithNewKPI];
}

#pragma mark - barChartNotification protocol
- (void) selectedBar:(NSUInteger) index {
    [self.theKPITable scrollRowToVisible:index];
}

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.dataSource getZoneKPIValues].count;
}

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
    NSArray* theValues = [self.dataSource getZoneKPIValues];
    KPI* theKPI = [self.dataSource getZoneKPI];
    
    [rowView setBackgroundColor:[theKPI getBackgroundColorValueFromNumber:theValues[row]]];
}

// This method is optional if you use bindings to provide the data
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    DCMonitoringPeriodView monitoringPeriodView = [[MonitoringPeriodUtility sharedInstance] monitoringPeriod];
    if ((monitoringPeriodView == last6Hours15MnView) ||
        (monitoringPeriodView == last24HoursHourlyView)) {
        return [self configureDetailsCell:tableView viewForTableColumn:tableColumn row:row];
    } else {
        return [self configureDetailsCellPeriod:tableView viewForTableColumn:tableColumn row:row];
    }

    
}


- (NSView *) configureDetailsCell:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = [tableColumn identifier];
    
    NSArray* theValues = [self.dataSource getZoneKPIValues];
    KPI* theKPI = [self.dataSource getZoneKPI];
    
    if ([identifier isEqualToString:@"CellDate"]) {
        ZoneAverageDetailsCellWindow *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        cellView.dateCellLocalTime.stringValue = [DateUtility configureTimeDetailsCellWithTimezone:self.requestDate
                                                                                          timezone:self.timezone
                                                                                               row:row
                                                                                  monitoringPeriod:[[MonitoringPeriodUtility sharedInstance] monitoringPeriod]];
        cellView.dateLocalTime.stringValue = [DateUtility configureTimeDetailsCell:self.requestDate
                                                                               row:row
                                                                  monitoringPeriod:[[MonitoringPeriodUtility sharedInstance] monitoringPeriod]];
        return cellView;
    } else if ([identifier isEqualToString:@"CellValue"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        cellView.textField.stringValue = [theKPI getDisplayableValueFromNumber:theValues[row]];
        return cellView;
    } else if ([identifier isEqualToString:@"CellSeverity"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        cellView.textField.stringValue = @"";
        [cellView.textField setBackgroundColor:[theKPI getColorValueFromNumber:theValues[row]]];
        return cellView;
    }
    return nil;
    
}

- (NSView *) configureDetailsCellPeriod:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = [tableColumn identifier];

    NSArray* theValues = [self.dataSource getZoneKPIValues];
    KPI* theKPI = [self.dataSource getZoneKPI];
    
    if ([identifier isEqualToString:@"CellDate"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"CellPeriod" owner:self];
        cellView.textField.stringValue = [DateUtility configureTimeDetailsCellPeriod:self.requestDate
                                                                                 row:row
                                                                    monitoringPeriod:[[MonitoringPeriodUtility sharedInstance] monitoringPeriod]];
        return cellView;
    } else if ([identifier isEqualToString:@"CellValue"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        cellView.textField.stringValue = [theKPI getDisplayableValueFromNumber:theValues[row]];
        return cellView;
    } else if ([identifier isEqualToString:@"CellSeverity"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        cellView.textField.stringValue = @"";
        [cellView.textField setBackgroundColor:[theKPI getColorValueFromNumber:theValues[row]]];
        return cellView;
    }
    return nil;
}


@end
