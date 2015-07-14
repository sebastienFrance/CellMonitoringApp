//
//  HistoricalParametersViewController.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 08/03/2015.
//
//

#import <UIKit/UIKit.h>
#import "CellParametersHistoricalDataSource.h"

@interface HistoricalOverviewParametersViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, CellParametersHistoricalDataSourceDelegate>

-(void) initWithCell:(CellMonitoring*) theCell;

@end
