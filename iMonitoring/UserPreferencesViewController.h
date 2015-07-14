//
//  UserPreferencesViewController.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 08/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KPIsPrefListViewController;
@class iMonitoringMainViewController;


@interface UserPreferencesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> 

@property (weak, nonatomic) IBOutlet UITableView *preferencesTableView;

- (void) updateDefaultMonitoringPeriod;
- (void) updateDefaultKPIDictionary;


@end
