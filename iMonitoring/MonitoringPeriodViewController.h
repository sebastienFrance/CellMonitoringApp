//
//  MonitoringPeriodViewController.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 02/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserPreferencesViewController;

@interface MonitoringPeriodViewController : UITableViewController {
    UITableViewCell* _selectedCell;
}


@property (nonatomic, retain) UserPreferencesViewController* delegate;
@property (nonatomic, assign) Boolean isKPIDictionary;

@end
