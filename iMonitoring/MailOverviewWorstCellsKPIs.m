//
//  MailOverviewWorstCellsKPIs.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 16/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MailOverviewWorstCellsKPIs.h"
#import "WorstKPIDataSource.h"
#import "CellWithKPIValues.h"
#import "KPI.h"
#import "HTMLMailUtility.h"
#import "DataCenter.h"
#import "CellMonitoring.h"

@implementation MailOverviewWorstCellsKPIs

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
    return [NSString stringWithFormat:@"%@ KPIs distribution for %@ (%lu cells)", [BasicTypes getTechnoName:_datasource.technology], [MonitoringPeriodUtility getStringForGranularityPeriodDuration:dc.monitoringPeriod], (unsigned long)_datasource.cellIndexedByName.count];
    
}

- (NSString*) getAttachmentFileName {
     return [NSString stringWithFormat:@"%@.iMon", [BasicTypes getTechnoName:_datasource.technology]];

}

- (NSString*) buildSpecificBody {
    NSMutableString* HTMLheader = [[NSMutableString alloc] init];
    
    
    MonitoringPeriodUtility* dc = [MonitoringPeriodUtility sharedInstance];
    
    [HTMLheader appendFormat:@"<h2> %@ </h2>",[MonitoringPeriodUtility getStringForGranularityPeriodName:dc.monitoringPeriod]];
    [HTMLheader appendFormat:@"%@", [self exportKPIs:TRUE]];
    [HTMLheader appendFormat:@"<h2> %@ </h2>",[MonitoringPeriodUtility getStringForGranularityPeriodDuration:dc.monitoringPeriod]];
    [HTMLheader appendFormat:@"%@",[self exportKPIs:FALSE]];
    
    
    return HTMLheader; 
}


- (NSString* ) exportKPIs:(Boolean) lastWorstKPI {
    NSMutableString* HTMLheader = [[NSMutableString alloc] init];
    [HTMLheader appendFormat:@"<table border=\"1\">"];
    
    [HTMLheader appendFormat:@"<th>Domain</th><th>KPI Name</th>"];
    [HTMLheader appendFormat:@"<th style=\"background-color:%@;text-align:center\"><b>Green</b></th>",    [HTMLMailUtility getGreenColorCode]];
    [HTMLheader appendFormat:@"<th style=\"background-color:%@;text-align:center\"><b>Yellow</b></th>",   [HTMLMailUtility getYellowColorCode]];
    [HTMLheader appendFormat:@"<th style=\"background-color:%@;text-align:center\"><b>Orange</b></th>",   [HTMLMailUtility getOrangeColorCode]];
    [HTMLheader appendFormat:@"<th style=\"background-color:%@;text-align:center\"><b>Red</b></th>",      [HTMLMailUtility getRedColorCode]];
    [HTMLheader appendFormat:@"<th style=\"background-color:%@;text-align:center\"><b>No Value</b></th>", [HTMLMailUtility getNoValueColorCode]];
    
    NSDictionary* worstAverageKPIs = _datasource.worstAverageKPIs;
    for (NSArray* cellKPIsTable in [worstAverageKPIs objectEnumerator]) {
        [HTMLheader appendFormat:@"%@", [MailOverviewWorstCellsKPIs exportKPIDistribution:cellKPIsTable isLastWorst:lastWorstKPI]];
    }
    [HTMLheader appendFormat:@"</tr>"];
    [HTMLheader appendFormat:@"</table>"];
    
    return HTMLheader;
}

+ (NSString*) exportKPIDistribution:(NSArray*) KPIValues isLastWorst:(Boolean) lastWorstKPI {
    // Create the chart and initialize it
    NSUInteger numberOfGreen = 0;
    NSUInteger numberOfYellow = 0;
    NSUInteger numberOfOrange = 0;
    NSUInteger numberOfRed = 0;
    NSUInteger numberOfWhite = 0;
    

    NSMutableString* HTML = [[NSMutableString alloc] init];
    
    Boolean firstEntry = FALSE;
    
    for (CellWithKPIValues* cellData in KPIValues) {    
        
        if (firstEntry == FALSE) {
            [HTML appendFormat:@"<tr><td><b>%@ </b></td><td><b>%@ </b></td>",cellData.theKPI.domain, cellData.theKPI.name];   
            firstEntry = TRUE;
        }
        
        NSNumber* value;
        if (lastWorstKPI == true) {
            value = cellData.lastKPIValue;
        } else {
            value = cellData.averageValue;
        }
        KPIColorCodeId theColor = [cellData.theKPI getColorIdFromNumber:value];
        switch (theColor) {
            case KPIColorgreen: {
                numberOfGreen++;
                break;
            }
            case KPIColoryellow: {
                numberOfYellow++;
                break;
            }
            case KPIColororange: {
                numberOfOrange++;
                break;
            }
            case KPIColorred: {
                numberOfRed++;
                break;
            }
            case KPIColorwhite: {
                numberOfWhite++;
                break;
            }
            default: {
                // unknown color!  
            }
        }
    }

    [HTML appendFormat:@"<td style=\"background-color:%@;text-align:center\">%lu (%.2f%%)</td>", [HTMLMailUtility getGreenColorCode], (unsigned long)numberOfGreen, (((float)numberOfGreen / (float)KPIValues.count)*100)];
    [HTML appendFormat:@"<td style=\"background-color:%@;text-align:center\">%lu (%.2f%%)</td>", [HTMLMailUtility getYellowColorCode], (unsigned long)numberOfYellow, (((float)numberOfYellow / (float)KPIValues.count)*100)];
    [HTML appendFormat:@"<td style=\"background-color:%@;text-align:center\">%lu (%.2f%%)</td>", [HTMLMailUtility getOrangeColorCode], (unsigned long)numberOfOrange, (((float)numberOfOrange / (float)KPIValues.count)*100)];
    [HTML appendFormat:@"<td style=\"background-color:%@;text-align:center\">%lu (%.2f%%)</td>", [HTMLMailUtility getRedColorCode], (unsigned long)numberOfRed, (((float)numberOfRed / (float)KPIValues.count)*100)];
    [HTML appendFormat:@"<td style=\"background-color:%@;text-align:center\">%lu (%.2f%%)</td>", [HTMLMailUtility getNoValueColorCode], (unsigned long)numberOfWhite, (((float)numberOfWhite / (float)KPIValues.count)*100)];

    
    return HTML;
}



@end
