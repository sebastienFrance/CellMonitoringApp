//
//  DetailsWorstKPIsViewController.h
//  iMonitoring
//
//  Created by sébastien brugalières on 06/10/12.
//
//

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"
#import "KPIBarChart.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "WorstKPIChart.h"
#import "KNPathTableViewController.h"
#import "WorstKPIDataSource.h"

@class WorstKPIChart;
@class KPI;
@protocol WorstKPIItf;


@interface DetailsWorstKPIsViewController : KNPathTableViewController<pieChartNotification> {
    
@protected
    
    id<WorstKPIItf> _delegate;
    
}
@property (weak, nonatomic) IBOutlet UISegmentedControl *theSegment;

@property (weak, nonatomic) IBOutlet CPTGraphHostingView *theGraph;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *theSecondGraph;
@property (weak, nonatomic) IBOutlet UIView *theGraphContainer;
@property (weak, nonatomic) IBOutlet UITableView *theKPITable;
@property (weak, nonatomic) IBOutlet UIToolbar *theToolbar;

- (void) initialize:(WorstKPIDataSource*) datasource initialIndex:(NSUInteger) index isAverage:(Boolean) isAverageKPIs;

@end
