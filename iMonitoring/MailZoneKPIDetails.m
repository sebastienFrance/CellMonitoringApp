//
//  MailZoneKPIDetails.m
//  iMonitoring
//
//  Created by sébastien brugalières on 06/10/12.
//
//

#import "MailZoneKPIDetails.h"
#import "ZoneKPIDataSource.h"
#import "ZoneKPIsAverageMail.h"
#import "WorstKPIItf.h"
#import "CellMonitoring.h"
#import "WorstKPIDataSource.h"
#import "NavCell.h"

@implementation MailZoneKPIDetails

- (id) init:(id<ZoneKPIDataSource>) theDatasource {
    if (self = [super init]) {
        _dataSource = theDatasource;
    }
    
    return self;
}



- (NSData*) buildNavigationData {
    return [NavCell buildNavigationData:[_dataSource getDetailedDataSource].cellIndexedByName.allValues];
}

- (NSString*) getMailTitle {
    KPI* theKPI = [_dataSource getZoneKPI];
    
    WorstKPIDataSource* worstDataSource = [_dataSource getDetailedDataSource];
    
    return [NSString stringWithFormat:@"Average for KPI %@ (%lu cells)", theKPI.name, (unsigned long)worstDataSource.cellIndexedByName.count];
}

- (NSString*) getAttachmentFileName {
    KPI* theKPI = [_dataSource getZoneKPI];
    return [NSString stringWithFormat:@"%@.iMon", theKPI.name];
}

- (NSString*) buildSpecificBody {
    NSMutableString* HTMLheader = [[NSMutableString alloc] init];
    
    KPI* theKPI = [_dataSource getZoneKPI];
    [HTMLheader appendFormat:@"%@", [theKPI KPIDescriptionToHTML]];

    [HTMLheader appendFormat:@"%@", [ZoneKPIsAverageMail convertZoneKPIToHTML:[_dataSource getFullZoneKPI] dataSource:[_dataSource getDetailedDataSource]]];
 
    return HTMLheader;
}




@end
