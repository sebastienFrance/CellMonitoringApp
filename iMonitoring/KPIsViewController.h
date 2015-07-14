//
//  KPIsViewController.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 20/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestUtilities.h"
#import "DetailsWorstKPIsViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "DataCenter.h"
#import "WorstKPIDataSource.h"

@interface KPIsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

- (void) initialize:(WorstKPIDataSource*) worstKPIs;
- (void) refreshView;
- (void)sendTheMail;

@property (weak, nonatomic) IBOutlet UITableView *theTable;


@end
