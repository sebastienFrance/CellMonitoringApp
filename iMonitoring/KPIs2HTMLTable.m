//
//  KPIs2HTMLTable.m
//  iMonitoring
//
//  Created by sébastien brugalières on 02/03/13.
//
//

#import "KPIs2HTMLTable.h"
#import "HTMLMailUtility.h"
#import "KPI.h"

@implementation KPIs2HTMLTable

- (id) init:(NSDate*) theDate timezone:(NSString*) theTimezone monitoringPeriod:(DCMonitoringPeriodView) theMonitoringPeriod {
    if (self = [super init]) {
        _endTableAdded = FALSE;
        _theHTML = [[NSMutableString alloc] init];
        
       
        [_theHTML appendFormat:@"<table border=\"1\">"];
        [_theHTML appendFormat:@"<tr><th> KPI Name</th>"];
        
        
        [_theHTML appendFormat:@"%@",[HTMLMailUtility convertKPIsTableHeader:theDate timezone:theTimezone monitoringPeriod:theMonitoringPeriod]];
        
        [_theHTML appendFormat:@"</tr>"];
    }
    
    return self;
    
}


- (void) appendRowKPIValues:(KPI*) theKPI KPIValues:(NSArray*) theKPIValues {
    
    [_theHTML appendFormat:@"<tr><td><b>%@ </b></td>", theKPI.name];
    for (NSNumber* values in theKPIValues) {
        
        NSString* colorCode = [theKPI getHTMLColorFromNumber:values];
        NSString* htmlValue = [theKPI getHTMLDisplayableValueFromNumber:values];
        [_theHTML appendFormat:@"<td style=\"background-color:%@;text-align:center\">%@</td>", colorCode, htmlValue];
    }
    [_theHTML appendFormat:@"</tr>"];
    
}

- (NSString*) getHTMLTable {
    if (_endTableAdded == FALSE) {
        [_theHTML appendString:@"</table>"];
    }
    
    return _theHTML;
}

@end
