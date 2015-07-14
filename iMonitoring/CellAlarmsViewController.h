//
//  CellAlarmsViewController.h
//  iMonitoring
//
//  Created by sébastien brugalières on 04/09/13.
//
//

#import <UIKit/UIKit.h>

#import "CellMonitoring.h"
#import "HTMLRequest.h"
#import "CellAlarmDatasource.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "KNPathTableViewController.h"



@interface CellAlarmsViewController : KNPathTableViewController <CellAlarmListener>

@property(nonatomic) CellAlarmDatasource* alarmDatasource;

@end
