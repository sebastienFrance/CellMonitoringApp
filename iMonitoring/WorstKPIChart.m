//
//  WorstKPIChart.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 20/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WorstKPIChart.h"
#import "KPI.h"
#import "CellWithKPIValues.h"

@interface WorstKPIChart()

@property (nonatomic) NSUInteger numberOfGreen;
@property (nonatomic) NSUInteger numberOfYellow;
@property (nonatomic) NSUInteger numberOfOrange;
@property (nonatomic) NSUInteger numberOfRed;
@property (nonatomic) NSUInteger numberOfWhite;
@property (nonatomic) NSUInteger grandTotalNumberOfObjects;
@property (nonatomic) Boolean barPlotIsAnimating;
@property (nonatomic) CPTPieChart* pieChart;
@property (nonatomic) NSString* chartId;

@end

@implementation WorstKPIChart


#pragma mark - Constructor

+ (WorstKPIChart*) instantiateChart:(NSArray*) KPIValues isLastWorst:(Boolean) lastWorstKPI {
    // Create the chart and initialize it
    NSUInteger numberOfGreen = 0;
    NSUInteger numberOfYellow = 0;
    NSUInteger numberOfOrange = 0;
    NSUInteger numberOfRed = 0;
    NSUInteger numberOfWhite = 0;
    
    for (CellWithKPIValues* cellData in KPIValues) {    
        
        NSNumber* value;
        if (lastWorstKPI == true) {
            value = cellData.lastKPIValue;
        } else {
            value = cellData.averageValue;
        }
        KPIColorCodeId theColor = [cellData.theKPI getColorIdFromNumber:value];
        switch (theColor) {
            case KPIColorgreen: {
                numberOfGreen++;
                break;
            }
            case KPIColoryellow: {
                numberOfYellow++;
                break;
            }
            case KPIColororange: {
                numberOfOrange++;
                break;
            }
            case KPIColorred: {
                numberOfRed++;
                break;
            }
            case KPIColorwhite: {
                numberOfWhite++;
                break;
            }
            default: {
                // unknown color!  
            }
        }
    }
    CellWithKPIValues* firstCellData = KPIValues[0];
    NSString* chartIdentifier = firstCellData.theKPI.internalName;
    
    WorstKPIChart* currentChart = [[WorstKPIChart alloc] init:KPIValues.count
                                                  numberOfRed:numberOfRed
                                               numberOfOrange:numberOfOrange
                                               numberOfYellow:numberOfYellow
                                                numberOfGreen:numberOfGreen
                                                numberOfWhite:numberOfWhite
                                                   identifier:chartIdentifier];
    
    return currentChart;
}


- (id) init:(NSUInteger) grandTotal
            numberOfRed:(NSUInteger) red
            numberOfOrange:(NSUInteger) orange
            numberOfYellow:(NSUInteger) yellow
            numberOfGreen:(NSUInteger) green
            numberOfWhite:(NSUInteger) white
            identifier:(NSString*) chartIdentifier {
    if (self = [super init]) {
        
        _grandTotalNumberOfObjects = grandTotal;
        
        _numberOfRed = red;
        _numberOfOrange = orange;
        _numberOfYellow = yellow;
        _numberOfGreen = green;
        _numberOfWhite = white;
        
        // init title with default values
        _titleColor = [CPTColor whiteColor];
        _titleFontSize = 16.0f;
        _titleAlignment = CPTTextAlignmentCenter;
        _xTitleDisplacement = 0.0f;
        _yTitleDisplacement = -20.0f;
        _titlePlotAreaFrameAnchor = CPTRectAnchorTop;
        _title = Nil;
        
        // default for Pie
        _pieRadius = 65.0;

        _paddingLeft    = -120.0;
        _paddingTop	    = 10.0;

        
        // default for Legend
         _legendCornerRadius = 5.0;
         _legendFontSize = 14.0;
         _legendXDisplacement = 80.0;
         _legendYDisplacement = 5.0;
        
        _fillWithGradient = TRUE;
        
        _chartId = chartIdentifier;
    }
    
    return self;
}

#pragma mark - Display chart

- (void) displayChart:(CPTGraphHostingView*) hostingView  withAnimate:(Boolean) animate {
    [self initializePieChart];
    
	hostingView.hostedGraph = self.pieGraph;
    
    if (animate) {
        [self animateIt];
    } else {
        [self addLegend];
    }
}

- (void) animateIt {
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    [anim setDuration:0.8f];
    
    anim.toValue = @0.0f;
    anim.fromValue = @300.0f;
    anim.removedOnCompletion = NO;
    anim.delegate = self;
    anim.fillMode = kCAFillModeForwards;
    
    [self.pieChart addAnimation:anim forKey:@"grow"];
    self.barPlotIsAnimating = TRUE;
}

-(void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
	self.barPlotIsAnimating = NO;
    [self addLegend];
}

- (void) prepareChart {
    // Create pieChart from theme
    [self initializePieChart];
    [self addLegend];

}


-(void) unregisterDelegates {
    self.pieChart.delegate = Nil;
    self.pieGraph.legend.delegate = Nil;
}

- (void) setPieRadius:(float)pieRadius {
    _pieRadius = pieRadius;
    if (self.pieChart != Nil) {
        self.pieChart.pieRadius = pieRadius;
    }
}

- (void) setLegendXDisplacement:(float)legendXDisplacement {
    _legendXDisplacement = legendXDisplacement;
    if (self.pieGraph != Nil) {
        self.pieGraph.legendDisplacement = CGPointMake(self.legendXDisplacement, self.legendYDisplacement);
    }
}


- (void) setLegendYDisplacement:(float)legendYDisplacement {
    _legendYDisplacement =legendYDisplacement;
    if (self.pieGraph != Nil) {
        self.pieGraph.legendDisplacement = CGPointMake(self.legendXDisplacement, self.legendYDisplacement);
    }
}


- (void) initializePieChart {
    // Create pieChart from theme
	self.pieGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    
    CPTTheme *theme = Nil;
    if (self.fillWithGradient) {
        theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    } else {
        theme = [CPTTheme themeNamed:kCPTPlainBlackTheme];
    }
	[self.pieGraph applyTheme:theme];
    
	self.pieGraph.plotAreaFrame.masksToBorder = YES;
    
    self.pieGraph.plotAreaFrame.borderLineStyle = nil;
	self.pieGraph.plotAreaFrame.cornerRadius	= 0.0f;
    self.pieGraph.plotAreaFrame.paddingLeft	    = self.paddingLeft;
    self.pieGraph.plotAreaFrame.paddingTop	    = self.paddingTop;
    
	self.pieGraph.paddingLeft   = 0.0;
	self.pieGraph.paddingTop	= 0.0;
	self.pieGraph.paddingRight  = 0.0;
	self.pieGraph.paddingBottom = 0.0;
    self.pieGraph.borderWidth   = 0;
    self.pieGraph.axisSet = nil;
    
    // Graph title
    [self configureTitle];
	
    // Add pie chart
	self.pieChart                    = [[CPTPieChart alloc] init];
	self.pieChart.dataSource         = self;
    self.pieChart.delegate           = self;
	self.pieChart.pieRadius          = self.pieRadius; // Taille du pie chart (Rayon)
	self.pieChart.identifier         = self.chartId;
	self.pieChart.startAngle         = 0;//M_PI_4;
	self.pieChart.sliceDirection     = CPTPieDirectionCounterClockwise;
	self.pieChart.borderLineStyle    = Nil; // [CPTLineStyle lineStyle];
	self.pieChart.labelOffset		= 5.0;
    
    [self.pieGraph addPlot:self.pieChart];
}


#pragma mark - Configure chart

- (void) addLegend {
    // Add legend
    CPTLegend *theLegend        = [CPTLegend legendWithGraph:self.pieGraph];
    theLegend.numberOfColumns   = 1;
    theLegend.fill              = [CPTFill fillWithColor:[CPTColor whiteColor]];
    theLegend.borderLineStyle   = [CPTLineStyle lineStyle];
    theLegend.cornerRadius      = self.legendCornerRadius;
    theLegend.delegate          = self; // CPTLegendDelegate
    
	CPTMutableTextStyle *legendTextStyle = [CPTMutableTextStyle textStyle];
	legendTextStyle.color = [CPTColor blackColor];
    legendTextStyle.fontSize = self.legendFontSize;
    
    theLegend.textStyle = legendTextStyle;
    
    self.pieGraph.legend = theLegend;
    
    self.pieGraph.legendAnchor = CPTRectAnchorBottom;
    self.pieGraph.legendDisplacement = CGPointMake(self.legendXDisplacement, self.legendYDisplacement);

}

- (void) configureTitle {
    CPTMutableTextStyle *textStyle  = [CPTMutableTextStyle textStyle];
	textStyle.color                 = self.titleColor;
	textStyle.fontSize				= self.titleFontSize;
	textStyle.textAlignment			= self.titleAlignment;

	self.pieGraph.titleTextStyle            = textStyle;
	self.pieGraph.titleDisplacement         = CGPointMake(self.xTitleDisplacement, self.yTitleDisplacement);
	self.pieGraph.titlePlotAreaFrameAnchor  = self.titlePlotAreaFrameAnchor;
    
    // Configure title if requested
    if (self.title != nil) {
        self.pieGraph.title = self.title;
    }
}

#pragma mark - CPTPlotDataSource protocol
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return 5;
}

- (CPTFill *) sliceFillForPieChart:(CPTPieChart *) 	pieChart recordIndex:(NSUInteger) index {
    switch (index) {
        case KPIColorgreen: {
            return [self getFilling:[CPTColor greenColor] endingColor:[CPTColor colorWithComponentRed:0.0 green:0.3 blue:0.0 alpha:1.0]];
            break;
        }
        case KPIColoryellow: {
            return [self getFilling:[CPTColor yellowColor] endingColor:[CPTColor colorWithComponentRed:0.7 green:0.7 blue:0.0 alpha:1.0]];
            break;
        }
        case KPIColororange: {
            return [self getFilling:[CPTColor orangeColor] endingColor:[CPTColor colorWithComponentRed:0.5 green:0.5 blue:0.0 alpha:1.0]];
            break;
        }
        case KPIColorred: {
            return [self getFilling:[CPTColor redColor] endingColor:[CPTColor colorWithComponentRed:0.3 green:0.0 blue:0.0 alpha:1.0]];
            break;
        }
        case KPIColorwhite: {
            return [self getFilling:[CPTColor lightGrayColor] endingColor:[CPTColor colorWithGenericGray:1.0/3.0]];
            break;
        }
        default: {
            return Nil;
        }
    }
    
}

- (CPTFill*) getFilling:(CPTColor*) baseColor {
    if (self.fillWithGradient) {
        return [CPTFill fillWithGradient:[CPTGradient gradientWithBeginningColor:baseColor endingColor:[CPTColor blackColor]]];
    } else {
        return [CPTFill fillWithColor:baseColor];
    }
}
                   
- (CPTFill*) getFilling:(CPTColor*) baseColor endingColor:(CPTColor*) endingColor {
    if (self.fillWithGradient) {
        return [CPTFill fillWithGradient:[CPTGradient gradientWithBeginningColor:baseColor endingColor:endingColor]];
    } else {
        return [CPTFill fillWithColor:baseColor];
    }
}


-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
	NSDecimalNumber *num = nil;
    
	if ( [plot isKindOfClass:[CPTPieChart class]] ) {
		if ( index >= 5 ) {
			return nil;
		}
        
		if ( fieldEnum == CPTPieChartFieldSliceWidth ) {
            NSUInteger counter;
            switch (index) {
                case KPIColorgreen: {
                    counter = self.numberOfGreen;
                    break;
                }
                case KPIColoryellow: {
                    counter = self.numberOfYellow;
                    break;
                }
                case KPIColororange: {
                    counter = self.numberOfOrange;
                    break;
                }
                case KPIColorred: {
                    counter = self.numberOfRed;
                    break;
                }
                case KPIColorwhite: {
                    counter = self.numberOfWhite;
                    break;
                }
                default: {
                    counter = 0;
                }
            }
			return @(counter);
		}
		else {
			num = (NSDecimalNumber *)[NSDecimalNumber numberWithUnsignedInteger:index];
		}
	}
    
	return num;
}


- (NSString *) legendTitleForPieChart:(CPTPieChart *) pieChart recordIndex:(NSUInteger) index {
    
    NSString* legendTitle;
    
    switch (index) {
        case KPIColorgreen: {
            legendTitle = [NSString stringWithFormat:@"%lu (%.2f%%)",(unsigned long)self.numberOfGreen, (((float)self.numberOfGreen / (float)self.grandTotalNumberOfObjects)*100)];
            break;
        }
        case KPIColoryellow: {
            legendTitle = [NSString stringWithFormat:@"%lu (%.2f%%)", (unsigned long)self.numberOfYellow, (((float)self.numberOfYellow / (float)self.grandTotalNumberOfObjects)*100)];
            break;
        }
        case KPIColororange: {
            legendTitle = [NSString stringWithFormat:@"%lu (%.2f%%)", (unsigned long)self.numberOfOrange, (((float)self.numberOfOrange / (float)self.grandTotalNumberOfObjects)*100)];
            break;
        }
        case KPIColorred: {
            legendTitle = [NSString stringWithFormat:@"%lu (%.2f%%)", (unsigned long)self.numberOfRed, (((float)self.numberOfRed / (float)self.grandTotalNumberOfObjects)*100)];
            break;
        }
        case KPIColorwhite: {
            legendTitle = [NSString stringWithFormat:@"%lu (%.2f%%)", (unsigned long)self.numberOfWhite, (((float)self.numberOfWhite / (float)self.grandTotalNumberOfObjects)*100)];
            break;
        }
        default:
            legendTitle = @"unknown";
            
    }
    
    return legendTitle;
}

-(CGFloat)radialOffsetForPieChart:(CPTPieChart *)the_piePlot recordIndex:(NSUInteger)index
{
	CGFloat offset = 0.0;
    
	return offset;
}



-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    return Nil;
    
}

#pragma mark - CPTPieChartDelegate Protocol
-(void)pieChart:(CPTPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)index {
    if (self.subscriber != Nil) {
        [self.subscriber selectedSlice:index];
    }
}

#pragma mark - CPTLegendDelegate Protocol
-(void)legend:(CPTLegend *)legend legendEntryForPlot:(CPTPlot *)plot wasSelectedAtIndex:(NSUInteger)index {
    if (self.subscriber != Nil) {
        [self.subscriber selectedSlice:index];
    }
}


@end
