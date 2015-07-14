//
//  iPadCellDetailsPopoverMenuViewController.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 30/12/2014.
//
//

#import <UIKit/UIKit.h>

#import "iPadAroundMeImpl.h"
#import "CellTimezoneDataSource.h"
#import "CellDetailsInfoBasicViewController.h"

@class CellMonitoring;

@interface iPadCellDetailsPopoverMenuViewController : CellDetailsInfoBasicViewController< CellTimezoneDataSourceDelegate>


@property (weak, nonatomic) IBOutlet UITableView *theTable;

@end
