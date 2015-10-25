//
//  DetailsCellKPIViewController.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 21/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestUtilities.h"
#import <CorePlot/ios/CorePlot.h>
#import "KPIDataSource.h"
#import "KPIBarChart.h"
#import <MessageUI/MFMailComposeViewController.h>

#import "KNPathTableViewController.h"
#import "CellKPIDatasource.h"

@class  KPI;
@class KPIBarChart;
@class CellDetailsCellKPIViewCell;

@interface DetailsCellWithChartViewController : KNPathTableViewController <barChartNotification>

@property (nonatomic) CellKPIDatasource* datasource;

@property (weak, nonatomic) IBOutlet UITableView *theKPITable;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *theSecondGraph;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *theGraph;
@property (weak, nonatomic) IBOutlet UIView *theGraphContainer;


- (void) initialize:(CellKPIsDataSource*) cellDatasource initialMonitoringPeriod:(DCMonitoringPeriodView) monitoringPeriod initialIndex:(NSIndexPath*) index;


- (float) getRowHeightForDetailedView;
- (float) getRowHeightForSimpleView;

-(void) customizeChartDisplayProperties:(KPIBarChart*) theChart;

@end

