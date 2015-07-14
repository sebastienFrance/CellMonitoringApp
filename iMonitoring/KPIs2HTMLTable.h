//
//  KPIs2HTMLTable.h
//  iMonitoring
//
//  Created by sébastien brugalières on 02/03/13.
//
//

#import <Foundation/Foundation.h>
#import "MonitoringPeriodUtility.h"

@class KPI;

@interface KPIs2HTMLTable : NSObject {
    @private
    
    NSMutableString* _theHTML;
    Boolean _endTableAdded;
     
}


- (id) init:(NSDate*) theDate timezone:(NSString*) theTimezone monitoringPeriod:(DCMonitoringPeriodView) theMonitoringPeriod;
- (void) appendRowKPIValues:(KPI*) theKPI KPIValues:(NSArray*) theKPIValues;
- (NSString*) getHTMLTable;


@end
