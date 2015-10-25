//
//  WorstKPIChart.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 20/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <CorePlot/ios/CorePlot.h>
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
#import <CorePlot/CorePlot.h>
#endif

@protocol pieChartNotification;

@interface WorstKPIChart : NSObject<CPTPlotDataSource, CPTPieChartDelegate, CPTLegendDelegate>
@property (nonatomic) NSString* title;
@property (nonatomic) CPTColor* titleColor;
@property (nonatomic) float titleFontSize;
@property (nonatomic) CPTTextAlignment titleAlignment;
@property (nonatomic) float xTitleDisplacement;
@property (nonatomic) float yTitleDisplacement;
@property (nonatomic) CPTRectAnchor titlePlotAreaFrameAnchor;
@property (nonatomic) CPTXYGraph*  pieGraph;

// property for the Pie
@property (nonatomic) float pieRadius;
@property (nonatomic) Boolean fillWithGradient;

@property (nonatomic) float paddingLeft;
@property (nonatomic) float paddingTop;


// properties for Legend
@property (nonatomic) float legendCornerRadius;
@property (nonatomic) float legendFontSize;
@property (nonatomic) float legendXDisplacement;
@property (nonatomic) float legendYDisplacement;

@property (nonatomic) NSIndexPath* KPIIndex;

@property (nonatomic, weak) id<pieChartNotification> subscriber;

- (void) displayChart:(CPTGraphHostingView*) viewForGraph withAnimate:(Boolean) animate; 

- (void) prepareChart;


-(void) unregisterDelegates;

+ (WorstKPIChart*) instantiateChart:(NSArray*) KPIValues isLastWorst:(Boolean) lastWorstKPI;

@end

@protocol pieChartNotification <NSObject>

- (void) selectedSlice:(NSUInteger) index;

@end
