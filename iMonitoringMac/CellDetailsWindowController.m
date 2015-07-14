//
//  CellDetailsWindowController.m
//  iMonitoring
//
//  Created by sébastien brugalières on 22/12/2013.
//
//

#import "CellDetailsWindowController.h"
#import "CellMonitoring.h"
#import "AttributeNameValue.h"
#import "CellAlarm.h"
#import "DateUtility.h"
#import "MainMapWindowController.h"
#import <CorePlot/CorePlot.h>
#import "UserPreferences.h"
#import "DashboardWorstCellViewCell.h"
#import "DashboardCellDetailsHelper.h"
#import "MonitoringPeriodUtility.h"
#import "CellDetailsKPIWindowController.h"
#import "KPIDictionary.h"
#import "KPIDictionaryManager.h"


@interface CellDetailsWindowController ()
@property (weak) IBOutlet NSTextField *cellNameLabel;
@property (weak) IBOutlet NSTextField *cellSiteLabel;
@property (weak) IBOutlet NSTextField *cellTechnoLabel;
@property (weak) IBOutlet NSTextField *cellReleaseLabel;
@property (weak) IBOutlet NSTextField *cellStreetLabel;
@property (weak) IBOutlet NSTextField *cellCityLabel;
@property (weak) IBOutlet NSTextField *cellCountryLabel;
@property (weak) IBOutlet NSTextField *cellTimezoneLabel;
@property (weak) IBOutlet NSTextField *alarmCriticalNBLabel;
@property (weak) IBOutlet NSTextField *alarmMajorNBLabel;
@property (weak) IBOutlet NSTextField *alarmMinorNBLabel;
@property (weak) IBOutlet NSTextField *alarmWarningNBLabel;
@property (weak) IBOutlet NSBox *alarmBox;
@property (weak) IBOutlet NSTextField *intraFrequenciesNBLabel;
@property (weak) IBOutlet NSTextField *interFrequenciesNBLabel;

@property (weak) IBOutlet NSTextField *interRATNBLabel;

@property (weak) CellMonitoring* theCell;
@property (nonatomic)  CellParametersDataSource* parameterDatasource;
@property (weak) IBOutlet NSTableView *parameterTableView;

@property (nonatomic) CellAlarmDatasource* alarmDatasource;
@property (nonatomic) NSMutableArray* alarmList;
@property (weak) IBOutlet NSTableView *alarmTableView;

@property (nonatomic) NSMutableArray* cellParameters;
@property (nonatomic) CellTimezoneDataSource* timezoneDatasource;

@property (nonatomic, weak) MainMapWindowController* theDelegate;
@property (weak) IBOutlet ExtendedTableView *KPIsTableView;
@property (weak) IBOutlet ExtendedTableView *KPIsTableView2;
@property (weak) IBOutlet ExtendedTableView *KPIsTableView3;
@property (weak) IBOutlet ExtendedTableView *KPIsTableView4;
@property (weak) IBOutlet ExtendedTableView *KPIsTableView5;

@property (nonatomic)  CellDetailsKPIWindowController *KPIWindow;
@property (nonatomic)  CellDetailsKPIWindowController *KPIWindow2;
@property (nonatomic)  CellDetailsKPIWindowController *KPIWindow3;
@property (nonatomic)  CellDetailsKPIWindowController *KPIWindow4;
@property (nonatomic)  CellDetailsKPIWindowController *KPIWindow5;


@property (nonatomic) CellKPIsDataSource* cellDatasource;
@property (nonatomic) NSMutableArray* barChartViewsDic;
@property (nonatomic) DCMonitoringPeriodView currentMonitoringPeriod;
@property (nonatomic) NSArray* currentBarChartViews;
@property (weak) IBOutlet NSTabView *theTabView;
@end

@implementation CellDetailsWindowController

#pragma mark - Initialization
- (id)initWithCell:(CellMonitoring*) cell  mapWindowController:(MainMapWindowController*) delegate
{
    self = [super initWithWindowNibName:@"cellDetailsWindow"];
    
    _theCell = cell;
    _theDelegate = delegate;
    
    return self;
}



- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.window setLevel: NSStatusWindowLevel];

    [self.KPIsTableView setExtendedDelegate:self];
    [self.KPIsTableView2 setExtendedDelegate:self];
    [self.KPIsTableView3 setExtendedDelegate:self];
    [self.KPIsTableView4 setExtendedDelegate:self];
    [self.KPIsTableView5 setExtendedDelegate:self];
    
    self.window.title = self.theCell.id;
    
    [self initializeView];
    
    self.parameterDatasource = [[CellParametersDataSource alloc] init:self];
    [self.parameterDatasource loadData:self.theCell];
    
    self.alarmDatasource = [[CellAlarmDatasource alloc] init:self.theCell];
    [self.alarmDatasource subscribe:self];
    [self.alarmDatasource loadAlarms];
    
    self.timezoneDatasource = [[CellTimezoneDataSource alloc] initWithDelegate:self cell:self.theCell];
    [self.timezoneDatasource loadTimeZone];
    
    [self loadCellKPIsDetails];
}


- (void) initializeView {
    
    self.cellNameLabel.stringValue = self.theCell.id;
    self.cellTechnoLabel.stringValue = self.theCell.techno;
    self.cellReleaseLabel.stringValue = self.theCell.releaseName;
    self.cellSiteLabel.stringValue = self.theCell.site;
    
    self.intraFrequenciesNBLabel.integerValue = self.theCell.numberIntraFreqNR;
    self.interFrequenciesNBLabel.integerValue = self.theCell.numberInterFreqNR;
    self.interRATNBLabel.integerValue = self.theCell.numberInterRATNR;
    
    [self getCellAddress:self.theCell];
    
    if ([self.theCell hasTimezone]) {
        self.cellTimezoneLabel.stringValue = [NSString stringWithFormat:@"%@ (TZ)",self.theCell.timezone];
    }
    
    [self initializeTitlesOfTabViewItems];
    
}


-(void) initializeTitlesOfTabViewItems {

    NSTabViewItem* item = [self.theTabView tabViewItemAtIndex:2];
    [item setLabel:[NSString stringWithFormat:@"%@", [MonitoringPeriodUtility getStringForGranularityPeriodDuration:last6Hours15MnView]]];

    item = [self.theTabView tabViewItemAtIndex:3];
    [item setLabel:[NSString stringWithFormat:@"%@", [MonitoringPeriodUtility getStringForGranularityPeriodDuration:last24HoursHourlyView]]];

    item = [self.theTabView tabViewItemAtIndex:4];
    [item setLabel:[NSString stringWithFormat:@"%@", [MonitoringPeriodUtility getStringForGranularityPeriodDuration:Last7DaysDailyView]]];

    item = [self.theTabView tabViewItemAtIndex:5];
    [item setLabel:[NSString stringWithFormat:@"%@", [MonitoringPeriodUtility getStringForGranularityPeriodDuration:Last4WeeksWeeklyView]]];

    item = [self.theTabView tabViewItemAtIndex:6];
    [item setLabel:[NSString stringWithFormat:@"%@", [MonitoringPeriodUtility getStringForGranularityPeriodDuration:Last6MonthsMontlyView]]];
}



- (void) getCellAddress:(CellMonitoring*) theCell {
    if ([theCell hasAddress] == false) {
        CLGeocoder* reverseGeoCoder = [[CLGeocoder alloc] init];
        
        CLLocationCoordinate2D cellCoordinate = [theCell coordinate];
        CLLocation *coordinate = [[CLLocation alloc] initWithLatitude:cellCoordinate.latitude longitude:cellCoordinate.longitude];
        
        [reverseGeoCoder reverseGeocodeLocation:coordinate completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error){
                self.cellStreetLabel.stringValue = @"Cannot resolve address";
                self.cellCityLabel.stringValue = @"";
                self.cellCountryLabel.stringValue = @"";
                return;
            }
            CLPlacemark* currentPlacemark = [placemarks lastObject];
            
            [theCell initialiazeAddress:currentPlacemark];
            
            self.cellStreetLabel.stringValue = theCell.street;
            self.cellCityLabel.stringValue = theCell.city;
            self.cellCountryLabel.stringValue = theCell.country;
        }];
    } else {
        self.cellStreetLabel.stringValue = theCell.street;
        self.cellCityLabel.stringValue = theCell.city;
        self.cellCountryLabel.stringValue = theCell.country;
    }
    
}

#pragma mark - Actions

- (IBAction)showCellOnMap:(NSButton *)sender {
    [self.theDelegate showSelectedCellOnMap:self.theCell];
}

- (IBAction)reloadAlarms:(NSButton *)sender {
    [self.alarmDatasource loadAlarms];
}
- (IBAction)showNeighborsRelations:(NSButton *)sender {
    [self.theDelegate initiliazeWithNeighborsOf:self.theCell];
}

#pragma mark - CellTimezoneDataSourceDelegate delegate
- (void) cellTimezoneResponse:(CellMonitoring*) cell error:(NSError*) theError {
    if (theError == Nil) {
        self.cellTimezoneLabel.stringValue = cell.timezone;
    } else {
        self.cellTimezoneLabel.stringValue = @"unknown timezone";
    }
}

#pragma mark - CellParametersDataSourceDelegate protocol
-(void) cellParametersWithResponse:(CellMonitoring*) cell error:(NSError*) theError {
    if (theError == Nil) {
        
        NSMutableArray* allParameters = [[NSMutableArray alloc] init];
        for (NSArray* parameterOfCurrentSection in self.theCell.parametersBySection.allValues) {
            [allParameters addObjectsFromArray:parameterOfCurrentSection];
        }
        
        self.cellParameters = allParameters;
        [self.parameterTableView reloadData];
    } else {
        NSAlert* alert = [NSAlert alertWithMessageText:@"Communication failure"
                                         defaultButton:Nil
                                       alternateButton:Nil
                                           otherButton:Nil
                             informativeTextWithFormat:@"Parameters cannot be loaded"];
        [alert runModal];
    }
}
#pragma  mark - AlarmListener protocol

- (void) alarmLoadingFailure {
    
    NSAlert* alert = [NSAlert alertWithMessageText:@"Communication failure"
                                     defaultButton:Nil
                                   alternateButton:Nil
                                       otherButton:Nil
                         informativeTextWithFormat:@"Alarms cannot be loaded"];
    [alert runModal];
    
//    self.isCellAlarmsLoading = FALSE;
    
    NSLog(@"Alarm loading failure");
}
- (void) alarmLoaded {
//    self.isCellAlarmsLoading = FALSE;
    
    self.alarmList = [[NSMutableArray alloc] initWithArray:self.alarmDatasource.alarmsOrderedByDate];
    
    [self refreshAlarmBox];
    [self.alarmTableView reloadData];
}

-(void) refreshAlarmBox {
    self.alarmCriticalNBLabel.stringValue = [NSString stringWithFormat:@"%ld", self.alarmDatasource.criticalAlarmCounter];
    
    if (self.alarmDatasource.criticalAlarmCounter > 0) {
        [self.alarmCriticalNBLabel setBackgroundColor:[CellAlarm getColorForSeverity:Critical]];
    } else {
        [self.alarmCriticalNBLabel setBackgroundColor:self.alarmDatasource.alarmWithHighestSeverity.severityLightColor];
    }
    
    self.alarmMajorNBLabel.stringValue = [NSString stringWithFormat:@"%ld", self.alarmDatasource.majorAlarmCounter];
    if (self.alarmDatasource.majorAlarmCounter > 0) {
        [self.alarmMajorNBLabel setBackgroundColor:[CellAlarm getColorForSeverity:Major]];
    } else {
        [self.alarmMajorNBLabel setBackgroundColor:self.alarmDatasource.alarmWithHighestSeverity.severityLightColor];
    }

    self.alarmMinorNBLabel.stringValue = [NSString stringWithFormat:@"%ld", self.alarmDatasource.minorAlarmCounter];
    if (self.alarmDatasource.minorAlarmCounter > 0) {
        [self.alarmMinorNBLabel setBackgroundColor:[CellAlarm getColorForSeverity:Minor]];
    } else {
        [self.alarmMinorNBLabel setBackgroundColor:self.alarmDatasource.alarmWithHighestSeverity.severityLightColor];
    }

    self.alarmWarningNBLabel.stringValue = [NSString stringWithFormat:@"%ld", self.alarmDatasource.warningAlarmCounter];
    if (self.alarmDatasource.warningAlarmCounter > 0) {
        [self.alarmWarningNBLabel setBackgroundColor:[CellAlarm getColorForSeverity:Warning]];
    } else {
        [self.alarmWarningNBLabel setBackgroundColor:self.alarmDatasource.alarmWithHighestSeverity.severityLightColor];
    }

    [self.alarmBox setFillColor:self.alarmDatasource.alarmWithHighestSeverity.severityLightColor];
    [self.alarmBox setBorderColor:self.alarmDatasource.alarmWithHighestSeverity.severityColor];
}

#pragma mark - CellDetailsItf protocol

- (void) loadCellKPIsDetails {
    
    CellKPIsDataSource* cache = [self.theCell getCache];
    if (cache != Nil) {
        self.cellDatasource = cache;
        [self buildGraphic];
        
    } else {
        self.cellDatasource = [[CellKPIsDataSource alloc] init:self];
        
        [self.cellDatasource loadData:self.theCell];
    }
}


#pragma mark - CellDetailsItf protocol
- (void) dataIsLoaded {
    [self buildGraphic];
}

-(void) buildGraphic {

  //  return;
    self.currentMonitoringPeriod = [UserPreferences sharedInstance].CellDashboardDefaultViewScope;
//    [self buildChartForCurrentMonitoringPeriod];

//    dispatch_queue_t buildImagesQueue = dispatch_queue_create("image builder", NULL);
//    dispatch_async(buildImagesQueue, ^{
        
        if (self.barChartViewsDic == Nil) {
            self.barChartViewsDic = [[NSMutableArray alloc] initWithObjects:[NSNull null], [NSNull null] , [NSNull null], [NSNull null], [NSNull null], nil];
        }

        
        for (NSUInteger i = 0; i < self.barChartViewsDic.count; i++) {
            if (self.barChartViewsDic[i] == [NSNull null]) {
                DashboardCellDetailsHelper* helper = [[DashboardCellDetailsHelper alloc] init:327 height:207];
                self.barChartViewsDic[i] = [helper createChartForMonitoringPeriod:self.cellDatasource monitoringPeriod:i];
            }
        }
        
//        dispatch_async(dispatch_get_main_queue(), ^{
            [self.KPIsTableView reloadData];
            [self.KPIsTableView2 reloadData];
            [self.KPIsTableView3 reloadData];
            [self.KPIsTableView4 reloadData];
            [self.KPIsTableView5 reloadData];
//        });
//    });
    
}

- (void) dataLoadingFailure {
    NSLog(@"Cell Details have  failed");
}

- (void) timezoneIsLoaded:(NSString*) theTimeZone {
    // Nothing has to be done
}

- (void) buildChartForCurrentMonitoringPeriod {
    if (self.barChartViewsDic == Nil) {
        self.barChartViewsDic = [[NSMutableArray alloc] initWithObjects:[NSNull null], [NSNull null] , [NSNull null], [NSNull null], [NSNull null], nil];
    }
    
    self.currentBarChartViews = self.barChartViewsDic[self.currentMonitoringPeriod];
    if ([self.currentBarChartViews isEqual:[NSNull null]]) {
        self.barChartViewsDic[self.currentMonitoringPeriod]= self.currentBarChartViews;
    }
}



#pragma mark - Utilities
+ (NSImage*) extractImageFromGraph:(CPTXYGraph*) graph {
    CGRect myRect = CGRectMake(0, 0, 336, 207);
    graph.bounds = myRect;
    return [graph imageOfLayer];
}

#pragma mark - ExtendedTableViewDelegate
- (void) selected:(ExtendedTableView*) tableview row:(NSUInteger)theRow column:(NSUInteger)theColumn {
    NSLog(@"Cell selected");
    
    DCMonitoringPeriodView theMonitoringPeriod;
    switch ([self.theTabView indexOfTabViewItem:self.theTabView.selectedTabViewItem]) {
        case 2: {
            theMonitoringPeriod = last6Hours15MnView;
            break;
        }
        case 3: {
            theMonitoringPeriod = last24HoursHourlyView;
            break;
        }
        case 4: {
            theMonitoringPeriod = Last7DaysDailyView;
            break;
        }
        case 5: {
            theMonitoringPeriod = Last4WeeksWeeklyView;
            break;
        }
        case 6: {
            theMonitoringPeriod = Last6MonthsMontlyView;
            break;
        }
        default: {
            return;
        }
    }

    
    KPIDictionary* dictionary = [KPIDictionaryManager sharedInstance].defaultKPIDictionary;
    NSUInteger index = theRow * 2 + theColumn;
   
    NSUInteger indexes[] = {0,0};
    NSIndexPath* indexOfCurrentKPI = [NSIndexPath indexPathWithIndexes:indexes length:2];
    for (NSUInteger i = 0; i < index; i++) {
        indexOfCurrentKPI = [dictionary getNextKPIByDomain:indexOfCurrentKPI techno:_theCell.cellTechnology];
    }

    
    CellDetailsKPIWindowController* theKPIWindow = [[CellDetailsKPIWindowController alloc] init:self.cellDatasource initialIndex:indexOfCurrentKPI initialMonitoringPeriod:theMonitoringPeriod];
    [theKPIWindow showWindow:self];

    switch ([self.theTabView indexOfTabViewItem:self.theTabView.selectedTabViewItem]) {
        case 2: {
            self.KPIWindow = theKPIWindow;
            break;
        }
        case 3: {
            self.KPIWindow2 = theKPIWindow;
            break;
        }
        case 4: {
            self.KPIWindow3 = theKPIWindow;
            break;
        }
        case 5: {
            self.KPIWindow4 = theKPIWindow;
            break;
        }
        case 6: {
            self.KPIWindow5 = theKPIWindow;
            break;
        }
        default: {
            
        }
    }

}

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView == self.parameterTableView) {
        if (self.cellParameters == Nil) {
            return 0;
        } else {
            return self.cellParameters.count;
        }
    } else if (tableView == self.alarmTableView) {
        return self.alarmList.count;
        //    } else if (tableView == self.KPIsTableView) {
    } else {
        NSArray* theBarChartViews = [self getBartChartsViewsFor:tableView];
        if (theBarChartViews == Nil) {
            return 0;
        } else {
            return (floor(theBarChartViews.count / 2) + theBarChartViews.count % 2);
        }
    }
    return 0;
    
}

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
    if (tableView == self.alarmTableView) {
        CellAlarm* theAlarm = self.alarmList[row];
        [rowView setBackgroundColor:theAlarm.severityLightColor];
    }
}

// This method is optional if you use bindings to provide the data
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // Group our "model" object, which is a dictionary
    
    // In IB the tableColumn has the identifier set to the same string as the keys in our dictionary
    NSString *identifier = [tableColumn identifier];

    NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
  
    if (tableView == self.parameterTableView) {
        
        AttributeNameValue* parameter = self.cellParameters[row];
        
        if ([identifier isEqualToString:@"ParameterName"]) {
            cellView.textField.stringValue = parameter.name;
            return cellView;
        } else if ([identifier isEqualToString:@"ParameterValue"]) {
            cellView.textField.stringValue = parameter.value;
            return cellView;
        } else if ([identifier isEqualToString:@"ParameterSection"]) {
            cellView.textField.stringValue = parameter.section;
            return cellView;
        }
        return nil;
    } else if (tableView == self.alarmTableView) {
        CellAlarm* theAlarm = self.alarmList[row];
        if ([identifier isEqualToString:@"alarmDate"]) {
            cellView.textField.stringValue = [theAlarm getAlarmDate:self.alarmDatasource.theCell];
            return cellView;
        } else if ([identifier isEqualToString:@"alarmSeverity"]) {
            cellView.textField.stringValue = theAlarm.severityString;
            return cellView;
        } else if ([identifier isEqualToString:@"alarmType"]) {
            cellView.textField.stringValue = theAlarm.alarmTypeString;
            return cellView;
        } else if ([identifier isEqualToString:@"alarmProbableCause"]) {
            cellView.textField.stringValue = theAlarm.probableCause;
            return cellView;
        }
        return nil;
    } else {
        NSArray* theBarChartViews = [self getBartChartsViewsFor:tableView];
        if (theBarChartViews == Nil) {
            return Nil;
        } else {
            
            NSString *identifier = [tableColumn identifier];
            
            NSInteger index = row * 2;
            if ([identifier isEqualToString:@"Col2"]) {
                index++;
                if (index >= theBarChartViews.count) {
                    return Nil;
                }
            }
            
            DashboardWorstCellViewCell* cellView = [tableView makeViewWithIdentifier:identifier owner:self];
            
            
            NSImage* currentImage = theBarChartViews[index];
            cellView.graphImage.image = currentImage;
            return cellView;
        }
    }
    
    return Nil;
}

- (NSArray*) getBartChartsViewsFor:(NSTableView*) tableView {
    NSArray* theBarChartViews = Nil;
    if (tableView == self.KPIsTableView) {
        theBarChartViews = self.barChartViewsDic[0];
    } else if (tableView == self.KPIsTableView2) {
        theBarChartViews = self.barChartViewsDic[1];
    } else if (tableView == self.KPIsTableView3) {
        theBarChartViews = self.barChartViewsDic[2];
    } else if (tableView == self.KPIsTableView4) {
        theBarChartViews = self.barChartViewsDic[3];
    } else if (tableView == self.KPIsTableView5) {
        theBarChartViews = self.barChartViewsDic[4];
    }
 
    return theBarChartViews;
}


- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    if (aTableView == self.parameterTableView) {
        return self.cellParameters[rowIndex];
    } else if (aTableView == self.alarmTableView) {
        return self.alarmList[rowIndex];
    }
    return Nil;
}

- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    if (tableView == self.parameterTableView) {
        [self.cellParameters sortUsingDescriptors:[tableView sortDescriptors]];
        [tableView reloadData];
    } else {
        [self.alarmList sortUsingDescriptors:[tableView sortDescriptors]];
        [tableView reloadData];
    }
}


#pragma mark - NSTabViewDelegate protocol
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    NSLog(@"Tabview selected item: %@", tabViewItem.label);
}

@end
