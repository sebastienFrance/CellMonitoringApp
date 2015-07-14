//
//  iPadCellGroupPopoverViewController.h
//  iMonitoring
//
//  Created by sébastien brugalières on 12/04/13.
//
//

#import <UIKit/UIKit.h>
#import "AroundMeViewItf.h"
@class CellMonitoringGroup;


@interface CellGroupViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

-(void) initialize:(CellMonitoringGroup*) cellGroup delegate:(id<AroundMeViewItf>) theDelegate;

@property (weak, nonatomic) IBOutlet UITableView *theTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *theSegment;

@end
