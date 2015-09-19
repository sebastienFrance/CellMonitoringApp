//
//  DashboardGraphicsHelper.m
//  iMonitoring
//
//  Created by sébastien brugalières on 04/01/2014.
//
//

#import "DashboardGraphicsHelper.h"
#import "BasicTypes.h"
#import "WorstKPIChart.h"
#import "KPIBarChart.h"
#import "CellWithKPIValues.h"
#import "ZoneKPI.h"
#import "KPI.h"
#import "UserPreferences.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
#import <Cocoa/Cocoa.h>
#endif

@interface DashboardGraphicsHelper()

@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

@end

@implementation DashboardGraphicsHelper

- (id) init:(CGFloat) theWidth height:(CGFloat) theHeight {
    if (self = [super init]) {
        _width = theWidth;
        _height = theHeight;
        
        [self initDefaultForWorstChar];
        [self initDefaultForBarChart];
    }
    
    return self;
}


- (NSArray*) createAllWorstCharts:(NSDictionary*) KPIValues scope:(DashboardScopeId) scope{
    NSArray* listOfKPIValuesPerCell = KPIValues.objectEnumerator.allObjects;
    NSMutableArray* charts = [[NSMutableArray alloc] initWithCapacity:listOfKPIValuesPerCell.count];
    
    for (NSArray* KPIValuesPerCell in listOfKPIValuesPerCell) {
        WorstKPIChart* currentChart = [self createWorstChart:KPIValuesPerCell scope:scope];
        [currentChart prepareChart];
        
#if TARGET_OS_IPHONE
        UIImage* theImage;
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
        NSImage* theImage;
#endif
        theImage =[self extractImageFromGraph:currentChart.pieGraph];
        
        [charts addObject:theImage];
    }
    
    return charts;
}

- (WorstKPIChart*) createWorstChart:(NSArray*) KPIValues scope:(DashboardScopeId) scope {
    
    // Create the chart and initialize it
    CellWithKPIValues* firstCellKPIs = KPIValues[0];
    KPI* theKPI = firstCellKPIs.theKPI;
    
    // Return the list of KPIs and for each KPI the list of values
    Boolean isLastWorstValue = FALSE;
    switch (scope) {
        case DSScopeLastGP: {
            isLastWorstValue = TRUE;
            break;
        }
        case DSScopeLastPeriod: {
            isLastWorstValue = FALSE;
            break;
        }
        case DSScopeAverageZoneAndPeriod: {
            // Not Applicable
            break;
        }
    }
    WorstKPIChart* currentChart = [WorstKPIChart instantiateChart:KPIValues isLastWorst:isLastWorstValue];
    currentChart.title = [NSString stringWithFormat:@"%@ / %@", theKPI.domain, theKPI.name];
    [self configureWorstChartStyle:currentChart];
    
    return currentChart;
}


#pragma mark - Average Chart

- (NSArray*) createAllChartsWithAverageOnZone:(NSArray*) ListOfZoneKPI
                                  requestDate:(NSDate*) theRequestDate
                             monitoringPeriod:(DCMonitoringPeriodView) theMonitoringPeriod{
    // Return the list of KPIs and for each KPI the list of values
    
    NSMutableArray* newCharts = [[NSMutableArray alloc] initWithCapacity:ListOfZoneKPI.count];
    
    for (ZoneKPI* currentZoneKPI in ListOfZoneKPI) {
        
#if TARGET_OS_IPHONE
        UIImage* currentChart;
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
        NSImage* currentChart;
#endif
        currentChart = [self createBarChart:currentZoneKPI requestDate:theRequestDate monitoringPeriod:theMonitoringPeriod];
        [newCharts addObject:currentChart];
    }
    return newCharts;
}

#if TARGET_OS_IPHONE
- (UIImage*) createBarChart:(ZoneKPI*) theZoneKPI
                requestDate:(NSDate*) theRequestDate
           monitoringPeriod:(DCMonitoringPeriodView) theMonitoringPeriod{
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
    - (NSImage*) createBarChart:(ZoneKPI*) theZoneKPI
requestDate:(NSDate*) theRequestDate
monitoringPeriod:(DCMonitoringPeriodView) theMonitoringPeriod{
#endif
    
    KPI* theKPI = theZoneKPI.theKPI;
    
    KPIBarChart* currentChart = [[KPIBarChart alloc] init:theZoneKPI.getKPIAverage KPI:theKPI date:theRequestDate monitoringPeriod:theMonitoringPeriod];
    [self configureBartChartStyle:currentChart];
    
    [currentChart prepareChart];
    return [self extractImageFromGraph:currentChart.barChart];
}
    
    
#pragma mark - Graphics Configuration
    
    - (void) initDefaultForWorstChar {
        _worstChartyTitleDisplacement     = -10.0f;
        _worstCharttitleFontSize          = 12.0f;
        _worstChartpieRadius              = 70.0f;
        _worstChartlegendFontSize         = 12.0f;
        _worstChartlegendXDisplacement    = 65.0f;
        _worstChartlegendYDisplacement    = 40.0f;
        _worstChartfillWithGradient       = [UserPreferences sharedInstance].isZoneDashboardGradiant;
    }
    
    
    - (void) configureWorstChartStyle:(WorstKPIChart*) theChart {
        
        // Good Configuration for 3 rows / 4 columns
        theChart.yTitleDisplacement     = self.worstChartyTitleDisplacement;
        theChart.titleFontSize          = self.worstCharttitleFontSize;
        theChart.pieRadius              = self.worstChartpieRadius;
        theChart.legendFontSize         = self.worstChartlegendFontSize;
        theChart.legendXDisplacement    = self.worstChartlegendXDisplacement;
        theChart.legendYDisplacement    = self.worstChartlegendYDisplacement;
        theChart.fillWithGradient       = self.worstChartfillWithGradient;
    }
    
    -(void) initDefaultForBarChart {
        _barChartyTitleDisplacement = -8.0f;
        _barChartitleFontSize = 10.0f;
        _barCharfillWithGradient = [UserPreferences sharedInstance].isZoneDashboardGradiant;
        
    }
    
    - (void) configureBartChartStyle:(KPIBarChart*) theChart {
        
        // Good Configuration for 3 rows / 4 columns
        theChart.yTitleDisplacement = self.barChartyTitleDisplacement;
        theChart.titleFontSize = self.barChartitleFontSize;
        theChart.fillWithGradient = self.barCharfillWithGradient;

        theChart.xAxisAlignment = CPTTextAlignmentRight;

        theChart.xAxisFontSize = 12.0f;
        theChart.yAxisFontSize = 12.0f;

    }
    
    
    
#pragma mark - Utilities
    
#if TARGET_OS_IPHONE
    - (UIImage*) extractImageFromGraph:(CPTXYGraph*) graph  {
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
        - (NSImage*) extractImageFromGraph:(CPTXYGraph*) graph {
#endif
            CGRect myRect = CGRectMake(0, 0, self.width, self.height);
            graph.bounds = myRect;
            return [graph imageOfLayer];
        }
        
        
        @end
