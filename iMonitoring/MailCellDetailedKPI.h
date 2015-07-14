//
//  MailCellDetailedKPI.h
//  iMonitoring
//
//  Created by sébastien brugalières on 02/03/13.
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

@interface MailCellDetailedKPI : MailAbstract {
@private
    
    CellMonitoring* _theCell;
    KPI* _theKPI;
    NSArray* _theKPIValues;
    NSDate* _requestDate;
    NSArray* _theRelatedKPIValues;
    
    DCMonitoringPeriodView _currentMonitoringPeriod;
}

@property (nonatomic, retain) NSArray* relatedKPIValues;

- (id) init:(CellMonitoring*) theCell KPI:(KPI*) theKPI KPIValues:(NSArray*) theKPIValues monitoringPeriod:(DCMonitoringPeriodView) theMonitoringPeriod requestDate:(NSDate*) theRequestDate;

- (NSData*) buildNavigationData;

@end
