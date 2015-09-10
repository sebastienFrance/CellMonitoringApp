//
//  MailCellKPI.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 18/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MailCellKPI.h"
#import "CellMonitoring.h"
#import "CellKPIsDataSource.h"
#import "DateUtility.h"
#import "KPI.h"
#import "KPIDictionary.h"
#import "HTMLMailUtility.h"
#import "KPIs2HTMLTable.h"
#import "CellAlarm.h"
#import "CellAlarms2HTMLTable.h"
#import "Utility.h"

@interface MailCellKPI()

// Index: KPI Domain name
// Object list of KPIs of the domain
@property (nonatomic) NSDictionary<NSString*, NSArray<KPI*>*> *KPIDictionary;

// contains the name of sections header for KPIs only (KPI domains)
@property (nonatomic) NSArray<NSString*> *sectionsHeader;
@property (nonatomic) CellMonitoring* theCell;
@property (nonatomic) CellKPIsDataSource* datasource;
@property (nonatomic) DCMonitoringPeriodView currentMonitoringPeriod;
@property (nonatomic) NSArray* alarms;

@end

@implementation MailCellKPI

- (id) init:(CellMonitoring*) theCell datasource:(CellKPIsDataSource*) theDatasource KPIDictionary:(KPIDictionary*) theKPIDictionary monitoringPeriod:(DCMonitoringPeriodView) theMonitoringPeriod alarms:(NSArray*) theAlarms {
    if (self = [super init]) {
        _theCell = theCell;
        _datasource = theDatasource;
        _sectionsHeader = [theKPIDictionary getSectionsHeader:theCell.cellTechnology];
        _KPIDictionary = [theKPIDictionary getKPIsPerDomain:theCell.cellTechnology];
        _currentMonitoringPeriod = theMonitoringPeriod;
        _alarms = theAlarms;
    }
    
    return self;
  
}


- (NSData*) buildNavigationData {
    return [NavCell buildNavigationDataForCell:self.theCell];
}

- (NSString*) getMailTitle {
    return [NSString stringWithFormat:@"Cell %@ (%@)", self.theCell.id, self.theCell.techno];
}

- (NSString*) getAttachmentFileName {
    return [NSString stringWithFormat:@"%@.iMon", self.theCell.id];
}


- (NSString*) buildSpecificBody {
    NSMutableString* HTMLheader = [[NSMutableString alloc] init];
    [HTMLheader appendFormat:@"%@",[_theCell cellInfoToHTML]];
    
    
    if (self.alarms != Nil) {
        [HTMLheader appendFormat:@"%@",[CellAlarms2HTMLTable exportCellAlarms:self.alarms cell:self.theCell]];
    }
    
    for (NSString* headerKPIDomain in self.sectionsHeader) {
        NSString* result = [self convertKPIsFromDomainToHTML:headerKPIDomain];
        [HTMLheader appendFormat:@"%@",result];
    }
    
    return HTMLheader; 
}


- (NSString*) convertKPIsFromDomainToHTML:(NSString*) domainName {
    NSArray<KPI*>* sectionContent = self.KPIDictionary[domainName];

    KPIs2HTMLTable* HTMLTable = [[KPIs2HTMLTable alloc] init:self.datasource.requestDate timezone:self.theCell.theTimezone monitoringPeriod:self.currentMonitoringPeriod];

    NSDictionary* KPIs = [self.datasource getKPIsForMonitoringPeriod:_currentMonitoringPeriod];
    for (KPI* currentKPI in sectionContent) {
        NSArray* kpiValues = KPIs[currentKPI.internalName];
        [HTMLTable appendRowKPIValues:currentKPI KPIValues:kpiValues];
    }

    return [NSString stringWithFormat:@"<h2> %@ </h2> %@",domainName, [HTMLTable getHTMLTable]];
}




@end
