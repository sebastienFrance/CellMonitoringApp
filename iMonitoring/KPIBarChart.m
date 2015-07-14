//
//  KPIBarChart.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 27/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KPIBarChart.h"
#import "CellKPIsDataSource.h"
#import "CellMonitoring.h"
#import "KPIDictionary.h"
#import "KPI.h"
#import "DateUtility.h"

@interface KPIBarChart()

@property (nonatomic) NSArray *theKPIValues;
@property (nonatomic) KPI* theKPI;
@property (nonatomic) NSDate* theDate;
@property (nonatomic) DCMonitoringPeriodView theMonitoringPeriod;
@property (nonatomic) float theMinKPIValue;
@property (nonatomic) float theMaxKPIValue;

@property (nonatomic) NSString* title;
@property (nonatomic) NSArray* theRelatedKPIValues;
@property (nonatomic) KPI* theRelatedKPI;
@property (nonatomic) float theRelatedKPIMinValue;
@property (nonatomic) float theRelatedKPIMaxValue;
@property (nonatomic) DCMonitoringPeriodView monitoringPeriod;
@property (nonatomic) CPTXYPlotSpace* plotSpace;
@property (nonatomic) CPTXYPlotSpace* secondPlotSpace;
@property (nonatomic) CPTBarPlot* barPlot;
@property (nonatomic) Boolean barPlotIsAnimating;
@property (nonatomic) CPTScatterPlot *plot;
@property (nonatomic) Boolean alreadyDisplayed;

@end

@implementation KPIBarChart

- (id) init:(NSArray*) KPIValues KPI:(KPI*) theKPI date:(NSDate*) theDate monitoringPeriod:(DCMonitoringPeriodView) theMonitoringPeriod {
    if (self = [super init]) {
        _theKPIValues = KPIValues;
        _theKPI = theKPI;
        _theDate = theDate;
        _monitoringPeriod = theMonitoringPeriod;

        NSArray* minMax = [Utility getMinMaxValue:_theKPIValues];
        NSNumber* value = minMax[MinArrayEntry];
        _theMinKPIValue = [value floatValue];
        value = minMax[MaxArrayEntry];
        _theMaxKPIValue = [value floatValue];

        // init title with default values
        _titleColor = [CPTColor whiteColor];
        _titleFontSize = 16.0f;
        _titleAlignment = CPTTextAlignmentCenter;
        _xTitleDisplacement = 0.0f;
        _yTitleDisplacement = -20.0f;
        _titlePlotAreaFrameAnchor = CPTRectAnchorTop;
        _titleWithKPIDomain = FALSE;
        
        // init default values for xAxis
        _xAxisColor = [CPTColor whiteColor];
        _xAxisFontSize = 14.0f;
        _xAxisAlignment = CPTTextAlignmentCenter;
        
        // init default values for yAxis
        _yAxisColor = [CPTColor whiteColor];
        _yAxisFontSize = 14.0f;
        _yAxisAlignment = CPTTextAlignmentCenter;
        
        _fillWithGradient = TRUE;
        
        _theRelatedKPI = Nil;
        _theRelatedKPIValues = Nil;
    }
    
    return self;
}


- (void) setRelatedKPI:(KPI *)theRelatedKPI KPIValues:(NSArray *)theKPIValues {
    _theRelatedKPI = theRelatedKPI;
    _theRelatedKPIValues = theKPIValues;

    NSArray* minMax = [Utility getMinMaxValue:_theRelatedKPIValues];
    NSNumber* value = minMax[MinArrayEntry];
    _theRelatedKPIMinValue = [value floatValue];
    value = minMax[MaxArrayEntry];
    _theRelatedKPIMaxValue = [value floatValue];
}

- (void) displayChart:(CPTGraphHostingView*) hostingView  withAnimate:(Boolean) animate {
    
    [self buildChart:hostingView];
    
    if (animate) {
        [self animateIt];
    } else {
        [self addChartToPlot];
    }
}

- (void) prepareChart {
	// Create barChart from theme 
	_barChart = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme;

    if (self.fillWithGradient) {
        theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    } else {
        theme = [CPTTheme themeNamed:kCPTPlainBlackTheme];
    }
    
	[self.barChart applyTheme:theme];
    
	// Border
	self.barChart.plotAreaFrame.borderLineStyle = nil;
	self.barChart.plotAreaFrame.cornerRadius	   = 0.0f;
    
	// Paddings
	self.barChart.paddingLeft   = 0.0f;
	self.barChart.paddingRight  = 0.0f;
	self.barChart.paddingTop	= 0.0f;
	self.barChart.paddingBottom = 0.0f;
    
    // Offset pour placer les coordoonees du graph
	self.barChart.plotAreaFrame.paddingLeft	 = [KPIBarChart getPadding:_theKPI maxValue:self.theMaxKPIValue];
	self.barChart.plotAreaFrame.paddingTop	 = 20.0;
    
    if (_theRelatedKPI != Nil) {
        self.barChart.plotAreaFrame.paddingRight	 = [KPIBarChart getPadding:_theRelatedKPI maxValue:_theRelatedKPIMaxValue];
    } else {
        self.barChart.plotAreaFrame.paddingRight	 = 15.0;
    }
    
	self.barChart.plotAreaFrame.paddingBottom = 35.0;
    
	// Graph title
    [self configureTitle];
    
    
	// Add plot space for horizontal bar charts
	_plotSpace = (CPTXYPlotSpace *)self.barChart.defaultPlotSpace;
    
    float minAxis = 0.0;
    if ([_theKPI.unit isEqualToString:@"%"]) {
        
        float intervalSize = ((self.theMaxKPIValue - minAxis)/100.0)/4;
        
        minAxis = self.theMinKPIValue - intervalSize;
        if (minAxis <= 0) {
            minAxis = 0.0;
        }


        _plotSpace.yRange = [CPTPlotRange plotRangeWithLocationDecimal:[[NSDecimalNumber alloc] initWithFloat:minAxis/100.0].decimalValue
                                                         lengthDecimal:[[NSDecimalNumber alloc] initWithFloat:((self.theMaxKPIValue - minAxis)/100.0)].decimalValue];
    } else {
        if (self.theMinKPIValue == self.theMaxKPIValue) {
            _plotSpace.yRange = [CPTPlotRange plotRangeWithLocationDecimal:CPTDecimalFromFloat(0) lengthDecimal:CPTDecimalFromFloat(10)];
        } else {
            
            if (self.theMinKPIValue >= 0) {
                _plotSpace.yRange = [CPTPlotRange plotRangeWithLocationDecimal:CPTDecimalFromFloat(0) lengthDecimal:CPTDecimalFromFloat(self.theMaxKPIValue)];
            } else {
                _plotSpace.yRange = [CPTPlotRange plotRangeWithLocationDecimal:CPTDecimalFromFloat(0) lengthDecimal:CPTDecimalFromFloat(self.theMinKPIValue)];
            }
        }
    }
    
    
    CPTXYAxis* xAxis = [[CPTXYAxis alloc] initWithFrame:CGRectZero];
    CPTXYAxis* yAxis = [[CPTXYAxis alloc] initWithFrame:CGRectZero];
    xAxis.plotSpace = _plotSpace;
    yAxis.plotSpace = _plotSpace;
    
    [self configureXAxis:xAxis min:minAxis plotSpace:_plotSpace];
    [self configureYAxis:yAxis min:minAxis];
    
    // Configure the Bar Plot
    _barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blueColor] horizontalBars:NO];
	_barPlot.baseValue  = @0;
	_barPlot.dataSource = self;
    _barPlot.delegate = self;
	_barPlot.barOffset  = @-0.25f;
	_barPlot.identifier = @"Bar Plot 1";
    
    if (_theRelatedKPI != Nil) {
        CPTXYAxis* yRightAxis = [self buildRelatedKPIChart];
        self.barChart.axisSet.axes = @[xAxis, yAxis, yRightAxis];
    } else {
        self.barChart.axisSet.axes = @[xAxis, yAxis];
    }

    [self addChartToPlot];
}

-(void) unregisterDelegates {
    _barPlot.delegate = Nil;
}

- (void) animateIt {
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    [anim setDuration:0.8f];
    
    anim.toValue = @0.0f;
    anim.fromValue = @300.0f;
    anim.removedOnCompletion = NO;
    anim.delegate = self;
    anim.fillMode = kCAFillModeForwards;
    
    [_barPlot addAnimation:anim forKey:@"grow"];
    [self addChartToPlot];
    _barPlotIsAnimating = TRUE;
}


- (void) addChartToPlot {
    [self.barChart addPlot:_barPlot toPlotSpace:_plotSpace];
    
    if (_theRelatedKPI != Nil) {
        [self.barChart addPlot:_plot toPlotSpace:_secondPlotSpace];
    }
}

-(void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
	_barPlotIsAnimating = NO;
    //	[_barPlot performSelector:@selector(reloadData) withObject:nil afterDelay:0.4];
}


-(void)buildChart:(CPTGraphHostingView*) theHostingView {
    [self prepareChart];
    if (theHostingView != nil) {
        theHostingView.hostedGraph = self.barChart;
    }
}

+ (float) getPadding:(KPI*) theKPI maxValue:(float) theMaxValue {

    if ([theKPI.unit isEqualToString:@"%"]) {
        return 60.0;
    }
    
    if (theMaxValue < 10.0) {
        return 20.0;
    } else if (theMaxValue < 100.0) {
        return 26.0;
    } else if (theMaxValue < 1000.0) {
        return 35.0;
    } else if (theMaxValue < 10000.0) {
        return 42.0;
    } else if (theMaxValue < 100000.0) {
        return 51.0;
    } else {
        return 60.0;
    }
}


- (CPTXYAxis*) buildRelatedKPIChart {
    _secondPlotSpace = [[CPTXYPlotSpace alloc] init];
    
    float minAxis = 0.0;
    if ([_theRelatedKPI.unit isEqualToString:@"%"]) {
        
        float intervalSize = ((_theRelatedKPIMaxValue - minAxis)/100.0)/4;
        
        minAxis = _theRelatedKPIMinValue - intervalSize;
        if (minAxis <= 0) {
            minAxis = 0.0;
        }
        
        _secondPlotSpace.yRange = [CPTPlotRange plotRangeWithLocationDecimal:CPTDecimalFromFloat(minAxis/100.0)
                                                               lengthDecimal:CPTDecimalFromFloat((_theRelatedKPIMaxValue - minAxis)/100.0)];
        
    } else {
        
        if (_theRelatedKPIMinValue >= 0) {
            _secondPlotSpace.yRange = [CPTPlotRange plotRangeWithLocationDecimal:CPTDecimalFromFloat(0)
                                                                   lengthDecimal:CPTDecimalFromFloat(_theRelatedKPIMaxValue)];
        } else {
            _secondPlotSpace.yRange = [CPTPlotRange plotRangeWithLocationDecimal:CPTDecimalFromFloat(0)
                                                                   lengthDecimal:CPTDecimalFromFloat(_theRelatedKPIMinValue)];
        }
    }
    [self configurePlotSpace:_secondPlotSpace];

     [self.barChart addPlotSpace:_secondPlotSpace];
    // Configure the Scatter Plot
    _plot = [[CPTScatterPlot alloc] init];
    _plot.dataSource = self;
    _plot.identifier = @"mainplot";
    
    CPTMutableLineStyle* lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor lightGrayColor];
    lineStyle.lineWidth = 3.0f;
    _plot.dataLineStyle = lineStyle;
    
    CPTPlotSymbol* thePlotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    thePlotSymbol.fill = [CPTFill fillWithColor:[CPTColor  darkGrayColor]];
    thePlotSymbol.size = CGSizeMake(5.0, 5.0);
    _plot.plotSymbol = thePlotSymbol;
    
    CPTXYAxis* yRightAxis = [[CPTXYAxis alloc] initWithFrame:CGRectZero];
    yRightAxis.plotSpace = _secondPlotSpace;
    [self configureYRightAxis:yRightAxis min:minAxis];
    
    return yRightAxis;
}


- (void) configureTitle {
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
	textStyle.color					  = _titleColor;
	textStyle.fontSize				  = _titleFontSize;
	textStyle.textAlignment			  = _titleAlignment;
	self.barChart.titleTextStyle			  = textStyle;
	self.barChart.titleDisplacement		  = CGPointMake(_xTitleDisplacement, _yTitleDisplacement);
	self.barChart.titlePlotAreaFrameAnchor = _titlePlotAreaFrameAnchor;
    // Configure title if requested

     if (_theRelatedKPI != Nil) {
         if (_titleWithKPIDomain) {
             self.barChart.title = [NSString stringWithFormat:@"%@ - %@ vs %@", _theKPI.domain, _theKPI.name, _theRelatedKPI.name];
         } else{
             self.barChart.title = [NSString stringWithFormat:@"%@ vs %@",_theKPI.name, _theRelatedKPI.name];
         }
     } else {
         if (_titleWithKPIDomain) {
             self.barChart.title = [NSString stringWithFormat:@"%@ - %@", _theKPI.domain, _theKPI.name];
         } else {
             self.barChart.title = [NSString stringWithFormat:@"%@", _theKPI.name];
         }
     }
}

#pragma mark - configure Axis
- (void) configureXAxis:(CPTXYAxis *)x min:(float) minAxis plotSpace:(CPTXYPlotSpace*) plotSpace {
    NSMutableArray *customTickLocations;
    NSMutableArray *xAxisLabels;
    
    switch (_monitoringPeriod) {
        case last6Hours15MnView: {            
            plotSpace.xRange = [CPTPlotRange plotRangeWithLocationDecimal:CPTDecimalFromFloat(0.0f)
                                                            lengthDecimal:CPTDecimalFromFloat(24.0f)];
            xAxisLabels = [@[@"-6h", @"-5h", @"-4h", @"-3h", @"-2h", @"-1h", @"0h"] mutableCopy];
            customTickLocations = [@[[NSDecimalNumber numberWithInt:0], [NSDecimalNumber numberWithInt:4], [NSDecimalNumber numberWithInt:8], [NSDecimalNumber numberWithInt:12], [NSDecimalNumber numberWithInt:16], [NSDecimalNumber numberWithInt:20], [NSDecimalNumber numberWithInt:24]] mutableCopy];
            break;
        }
        case last24HoursHourlyView: {
            plotSpace.xRange = [CPTPlotRange plotRangeWithLocationDecimal:CPTDecimalFromFloat(0.0f)
                                                            lengthDecimal:CPTDecimalFromFloat(24.0f)];
            xAxisLabels = [@[@"-24h", @"-20h", @"-16h", @"-12h", @"-8h", @"-4h", @"0h"] mutableCopy];
            customTickLocations = [@[[NSDecimalNumber numberWithInt:0], [NSDecimalNumber numberWithInt:4], [NSDecimalNumber numberWithInt:8], [NSDecimalNumber numberWithInt:12], [NSDecimalNumber numberWithInt:16], [NSDecimalNumber numberWithInt:20], [NSDecimalNumber numberWithInt:24]] mutableCopy];
            break;
        }
        case Last7DaysDailyView: {
            NSUInteger numEntries = 7;
            plotSpace.xRange = [CPTPlotRange plotRangeWithLocationDecimal:CPTDecimalFromFloat(0.0f)
                                                            lengthDecimal:CPTDecimalFromFloat(numEntries)];
            customTickLocations = [[NSMutableArray alloc] initWithCapacity:numEntries];
            xAxisLabels = [[NSMutableArray alloc] initWithCapacity:numEntries];
            for (int i = 0; i < numEntries; i++) {
                [xAxisLabels addObject:[DateUtility getDayMinusNumberOfDay:self.theDate minusDay:numEntries-i shortFormat:TRUE]];
                [customTickLocations addObject:[NSDecimalNumber numberWithInt:(i+1)]];
            }
            break;
        }
        case Last4WeeksWeeklyView: {
            NSUInteger numEntries = 4;
            plotSpace.xRange = [CPTPlotRange plotRangeWithLocationDecimal:CPTDecimalFromFloat(0.0f)
                                                            lengthDecimal:CPTDecimalFromFloat(numEntries)];
            customTickLocations = [[NSMutableArray alloc] initWithCapacity:numEntries];
            xAxisLabels = [[NSMutableArray alloc] initWithCapacity:numEntries];
            for (int i = 0; i < numEntries; i++) {
                NSString* weekNumber = [NSString stringWithFormat:@"%@", [DateUtility getWeekMinusNumberOfWeek:self.theDate minusWeek:numEntries-i shortFormat:TRUE]];
                [xAxisLabels addObject:weekNumber];
                [customTickLocations addObject:[NSDecimalNumber numberWithInt:(i+1)]];
            }
            break;
        }
        case Last6MonthsMontlyView: {
            NSUInteger numEntries = 6;
            plotSpace.xRange = [CPTPlotRange plotRangeWithLocationDecimal:CPTDecimalFromFloat(0.0f)
                                                            lengthDecimal:CPTDecimalFromFloat(numEntries)];
            xAxisLabels = [[NSMutableArray alloc] initWithCapacity:numEntries];
            customTickLocations = [[NSMutableArray alloc] initWithCapacity:numEntries];
            for (int i = 0; i < numEntries; i++) {
                [xAxisLabels addObject:[DateUtility getMonthMinusNumberOfMonth:self.theDate minusMonth:numEntries-i  shortFormat:TRUE]];
                [customTickLocations addObject:[NSDecimalNumber numberWithInt:(i+1)]];
            }
            break;
        }
        default: {
            plotSpace.xRange = [CPTPlotRange plotRangeWithLocationDecimal:CPTDecimalFromFloat(0.0f)
                                                            lengthDecimal:CPTDecimalFromFloat(24.0f)];
            xAxisLabels = [@[@"-6h", @"-5h", @"-4h", @"-3h", @"-2h", @"-1h", @"0h"] mutableCopy];
            customTickLocations = [@[[NSDecimalNumber numberWithInt:0], [NSDecimalNumber numberWithInt:4], [NSDecimalNumber numberWithInt:8], [NSDecimalNumber numberWithInt:12], [NSDecimalNumber numberWithInt:16], [NSDecimalNumber numberWithInt:20], [NSDecimalNumber numberWithInt:24]] mutableCopy];
            break;
        }
    }
    
    
    // ------ configure X axis --------
    x.coordinate = CPTCoordinateX;
    x.tickDirection = CPTSignNegative;

    if ([_theKPI.unit isEqualToString:@"%"]) {
        x.orthogonalPosition = @(minAxis/100.0);
    } else {
        x.orthogonalPosition = @(minAxis);
    }
    
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
	textStyle.color					  = _xAxisColor;
	textStyle.fontSize				  = _xAxisFontSize;
	textStyle.textAlignment			  = _xAxisAlignment;
    x.labelTextStyle = textStyle;
    
	// Define some custom labels for the data elements
	x.labelingPolicy = CPTAxisLabelingPolicyNone;
    
	NSUInteger labelLocation	 = 0;
	NSMutableArray *customLabels = [NSMutableArray arrayWithCapacity:[xAxisLabels count]];
	for ( NSNumber *tickLocation in customTickLocations ) {
		CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:xAxisLabels[labelLocation++] textStyle:x.labelTextStyle];
		newLabel.tickLocation = tickLocation;
		newLabel.offset		  = 0;
		newLabel.rotation	  = M_PI / 4;
		[customLabels addObject:newLabel];
	}
    
	x.axisLabels = [NSSet setWithArray:customLabels];
    
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor lightGrayColor];
    lineStyle.lineWidth = 2.0f;
    x.axisLineStyle = lineStyle;
    x.majorTickLineStyle          = lineStyle;
    x.minorTickLineStyle          = lineStyle;

}

- (void) configureYAxis:(CPTXYAxis*) y min:(float) minAxis {
    y.coordinate = CPTCoordinateY;
    y.tickDirection = CPTSignNegative; // Allow to have the labels on left side of the axis

    y.minorTicksPerInterval = 1;
    y.orthogonalPosition = @0;
    y.axisTitle = Nil; // No title on y axis
    
    CPTMutableTextStyle* textStyle = [CPTMutableTextStyle textStyle];
	textStyle.color					  = _yAxisColor;
	textStyle.fontSize				  = _yAxisFontSize;
	textStyle.textAlignment			  = _yAxisAlignment;
    y.labelTextStyle = textStyle;
    
    y.labelFormatter = [KPIBarChart getLabelFormatter:_theKPI];
    
    
    // add Grid line on Y axis
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor  darkGrayColor];
    lineStyle.lineWidth = 2.0f;
    y.majorGridLineStyle = lineStyle;
    
    lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor lightGrayColor];
    lineStyle.lineWidth = 2.0f;
    y.axisLineStyle = lineStyle;
    y.majorTickLineStyle          = lineStyle;
    y.minorTickLineStyle          = lineStyle;
    y.labelingPolicy           = CPTAxisLabelingPolicyAutomatic ;

}

- (void) configureYRightAxis:(CPTXYAxis*) yAxis min:(float) minAxis  {
    yAxis.coordinate = CPTCoordinateY;
    yAxis.tickDirection = CPTSignPositive; // Allow to have the labels on right side of the axis
    
    yAxis.minorTicksPerInterval = 1;
    yAxis.orthogonalPosition = @0;
    yAxis.axisTitle = Nil; // No title on y axis
    
    CPTMutableTextStyle* textStyle = [CPTMutableTextStyle textStyle];
	textStyle.color					  = _yAxisColor;
	textStyle.fontSize				  = _yAxisFontSize;
	textStyle.textAlignment			  = CPTAlignmentLeft;
    yAxis.labelTextStyle = textStyle;
    
    
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor lightGrayColor];
    lineStyle.lineWidth = 2.0f;
    yAxis.axisLineStyle = lineStyle;
    yAxis.majorTickLineStyle          = lineStyle;
    yAxis.minorTickLineStyle          = lineStyle;
    yAxis.labelOffset             = 3.0f;
    yAxis.labelingPolicy           = CPTAxisLabelingPolicyAutomatic ;
    yAxis.labelAlignment = CPTAlignmentLeft;


    // used to set the Y axis on the right side of the graph
    yAxis.axisConstraints            = [CPTConstraints constraintWithUpperOffset:0.0];
 
    yAxis.labelFormatter = [KPIBarChart getLabelFormatter:_theRelatedKPI];
    
}


+ (NSNumberFormatter*) getLabelFormatter:(KPI*) theKPI {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init] ;
    if ([theKPI.unit isEqualToString:@"%"]) {
        [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
        [numberFormatter setMaximumFractionDigits:2];
    } else {
        [numberFormatter setNumberStyle:NSNumberFormatterNoStyle];
        [numberFormatter setMaximumFractionDigits:0];
    }
    return numberFormatter;
}


- (void) configurePlotSpace:(CPTXYPlotSpace*) plotSpace {
    switch (_monitoringPeriod) {
        case last6Hours15MnView: {
            plotSpace.xRange = [CPTPlotRange plotRangeWithLocationDecimal:CPTDecimalFromFloat(0.0f)
                                                            lengthDecimal:CPTDecimalFromFloat(24.0f)];
            break;
        }
        case last24HoursHourlyView: {
            plotSpace.xRange = [CPTPlotRange plotRangeWithLocationDecimal:CPTDecimalFromFloat(0.0f)
                                                            lengthDecimal:CPTDecimalFromFloat(24.0f)];
            break;
        }
        case Last7DaysDailyView: {
            NSUInteger numEntries = 7;
            plotSpace.xRange = [CPTPlotRange plotRangeWithLocationDecimal:CPTDecimalFromFloat(0.0f)
                                                            lengthDecimal:CPTDecimalFromFloat(numEntries)];
            break;
        }
        case Last4WeeksWeeklyView: {
            NSUInteger numEntries = 4;
            plotSpace.xRange = [CPTPlotRange plotRangeWithLocationDecimal:CPTDecimalFromFloat(0.0f)
                                                            lengthDecimal:CPTDecimalFromFloat(numEntries)];
            break;
        }
        case Last6MonthsMontlyView: {
            NSUInteger numEntries = 6;
            plotSpace.xRange = [CPTPlotRange plotRangeWithLocationDecimal:CPTDecimalFromFloat(0.0f)
                                                            lengthDecimal:CPTDecimalFromFloat(numEntries)];
            break;
        }
        default: {
            plotSpace.xRange = [CPTPlotRange plotRangeWithLocationDecimal:CPTDecimalFromFloat(0.0f)
                                                            lengthDecimal:CPTDecimalFromFloat(24.0f)];
            break;
        }
    }

}


#pragma mark - Plot Data Source Methods

// Return the number of bar we will have in the graph
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    switch (_monitoringPeriod) {
        case last6Hours15MnView: {
            return 24;
        }
        case last24HoursHourlyView: {
            return 24;
        }
        case Last7DaysDailyView: {
            return 7;
        }
        case Last4WeeksWeeklyView: {
            return 4;
        }
        case Last6MonthsMontlyView: {
            return 6;
        }
        default: {
            return 24;
        }
    }
}


-(CPTFill *) barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)index {
    
    if (_theKPI.hasDirection) {
        float floatValue = [self getKPIValue:index];
        if (_theKPI.isDirectionIncrease) {
            if (floatValue <= (_theKPI.lowThreshold / 100.0)) {
                return [self getFilling:[CPTColor greenColor]];
            } else if (floatValue <= (_theKPI.mediumThreshold / 100.0)) {
                return [self getFilling:[CPTColor yellowColor]];
            } else if (floatValue <= (_theKPI.highThreshold / 100.0)) {
                return [self getFilling:[CPTColor orangeColor]];
            } else {
                return [self getFilling:[CPTColor redColor]];
            }
        } else {
            if (floatValue >= (_theKPI.lowThreshold / 100.0)) {
                return [self getFilling:[CPTColor greenColor]];
            } else if (floatValue >= (_theKPI.mediumThreshold / 100.0)) {
                return [self getFilling:[CPTColor yellowColor]];
                
            } else if (floatValue >= (_theKPI.highThreshold / 100.0)) {
                return [self getFilling:[CPTColor orangeColor]];
            } else {
                return [self getFilling:[CPTColor redColor]];
            }
            
        }
        
    }
    
    return [self getFilling:[CPTColor blueColor]];
}


- (CPTFill*) getFilling:(CPTColor*) baseColor {
    if (self.fillWithGradient) {
        return [CPTFill fillWithGradient:[CPTGradient gradientWithBeginningColor:baseColor endingColor:[CPTColor blackColor]]];
    } else {
        return [CPTFill fillWithColor:baseColor];
    }
}

// Return a NSNumber that contains the value to be display for the bar in the chart
-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
	NSDecimalNumber *num = nil;
    
	if ( [plot isKindOfClass:[CPTBarPlot class]] ) {
		switch ( fieldEnum ) {
			case CPTBarPlotFieldBarLocation:
				num = (NSDecimalNumber *)[NSDecimalNumber numberWithUnsignedInteger:(index +1)];
				break;
                
			case CPTBarPlotFieldBarTip:
            {
                float floatValue = [self getKPIValue:index];
                num = (NSDecimalNumber *)[NSDecimalNumber numberWithFloat:floatValue];
 				break;
            }
		}
	} else {
        if ( [plot isKindOfClass:[CPTScatterPlot class]]) {
            switch ( fieldEnum ) {
                case CPTScatterPlotFieldX:
                    num = (NSDecimalNumber *)[NSDecimalNumber numberWithUnsignedInteger:(index +1)];
                    break;
                    
                case CPTScatterPlotFieldY:
                {
                    float floatValue = [self getRelatedKPIValue:index];
                    num = (NSDecimalNumber *)[NSDecimalNumber numberWithFloat:floatValue];
                    break;
                }
            }
        }
    }
    
	return num;
}



// Return the value of the KPI
// If it's a percent the returned value is 1 for 100%, 0.5 for 50%...
- (float) getKPIValue:(NSUInteger) index {
    
    if (index >= self.theKPIValues.count) {
        return 0.0;
    }
    
    NSNumber* value = self.theKPIValues[index];
    return [_theKPI getKPIValueFromNumber:value];
}

- (float) getRelatedKPIValue:(NSUInteger) index {
    
    if (index >= _theRelatedKPIValues.count) {
        return 0.0;
    }
    
    NSNumber* value = _theRelatedKPIValues[index];
    return [_theRelatedKPI getKPIValueFromNumber:value];
    
}



- (void) barPlot:(CPTBarPlot *) plot barWasSelectedAtRecordIndex:(NSUInteger) index {
    if (_subscriber != Nil) {
        [_subscriber selectedBar:index];
    }
}



@end
