//
//  CellParametersValueViewController.h
//  iMonitoring
//
//  Created by sébastien brugalières on 07/01/13.
//
//

#import <UIKit/UIKit.h>

@class CellMonitoring;

@interface CellParametersValueViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *theTable;
@property (nonatomic, retain) CellMonitoring* theCell;

@end
