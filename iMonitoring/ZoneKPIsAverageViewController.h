//
//  ZoneKPIsAverageViewController.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 21/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "ZoneKPIDataSource.h"

@class WorstKPIDataSource;

@interface ZoneKPIsAverageViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (void) initialize:(WorstKPIDataSource*) worstKPIs;
- (void) refreshView;
- (void) sendTheMail;



@end
