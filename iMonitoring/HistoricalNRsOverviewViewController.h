//
//  HistoricalNRsOverviewViewController.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 25/01/2015.
//
//

#import <UIKit/UIKit.h>
#import "NeighborsHistoricalDataSource.h"

@interface HistoricalNRsOverviewViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, NeighborsHistoricalLoadingItf>

-(void) initWithCell:(CellMonitoring*) theCell;

@end
