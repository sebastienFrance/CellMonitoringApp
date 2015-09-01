//
//  DashboardCellDetailsHelper.m
//  iMonitoring
//
//  Created by sébastien brugalières on 12/01/2014.
//
//

#import "DashboardCellDetailsHelper.h"
#import "MonitoringPeriodUtility.h"
#import "KPIDictionary.h"
#import "KPIDictionaryManager.h"
#import "KPIBarChart.h"
#import "KPI.h"
#import "UserPreferences.h"
#import "CellKPIsDataSource.h"
#import "BasicTypes.h"
#import "CellMonitoring.h"

@interface DashboardCellDetailsHelper()

@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

@end

@implementation DashboardCellDetailsHelper

- (id) init:(CGFloat) theWidth height:(CGFloat) theHeight {
    if (self = [super init]) {
        _width = theWidth;
        _height = theHeight;
        
        [self initDefaultForChart];
    }
    
    return self;
}


- (NSArray<UIImage*>*) createChartForMonitoringPeriod:(CellKPIsDataSource*) cellDatasource monitoringPeriod:(DCMonitoringPeriodView) theMonitoringPeriod {
    NSMutableArray* barCharImages = [[NSMutableArray alloc] init];
    
    KPIDictionary* dictionary = [KPIDictionaryManager sharedInstance].defaultKPIDictionary;
    NSUInteger indexes[] = {0,0};
    NSIndexPath* indexOfCurrentKPI = [NSIndexPath indexPathWithIndexes:indexes length:2];
    while (indexOfCurrentKPI != Nil) {
        
        KPIBarChart* currentBarChart = [self createChart:indexOfCurrentKPI period:theMonitoringPeriod datasource:cellDatasource];
        
#if TARGET_OS_IPHONE
        UIImage* theImage = [self extractImageFromGraph:currentBarChart.barChart];
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
        NSImage* theImage = [self extractImageFromGraph:currentBarChart.barChart];
#endif
        [barCharImages addObject:theImage];
        
        indexOfCurrentKPI = [dictionary getNextKPIByDomain:indexOfCurrentKPI techno:cellDatasource.theCell.cellTechnology];
    }
    return barCharImages;
}

- (KPIBarChart*) createChart:(NSIndexPath*) indexOfCurrentKPI
                      period:(DCMonitoringPeriodView) monitoringPeriod
                  datasource:(CellKPIsDataSource*) cellDatasource {
    NSArray* KPIValues = [self getKPIValues:indexOfCurrentKPI period:monitoringPeriod datasource:cellDatasource];
    KPI* theKPI = [self getKPI:indexOfCurrentKPI technology:cellDatasource.theCell.cellTechnology];
    
    // Create the chart and initialize it
    KPIBarChart* currentChart = [[KPIBarChart alloc] init:KPIValues KPI:theKPI date:cellDatasource.requestDate monitoringPeriod:monitoringPeriod];
    
    if (theKPI.relatedKPI != Nil) {
        KPIDictionary* dictionary = [KPIDictionaryManager sharedInstance].defaultKPIDictionary;
        KPI* theRelatedKPI = [dictionary findKPIbyInternalName:theKPI.relatedKPI];
        if (theRelatedKPI != Nil) {
            NSDictionary* allKPIValues = [cellDatasource getKPIsForMonitoringPeriod:monitoringPeriod];
            if (allKPIValues != Nil) {
                NSArray* relatedKPIValues = allKPIValues[theRelatedKPI.internalName];
                [currentChart setRelatedKPI:theRelatedKPI KPIValues:relatedKPIValues];
            }
        }
    }
    
    [self configureChartStyle:currentChart];
    
    [currentChart setKPIIndex:indexOfCurrentKPI];
    [currentChart prepareChart];
    return currentChart;
}

- (KPI*) getKPI:(NSIndexPath*)  index technology:(DCTechnologyId) theTechnology {
    KPIDictionaryManager* dc = [KPIDictionaryManager sharedInstance];
    return [dc.defaultKPIDictionary getKPIbyDomain:index techno:theTechnology];
}

- (NSArray*) getKPIValues:(NSIndexPath*) index period:(DCMonitoringPeriodView) monitoringPeriod datasource:(CellKPIsDataSource*) cellDatasource{
    KPI* cellKPI = [self getKPI:index technology:cellDatasource.theCell.cellTechnology];
    NSDictionary* KPIValues = [cellDatasource getKPIsForMonitoringPeriod:monitoringPeriod];
    
    if (KPIValues != Nil) {
        return KPIValues[cellKPI.internalName];
    } else {
        return Nil;
    }
}


- (void) initDefaultForChart {
    _titleFontSize = 10.0f;
    _yTitleDisplacement = -8.0f;
    _titleWithKPIDomain = TRUE;
    
    _xAxisFontSize = 12.0f;
    _yAxisFontSize = 12.0f;
    
    _fillWithGradient = [UserPreferences sharedInstance].cellDashboardGradiant;
}



- (void) configureChartStyle:(KPIBarChart*) theChart {
    theChart.xAxisAlignment = CPTTextAlignmentRight;
    theChart.titleFontSize = self.titleFontSize;
    theChart.yTitleDisplacement = self.yTitleDisplacement;
    theChart.titleWithKPIDomain = self.titleWithKPIDomain;
    
    theChart.xAxisFontSize = self.xAxisFontSize;
    theChart.yAxisFontSize = self.yAxisFontSize;
    
    theChart.fillWithGradient = self.fillWithGradient;
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
