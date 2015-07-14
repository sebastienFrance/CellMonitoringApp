//
//  MarkedCellsViewController.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 28/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MarkedCellsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
}

@property (weak, nonatomic) IBOutlet UITableView *theTable;



@end
