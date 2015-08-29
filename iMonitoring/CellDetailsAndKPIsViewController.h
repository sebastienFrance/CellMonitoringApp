//
//  CellDetailsAndKPIsViewController.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 18/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestUtilities.h"
#import "DetailsCellWithChartViewController.h"
#import "MarkViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "CellKPIsDataSource.h"
#import "RequestUtilities.h"
#import "CellAlarmDatasource.h"
#import "AroundMeViewItf.h"
#import "CellParametersDataSource.h"
#import "CellDetailsInfoBasicViewController.h"

@class CellMonitoring;
@class AroundMeViewController;



@interface CellDetailsAndKPIsViewController : CellDetailsInfoBasicViewController

@property (weak, nonatomic) IBOutlet UITableView *theTable;

@end


