//
//  SimpleGraphicWindowController.m
//  iMonitoring
//
//  Created by sébastien brugalières on 02/01/2014.
//
//

#import "SimpleGraphicWindowController.h"
#import "MainMapWindowController.h"
#import <CorePlot/CorePlot.h>
#import "CellWithKPIValues.h"
#import "WorstKPIChart.h"
#import "KPI.h"

@interface SimpleGraphicWindowController ()

@property (nonatomic, weak) MainMapWindowController* delegate;

@property (nonatomic) WorstKPIDataSource* datasource;

@property (nonatomic, weak) IBOutlet CPTGraphHostingView *hostView;
@property (nonatomic, weak) IBOutlet NSImageView *theImageView;

@property (nonatomic) WorstKPIChart* theChart;

@end

@implementation SimpleGraphicWindowController

- (id)init:(MainMapWindowController*) theDelegate datasource:(WorstKPIDataSource*) lastWorstKPIs
{
    self = [super initWithWindowNibName:@"SimpleGraphicWindow"];
    _delegate = theDelegate;
    _datasource = lastWorstKPIs;
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.window setLevel:NSStatusWindowLevel];
    
    [self displayChart:TRUE];
    [self displayChartInImage];
    
//    self.datasource = [[ZonesDatasSource alloc] init:self];
//    [self.datasource downloadZones];
}


- (void) displayChartInImage {

    WorstKPIChart* currentChart = [self createWorstChart];
    
    [currentChart prepareChart];
    
    self.theImageView.image = [SimpleGraphicWindowController extractImageFromGraph:currentChart.pieGraph];

}


- (WorstKPIChart*) createWorstChart {
    
    // Create the chart and initialize it
    NSEnumerator* KPIsEnumerator = [self.datasource.KPIs objectEnumerator];
    
    NSArray* KPIsPerCell = [KPIsEnumerator nextObject];

    CellWithKPIValues* firstCellKPIs = KPIsPerCell[0];
    KPI* theKPI = firstCellKPIs.theKPI;
    
    // Return the list of KPIs and for each KPI the list of values
    Boolean isLastWorstValue = FALSE;
//    switch (scope) {
//        case DSScopeLastGP: {
//            isLastWorstValue = TRUE;
//            break;
//        }
//        case DSScopeLastPeriod: {
//            isLastWorstValue = FALSE;
//            break;
//        }
//        case DSScopeAverageZoneAndPeriod: {
//            // Not Applicable
//            break;
//        }
//    }
    WorstKPIChart* currentChart = [WorstKPIChart instantiateChart:KPIsPerCell isLastWorst:isLastWorstValue];
    currentChart.title = [NSString stringWithFormat:@"%@ / %@", theKPI.domain, theKPI.name];
    [self configureWorstChartStyle:currentChart];
    
    return currentChart;
}

- (void) configureWorstChartStyle:(WorstKPIChart*) theChart {
    
    // Good Configuration for 3 rows / 4 columns
    theChart.yTitleDisplacement     = -10.0f;
    
    theChart.titleFontSize          = 12.0f;
    theChart.pieRadius              = 70.0f;
    theChart.legendFontSize         = 12.0f;
    theChart.legendXDisplacement    = 65.0f;
    theChart.legendYDisplacement    = 40.0f;
    theChart.fillWithGradient       = TRUE;//[UserPreferences sharedInstance].isZoneDashboardGradiant;
}


#pragma mark - Utilities
+ (NSImage*) extractImageFromGraph:(CPTXYGraph*) graph {
    CGRect myRect = CGRectMake(0, 0, 672, 414);
    graph.bounds = myRect;
    return [graph imageOfLayer];
}




- (void) displayChart:(Boolean) animate {
    
    NSEnumerator* KPIsEnumerator = [self.datasource.KPIs objectEnumerator];
    
    NSArray* KPIsPerCell = [KPIsEnumerator nextObject];
    
    CellWithKPIValues* firstCell = KPIsPerCell[0];
    
    
    KPI* theKPI = firstCell.theKPI;
    
    self.theChart = [WorstKPIChart instantiateChart:KPIsPerCell isLastWorst:TRUE];
    
//    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
//    [self setGraphicPropertiesBasedOnOrientation:orientation];
    
    self.theChart.title = [NSString stringWithFormat:@"%@ / %@", theKPI.domain, theKPI.name];
    self.theChart.yTitleDisplacement = -10.0f;
    self.theChart.titleFontSize = 10.0f;
//    self.theChart.subscriber = self;
 //   self.theChart.fillWithGradient = [UserPreferences sharedInstance].isZoneKPIDetailsGradiant;
    
    CPTGraphHostingView *hostingView = self.hostView;
//    if (self.displayingPrimary == FALSE) {
//        hostingView = _theGraph;
//    } else {
//        hostingView = _theSecondGraph;
//    }
    [_theChart displayChart:hostingView withAnimate:animate];
}


@end
