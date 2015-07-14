//
//  ZoneAverageDetailsViewController.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 26/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "CellsOnCoverageViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "DataCenter.h"
#import "KPIBarChart.h"
#import "ZoneKPIDataSource.h"
#import "KNPathTableViewController.h"

@class KPI;
@class KPIBarChart;
@class ZoneAverageDetailsCell;
@class ZoneAveragePeriodDetailsCell;

@class WorstKPIDataSource;


@interface ZoneAverageDetailsViewController : KNPathTableViewController <barChartNotification> 
- (void) initialize:(WorstKPIDataSource*) theDatasource initialIndex:(NSUInteger) index;

@property (weak, nonatomic) IBOutlet UITableView *theTable;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *FirstChart;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *SecondChart;
@property (weak, nonatomic) IBOutlet UIView *theGraphContainer;



@end

