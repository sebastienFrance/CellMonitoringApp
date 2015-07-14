//
//  ZoneKPIsAverageMail.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 16/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ZoneKPIsAverageMail.h"
#import "WorstKPIDataSource.h"
#import "ZoneKPI.h"
#import "KPI.h"
#import "DateUtility.h"
#import "HTMLMailUtility.h"
#import "WorstKPIItf.h"
#import "CellMonitoring.h"
#import "NavCell.h"

@implementation ZoneKPIsAverageMail

- (id) init:(WorstKPIDataSource*) theDatasource {
    if (self = [super init]) {
        _datasource = theDatasource;
    }
    
    return self;
}

- (NSData*) buildNavigationData {
    return [NavCell buildNavigationData:_datasource.cellIndexedByName.allValues];
}

- (NSString*) getMailTitle {
    MonitoringPeriodUtility* dc = [MonitoringPeriodUtility sharedInstance];
    
    return [NSString stringWithFormat:@"%@ KPI Average for %@ (%lu cells)", [BasicTypes getTechnoName:_datasource.technology], [MonitoringPeriodUtility getStringForGranularityPeriodDuration:dc.monitoringPeriod], (unsigned long)_datasource.cellIndexedByName.count];
   
}

- (NSString*) getAttachmentFileName {
    return [NSString stringWithFormat:@"%@.iMon",  [BasicTypes getTechnoName:_datasource.technology]];
}

- (NSString*) buildSpecificBody {
    NSMutableString* HTMLheader = [[NSMutableString alloc] init];
    
    NSDictionary* zoneKPIs = _datasource.zoneKPIs;
    for (ZoneKPI* currentZoneKPI in [zoneKPIs objectEnumerator]) {
        NSString* result = [ZoneKPIsAverageMail convertZoneKPIToHTML:currentZoneKPI dataSource:_datasource];
        [HTMLheader appendFormat:@"%@",result];
    }
    
    
    return HTMLheader; 
}

+ (NSString*) convertZoneKPIToHTML:(ZoneKPI*) theZoneKPI dataSource:(WorstKPIDataSource*) theDatasource {
    
    KPI* theKPI = theZoneKPI.theKPI;
    
    NSMutableString* HTMLKPIDomain = [[NSMutableString alloc] init];
    [HTMLKPIDomain appendFormat:@"<h2> %@ </h2>",theKPI.domain];
    
    [HTMLKPIDomain appendFormat:@"<table border=\"1\">"];
    [HTMLKPIDomain appendFormat:@"<tr><th> KPI Name</th>"];
    
    [HTMLKPIDomain appendFormat:@"%@",[HTMLMailUtility convertKPIsTableHeader:theDatasource.requestDate timezone:theDatasource.timezone]];
    
    [HTMLKPIDomain appendFormat:@"</tr>"];
    
    [HTMLKPIDomain appendFormat:@"%@",[theZoneKPI export2HTML]];
    
    [HTMLKPIDomain appendFormat:@"</table>"];
    return HTMLKPIDomain;
}

@end
