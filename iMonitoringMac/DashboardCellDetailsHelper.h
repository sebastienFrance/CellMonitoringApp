//
//  DashboardCellDetailsHelper.h
//  iMonitoring
//
//  Created by sébastien brugalières on 12/01/2014.
//
//

#import <Foundation/Foundation.h>
#import "MonitoringPeriodUtility.h"

@class CellKPIsDataSource;

@interface DashboardCellDetailsHelper : NSObject

@property (nonatomic) float titleFontSize;

@property (nonatomic) float yTitleDisplacement;
@property (nonatomic) float xAxisFontSize;
@property (nonatomic) float yAxisFontSize;
@property (nonatomic) Boolean titleWithKPIDomain;
@property (nonatomic) Boolean fillWithGradient;

- (id) init:(CGFloat) theWidth height:(CGFloat) theHeight;
- (NSArray*) createChartForMonitoringPeriod:(CellKPIsDataSource*) cellDatasource monitoringPeriod:(DCMonitoringPeriodView) theMonitoringPeriod;

@end
