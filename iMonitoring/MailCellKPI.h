//
//  MailCellKPI.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 18/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "MailAbstract.h"
#import "DataCenter.h"

@class CellMonitoring;
@class CellKPIsDataSource;
@class KPIDictionary;

@interface MailCellKPI : MailAbstract

- (id) init:(CellMonitoring*) theCell datasource:(CellKPIsDataSource*) theDatasource KPIDictionary:(KPIDictionary*) theKPIDictionary monitoringPeriod:(DCMonitoringPeriodView) theMonitoringPeriod alarms:(NSArray*) theAlarms;

- (NSData*) buildNavigationData;


@end
