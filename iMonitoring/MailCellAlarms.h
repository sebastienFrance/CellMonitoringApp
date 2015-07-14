//
//  MailCellAlarms.h
//  iMonitoring
//
//  Created by sébastien brugalières on 11/09/13.
//
//

#import <Foundation/Foundation.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "MailAbstract.h"
#import "DataCenter.h"

@class CellMonitoring;
@class CellKPIsDataSource;
@class KPIDictionary;
@class KPIBarChart;

@interface MailCellAlarms : MailAbstract

- (id) init:(CellMonitoring*) theCell alarms:(NSArray*) theAlarms;
- (NSData*) buildNavigationData;

@end

