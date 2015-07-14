//
//  CellImageListViewController.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 22/02/2015.
//
//

#import <UIKit/UIKit.h>
#import "HTMLRequest.h"

@class CellMonitoring;

@interface CellImageListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, HTMLDataResponse>


-(void) initializeWithCell:(CellMonitoring*) theCell;

@end
