//
//  DashboardGraphicsHelper.h
//  iMonitoring
//
//  Created by sébastien brugalières on 04/01/2014.
//
//

#import <Foundation/Foundation.h>
#import "BasicTypes.h"
#import "MonitoringPeriodUtility.h"

@interface DashboardGraphicsHelper : NSObject

@property (nonatomic) float worstChartyTitleDisplacement;

@property (nonatomic) float worstCharttitleFontSize;
@property (nonatomic) float worstChartpieRadius;
@property (nonatomic) float worstChartlegendFontSize;
@property (nonatomic) float worstChartlegendXDisplacement;
@property (nonatomic) float worstChartlegendYDisplacement;
@property (nonatomic) Boolean worstChartfillWithGradient;

@property (nonatomic) float barChartyTitleDisplacement;
@property (nonatomic) float barChartitleFontSize;
@property (nonatomic) Boolean barCharfillWithGradient;


- (id) init:(CGFloat) theWidth height:(CGFloat) theHeight;

- (NSArray*) createAllWorstCharts:(NSDictionary*) KPIValues scope:(DashboardScopeId) scope;
- (NSArray*) createAllChartsWithAverageOnZone:(NSArray*) ListOfZoneKPI
                                  requestDate:(NSDate*) theRequestDate
                             monitoringPeriod:(DCMonitoringPeriodView) theMonitoringPeriod;
@end
