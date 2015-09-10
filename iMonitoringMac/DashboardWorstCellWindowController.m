//
//  DashboardWorstCellWindowController.m
//  iMonitoring
//
//  Created by sébastien brugalières on 03/01/2014.
//
//

#import "DashboardWorstCellWindowController.h"
#import "MainMapWindowController.h"
#import <CorePlot/CorePlot.h>
#import "CellWithKPIValues.h"
#import "WorstKPIChart.h"
#import "KPI.h"
#import "DashboardWorstCellViewCell.h"
#import "DashboardGraphicsHelper.h"
#import "WorstCellDetailsWindowController.h"
#import "UserPreferences.h"
#import "ExtendedTableView.h"
#import "ZoneAverageDetailsWindowController.h"
#import "ZoneKPISource.h"
#import "BasicTypes.h"
#import "DateUtility.h"

@interface DashboardWorstCellWindowController ()

@property (weak) IBOutlet ExtendedTableView *worstChartTableView;
@property (weak) IBOutlet ExtendedTableView *worstAverageChartsTableView;
@property (weak) IBOutlet ExtendedTableView *averageOnZoneChartsTableView;

@property (weak) IBOutlet NSTabView* scopeTabView;


@property(nonatomic, weak) MainMapWindowController* delegate;
@property (nonatomic) WorstKPIDataSource* datasource;


@property (nonatomic) NSArray* worstLastGPCharts;
@property (nonatomic) NSArray* worstAverageCharts;
@property (nonatomic) NSArray* averageOnZoneCharts;

@property (nonatomic) WorstCellDetailsWindowController* worstCellDetails;
@property (nonatomic) WorstCellDetailsWindowController* worstAverageCellDetails;
@property (nonatomic) ZoneAverageDetailsWindowController* ZoneAverageCellDetails;

@end

@implementation DashboardWorstCellWindowController

- (id)init:(MainMapWindowController*) theDelegate datasource:(WorstKPIDataSource*) theDatasource
{
    self = [super initWithWindowNibName:@"WorstCellsDashboardWindow"];
    _delegate = theDelegate;
    _datasource = theDatasource;
    
    return self;
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.window setLevel:NSStatusWindowLevel];
    
    NSString* windowTitle = [NSString stringWithFormat:@"%@ Dashboard / %@ (LT) / %@ (%@)",[BasicTypes getTechnoName:self.datasource.technology],
                             [DateUtility getDate:self.datasource.requestDate option:withHHmmss],
                             [DateUtility getDateWithRealTimeZone:self.datasource.requestDate timezone:self.datasource.timezone option:withHHmmss],
                             self.datasource.timezone];
    
    [self.window setTitle:windowTitle];
 
    [self.worstChartTableView setExtendedDelegate:self];
    [self.worstAverageChartsTableView setExtendedDelegate:self];
    [self.averageOnZoneChartsTableView setExtendedDelegate:self];
    
    [self initializeTitlesOfTabViewItems];
    [self createCharts];
    
    [self.worstChartTableView reloadData];
    [self.worstAverageChartsTableView reloadData];
    [self.averageOnZoneChartsTableView reloadData];
}


-(void) initializeTitlesOfTabViewItems {
    MonitoringPeriodUtility* dc = [MonitoringPeriodUtility sharedInstance];
    NSTabViewItem* item = [self.scopeTabView tabViewItemAtIndex:0];
    
    [item setLabel:[NSString stringWithFormat:@"Worst cell on %@", [MonitoringPeriodUtility getStringForGranularityPeriodName:dc.monitoringPeriod]]];
    
    item = [self.scopeTabView tabViewItemAtIndex:1];
    [item setLabel:[NSString stringWithFormat:@"Worst cell for %@", [MonitoringPeriodUtility getStringForGranularityPeriodDuration:dc.monitoringPeriod]]];
    item = [self.scopeTabView tabViewItemAtIndex:2];
    [item setLabel:[NSString stringWithFormat:@"KPI average for %@", [MonitoringPeriodUtility getStringForGranularityPeriodDuration:dc.monitoringPeriod]]];
}


-(void) createCharts {
    DashboardGraphicsHelper* graphicHelper = [[DashboardGraphicsHelper alloc] init:336 height:207];
    self.worstLastGPCharts = [graphicHelper createAllWorstCharts:self.datasource.KPIs scope:DSScopeLastGP];
    self.worstAverageCharts = [graphicHelper createAllWorstCharts:self.datasource.worstAverageKPIs scope:DSScopeLastPeriod];
    self.averageOnZoneCharts = [graphicHelper createAllChartsWithAverageOnZone:self.datasource.zoneKPIs.objectEnumerator.allObjects
                                                                   requestDate:self.datasource.requestDate
                                                              monitoringPeriod:[MonitoringPeriodUtility sharedInstance].monitoringPeriod];

}


#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return (floor(self.worstLastGPCharts.count / 2) + self.worstLastGPCharts.count % 2);
}

// This method is optional if you use bindings to provide the data
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // Group our "model" object, which is a dictionary
    
    // In IB the tableColumn has the identifier set to the same string as the keys in our dictionary
    NSString *identifier = [tableColumn identifier];
    NSImage* currentImage;
      
    NSInteger index = row * 2;
    if ([identifier isEqualToString:@"Col2"]) {
        index++;
        if (index >= self.worstLastGPCharts.count) {
            return Nil;
        }
    }
    
    
    if (tableView == self.worstChartTableView) {
        currentImage = self.worstLastGPCharts[index];
    } else if (tableView == self.worstAverageChartsTableView) {
        currentImage = self.worstAverageCharts[index];
    } else if (tableView == self.averageOnZoneChartsTableView) {
        currentImage = self.averageOnZoneCharts[index];
    } else {
        return Nil;
    }
    
    DashboardWorstCellViewCell* cellView = [tableView makeViewWithIdentifier:identifier owner:self];
    
    cellView.graphImage.image = currentImage;
    
    return cellView;

    
}

- (void) selected:(ExtendedTableView*) tableview row:(NSUInteger)theRow column:(NSUInteger)theColumn {
    
    NSUInteger index = (theRow * 2) + theColumn;
    if (index >= self.worstLastGPCharts.count) {
        return;
    }
    
    Boolean isAverageValue = FALSE;
    
    switch ([self.scopeTabView indexOfTabViewItem:self.scopeTabView.selectedTabViewItem]) {
        case 0: {
            isAverageValue = FALSE;
            break;
        }
        case 1: {
            isAverageValue = TRUE;
            break;
        }
        default: {
            
        }
    }
    
    
    if ([self.scopeTabView indexOfTabViewItem:self.scopeTabView.selectedTabViewItem] == 2) {
        if (self.ZoneAverageCellDetails != Nil) {
            [self.ZoneAverageCellDetails.window orderFront:self];
            [self.ZoneAverageCellDetails refresh:index];
            return;
        }
        
        self.ZoneAverageCellDetails = [[ZoneAverageDetailsWindowController alloc] init:self.datasource
                                                                          initialIndex:index];
        [self.ZoneAverageCellDetails showWindow:self];
       [self.ZoneAverageCellDetails.window setDelegate:self];

    } else {
    
        if ((isAverageValue == FALSE) && (self.worstCellDetails != Nil)) {
            [self.worstCellDetails.window orderFront:self];
            [self.worstCellDetails refresh:index];
            return;
        }
        
        if ((isAverageValue == TRUE) && (self.worstAverageCellDetails != Nil)) {
            [self.worstAverageCellDetails.window orderFront:self];
            [self.worstAverageCellDetails refresh:index];
            return;
        }
        
        WorstCellDetailsWindowController* theWindow = [[WorstCellDetailsWindowController alloc] init:self.datasource initialIndex:index isAverage:isAverageValue];
        [theWindow showWindow:self];
        
        [theWindow.window setDelegate:self];
        
        if (isAverageValue == TRUE) {
            self.worstAverageCellDetails = theWindow;
        } else {
            self.worstCellDetails = theWindow;
        }
    }

}


- (void)windowWillClose:(NSNotification *)notification {
    
    if ([notification object] == self.worstCellDetails.window) {
        self.worstCellDetails = Nil;
        return;
    }
    
    if ([notification object] == self.worstAverageCellDetails.window) {
        self.worstAverageCellDetails = Nil;
        return;
    }

    if ([notification object] == self.ZoneAverageCellDetails.window) {
        self.ZoneAverageCellDetails = Nil;
        return;
    }
}


@end
