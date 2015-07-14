//
//  CellAlarms2HTMLTable.m
//  iMonitoring
//
//  Created by sébastien brugalières on 11/09/13.
//
//

#import "CellAlarms2HTMLTable.h"
#import "DateUtility.h"

@implementation CellAlarms2HTMLTable

+(NSString*) exportCellAlarms:(NSArray*) cellAlarms cell:(CellMonitoring*) theCell {
    NSMutableString* HTMLAlarms = [[NSMutableString alloc] init];
    
    [HTMLAlarms appendFormat:@"<h2> Alarms </h2>"];
    
    // style="width: 100%;"
    if (cellAlarms == Nil) {
        [HTMLAlarms appendFormat:@"<p>Alarms couldn't be collected</p>"];
    } else if (cellAlarms.count == 0) {
        [HTMLAlarms appendFormat:@"<p>No alarms on this cell</p>"];
    } else {
        [HTMLAlarms appendFormat:@"<table border=\"1\">"];
        [HTMLAlarms appendFormat:@"<tr>"];
        
        //th style="width:300px"
        [HTMLAlarms appendFormat:@"<th> Date (%@)</th>", theCell.timezone];
        [HTMLAlarms appendFormat:@"<th> Probable Cause </th>"];
        [HTMLAlarms appendFormat:@"<th> Alarm Type </th>"];
        [HTMLAlarms appendFormat:@"<th> Acknowledged </th>"];
        [HTMLAlarms appendFormat:@"<th> Additional Text </th>"];
        [HTMLAlarms appendFormat:@"<th> Severity </th>"];
        [HTMLAlarms appendFormat:@"</tr>"];
        
        for (CellAlarm* currentAlarm in cellAlarms) {
            [HTMLAlarms appendFormat:@"%@", [CellAlarms2HTMLTable convertAlarmToHTML:currentAlarm cell:theCell]];
        }
        
        [HTMLAlarms appendString:@"</table>"];
    }
    
    
    return HTMLAlarms;
}

// style=\"width: 100%%;\"
+ (NSString*) convertAlarmToHTML:(CellAlarm*) theAlarm cell:(CellMonitoring*) theCell {
    NSMutableString* HTMLAlarm = [[NSMutableString alloc] init];
    
    [HTMLAlarm appendFormat:@"<tr>"];
    [HTMLAlarm appendFormat:@"<td style=\"background-color:%@\">%@</td>", theAlarm.severityHTMLColor,
     [DateUtility getDateWithTimeZone:theAlarm.dateAndTime timezone:theCell.timezone option:withHHmmss]];
    [HTMLAlarm appendFormat:@"<td>%@</td>", theAlarm.probableCause];
    [HTMLAlarm appendFormat:@"<td>%@</td>", theAlarm.alarmTypeString];
    [HTMLAlarm appendFormat:@"<td>%@</td>", theAlarm.isAcknowledged ? @"True" : @"False"];
    [HTMLAlarm appendFormat:@"<td>%@</td>", theAlarm.additionalText];
    [HTMLAlarm appendFormat:@"<td>%@</td>", theAlarm.severityString];
    [HTMLAlarm appendFormat:@"</tr>"];
    
    
    return HTMLAlarm;
}



@end
