//
//  MailCellDetailedKPI.m
//  iMonitoring
//
//  Created by sébastien brugalières on 02/03/13.
//
//

#import "MailCellDetailedKPI.h"
#import "CellMonitoring.h"
#import "CellKPIsDataSource.h"
#import "DateUtility.h"
#import "KPI.h"
#import "KPIDictionary.h"
#import "HTMLMailUtility.h"
#import "KPIs2HTMLTable.h"
#import "KPIBarChart.h"
#import <CorePlot/ios/CorePlot.h>

@implementation MailCellDetailedKPI

@synthesize relatedKPIValues = _theRelatedKPIValues;

- (id) init:(CellMonitoring*) theCell KPI:(KPI*) theKPI KPIValues:(NSArray*) theKPIValues monitoringPeriod:(DCMonitoringPeriodView) theMonitoringPeriod requestDate:(NSDate*) theRequestDate {
    if (self = [super init]) {
        _theCell = theCell;
        _theKPI = theKPI;
        _theKPIValues = theKPIValues;
        _requestDate = theRequestDate;
        _currentMonitoringPeriod = theMonitoringPeriod;
    }
    
    return self;
    
}


- (NSData*) buildNavigationData {
    return [NavCell buildNavigationDataForCell:_theCell];
}

- (NSString*) getMailTitle {
    return [NSString stringWithFormat:@"Cell %@ (%@)", _theCell.id, _theCell.techno];
}

- (NSString*) getAttachmentFileName {
    return [NSString stringWithFormat:@"%@.iMon", _theCell.id];
}


- (NSString*) buildSpecificBody {
    NSMutableString* HTMLheader = [[NSMutableString alloc] init];
    [HTMLheader appendFormat:@"%@",[_theCell cellInfoToHTML]];
    
    NSString* result = [self convertKPIsFromDomainToHTML];
    [HTMLheader appendFormat:@"%@",result];
    
    return HTMLheader;
}

- (NSString*) convertKPIsFromDomainToHTML {
    
    KPIs2HTMLTable* HTMLTable = [[KPIs2HTMLTable alloc] init:_requestDate timezone:_theCell.theTimezone monitoringPeriod:_currentMonitoringPeriod];
    
    [HTMLTable appendRowKPIValues:_theKPI KPIValues:_theKPIValues];
    
    if ((_theKPI.theRelatedKPI != Nil) && (_theRelatedKPIValues != Nil)) {
        [HTMLTable appendRowKPIValues:_theKPI.theRelatedKPI KPIValues:_theRelatedKPIValues];
    }
    
    return [NSString stringWithFormat:@"<h2> %@ </h2> %@",_theKPI.domain, [HTMLTable getHTMLTable]];
    
}





@end
