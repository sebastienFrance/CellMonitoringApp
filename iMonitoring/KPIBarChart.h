//
//  KPIBarChart.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 27/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CellKPIsDataSource.h"
#if TARGET_OS_IPHONE
#import "CorePlot-CocoaTouch.h"
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
#import <CorePlot/CorePlot.h>
#endif
#import "Utility.h"

@class KPI;

@protocol barChartNotification;

@interface KPIBarChart: NSObject<CPTPlotDataSource, CPTBarPlotDelegate, CPTScatterPlotDataSource>

#pragma mark - Graph properties
@property (nonatomic, readonly) CPTXYGraph *barChart;
@property (nonatomic) CPTColor* titleColor;
@property (nonatomic) float titleFontSize;
@property (nonatomic) CPTTextAlignment titleAlignment;
@property (nonatomic) CPTRectAnchor titlePlotAreaFrameAnchor;
@property (nonatomic) Boolean titleWithKPIDomain;

@property (nonatomic) float xTitleDisplacement;
@property (nonatomic) CPTColor* xAxisColor;
@property (nonatomic) float xAxisFontSize;
@property (nonatomic) CPTTextAlignment xAxisAlignment;

@property (nonatomic) float yTitleDisplacement;
@property (nonatomic) CPTColor* yAxisColor;
@property (nonatomic) float yAxisFontSize;
@property (nonatomic) CPTTextAlignment yAxisAlignment;

@property (nonatomic) id<barChartNotification> subscriber;
@property (nonatomic) NSIndexPath* KPIIndex;

@property (nonatomic) Boolean fillWithGradient;


- (id) init:(NSArray*) KPIValues KPI:(KPI*) theKPI date:(NSDate*) theDate monitoringPeriod:(DCMonitoringPeriodView) theMonitoringPeriod;
- (void) setRelatedKPI:(KPI*) theRelatedKPI KPIValues:(NSArray*) theKPIValues;
- (void) displayChart:(CPTGraphHostingView*) hostingView  withAnimate:(Boolean) animate;
- (void) prepareChart;

- (void) unregisterDelegates;
@end

@protocol barChartNotification <NSObject>

- (void) selectedBar:(NSUInteger) index;

@end

