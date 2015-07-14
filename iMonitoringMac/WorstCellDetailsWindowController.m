//
//  WorstCellDetailsWindowController.m
//  iMonitoring
//
//  Created by sébastien brugalières on 04/01/2014.
//
//

#import "WorstCellDetailsWindowController.h"
#import "WorstKPIItf.h"
#import "WorstKPIChart.h"
#import "KPI.h"
#import "CellWithKPIValues.h"
#import "UserPreferences.h"
#import "MonitoringPeriodUtility.h"
#import "WorstCellSource.h"
#import "WorstCellDetailsViewCell.h"
#import "MainMapWindowController.h"

@interface WorstCellDetailsWindowController ()

@property (nonatomic, weak) IBOutlet CPTGraphHostingView *hostView;
@property (weak) IBOutlet NSTableView *theKPITable;

@property (nonatomic) Boolean isAverageKPIs;
@property (nonatomic) NSArray* KPIValuesPerCell;
@property (nonatomic) NSString* KPIName;

@property (nonatomic) WorstKPIChart* theChart;

@property (nonatomic) WorstCellSource* datasource;


@end

@implementation WorstCellDetailsWindowController

- (id)init:(WorstKPIDataSource*) worstKPIDatasource initialIndex:(NSUInteger) index isAverage:(Boolean) isAverageKPIs
{
    self = [super initWithWindowNibName:@"WorstCellsDetails"];

    
    _datasource = [[WorstCellSource alloc] init:worstKPIDatasource initialIndex:index isAverage:isAverageKPIs];

    [self resyncValues];
    
    
    _isAverageKPIs = isAverageKPIs;

    return self;
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.window setLevel:NSStatusWindowLevel];
    
    MonitoringPeriodUtility* dc = [MonitoringPeriodUtility sharedInstance];
    if (self.isAverageKPIs == FALSE) {
        self.window.title = [MonitoringPeriodUtility getStringForGranularityPeriodName:dc.monitoringPeriod];
    } else {
        self.window.title =  [MonitoringPeriodUtility getStringForGranularityPeriodDuration:dc.monitoringPeriod];
    }
    
    [self displayChart:TRUE];
}
- (IBAction)previousKPIButtonPushed:(NSButton *)sender {
    [self.datasource moveToPreviousKPI];
    [self resyncAndDisplayWithNewKPI];
}

- (IBAction)nextKPIButtonPushed:(NSButton *)sender {
    [self.datasource moveToNextKPI];
    [self resyncAndDisplayWithNewKPI];
}

- (IBAction)KPIsButtonPushed:(NSButton *)sender {
    
    
    CellWithKPIValues* cellData = self.KPIValuesPerCell[sender.tag];
    CellMonitoring* theSelectedCell = [self.datasource getCellbyName:cellData.cellName];
    
   [[MainMapWindowController sharedInstance] showDetailsOfCell:theSelectedCell];
}

- (IBAction)mapButtonPushed:(NSButton *)sender {
    CellWithKPIValues* cellData = self.KPIValuesPerCell[sender.tag];
    CellMonitoring* theSelectedCell = [self.datasource getCellbyName:cellData.cellName];
    [[MainMapWindowController sharedInstance] showSelectedCellOnMap:theSelectedCell];

}

- (void) resyncValues {
    self.KPIValuesPerCell = [self.datasource getKPIValues];
    
    if (self.KPIValuesPerCell != Nil) {
        CellWithKPIValues* firstCell = self.KPIValuesPerCell[0];
        self.KPIName = firstCell.theKPI.name;
    }
   
}

- (void) resyncAndDisplayWithNewKPI {
    [self resyncValues];
    [self displayChart:FALSE];
    [self.theKPITable reloadData];
    [self.theKPITable scrollRowToVisible:0];
//    self.navigationItem.title = self.KPIName;
//    
}

-(void) refresh:(NSUInteger) index {
    [self.datasource goToIndex:index];
    [self resyncAndDisplayWithNewKPI];
}

- (void) displayChart:(Boolean) animate {
    CellWithKPIValues* firstCell = _KPIValuesPerCell[0];
    KPI* theKPI = firstCell.theKPI;
    
    self.theChart = [WorstKPIChart instantiateChart:_KPIValuesPerCell isLastWorst:!_isAverageKPIs];
    
    self.theChart.title = [NSString stringWithFormat:@"%@ / %@", theKPI.domain, theKPI.name];
    self.theChart.yTitleDisplacement = -10.0f;
    self.theChart.titleFontSize = 16.0f;
    
    self.theChart.pieRadius = 130.0f;
    
    self.theChart.paddingLeft = -170.0f;
    
    self.theChart.legendFontSize = 16.0f;
    self.theChart.legendXDisplacement = 140.0f;
    self.theChart.legendYDisplacement = 80.0f;
    
    self.theChart.subscriber = self;
    self.theChart.fillWithGradient = [UserPreferences sharedInstance].isZoneKPIDetailsGradiant;
    
    CPTGraphHostingView *hostingView = self.hostView;
    [self.theChart displayChart:hostingView withAnimate:animate];
}
#pragma mark - pieChartNotification protocol
- (void) selectedSlice:(NSUInteger) index {
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
        [_theKPITable scrollRowToVisible:targetIndex];
    } else {
        // No row to be displayed
    }
}

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.KPIValuesPerCell.count;
}

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
    CellWithKPIValues* cellData = self.KPIValuesPerCell[row];

    NSNumber* valueToBeDisplayed;
    if (self.isAverageKPIs == FALSE) {
        valueToBeDisplayed = cellData.lastKPIValue;
    } else {
        valueToBeDisplayed = cellData.averageValue;
    }

    [rowView setBackgroundColor:[cellData.theKPI getBackgroundColorValueFromNumber:valueToBeDisplayed]];
}

// This method is optional if you use bindings to provide the data
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = [tableColumn identifier];
    
  
    
    CellWithKPIValues* cellData = self.KPIValuesPerCell[row];
    
    
    NSNumber* valueToBeDisplayed;
    if (self.isAverageKPIs == FALSE) {
        valueToBeDisplayed = cellData.lastKPIValue;
    } else {
        valueToBeDisplayed = cellData.averageValue;
    }
    
    
    if ([identifier isEqualToString:@"CellName"]) {
        WorstCellDetailsViewCell *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        cellView.cellName.stringValue = cellData.cellName;
        cellView.KPIsButton.tag = row;
        cellView.mapButton.tag = row;
        return cellView;
    } else if ([identifier isEqualToString:@"CellValue"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        cellView.textField.stringValue = [cellData.theKPI getDisplayableValueFromNumber:valueToBeDisplayed];
        return cellView;
    } else if ([identifier isEqualToString:@"CellSeverity"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        cellView.textField.stringValue = @"";
        [cellView.textField setBackgroundColor:[cellData.theKPI getColorValueFromNumber:valueToBeDisplayed]];
        return cellView;
    }
    return nil;

}


@end
