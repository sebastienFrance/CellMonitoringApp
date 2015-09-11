//
//  CellDetailsDataSource.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 12/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CellKPIsDataSource.h"
#import "CellMonitoring.h"
#import "Utility.h"
#import "KPI.h"
#import "KPIDictionary.h"

@interface CellKPIsDataSource ()

// Index: Name of the Monitoring Period
// Object : a NSMutableDictionary with the KPI values
@property (nonatomic) NSMutableDictionary<NSString*,NSMutableDictionary<NSString*,NSArray<NSNumber*>*>*> *KPIsAllMonitoringPeriod;

@property (nonatomic) NSUInteger onGoingRequest;
@property (nonatomic) Boolean hasFailedDuringLoading;
@property (nonatomic, weak) id<CellKPIsLoadingItf> delegate;

@end

@implementation CellKPIsDataSource
@synthesize requestDate = _requestDate;
@synthesize theCell = _theCell;

#pragma mark - HTMLDataResponse protocol
// [{"KPIName":"_RB_Blocking_Rate_Mod_C","KPIValues":"0.00%,0.00%,0.06%,0.08%,0.00%,0.00%,0.13%,0.00%,0.00%,0.00%,0.00%,0.00%,0.00%,0.00%,0.00%,0.00%,0.00%,0.00%,0.00%,0.00%,0.00%,0.00%,0.00%,0.21%,0.00%,"},
// explanation of the format: 
//  - KPIName => contains the name of the KPI
//  - KPIValues => contains the list of values starting with the oldest value. Example, if we request from May 15th at 18:00 to May 16th 17:00 the first value contains the value from [18:00.. 19:00] on May 15th and the last value contains [17:00..18:00] on May 16th. IMPORTANT: the last hour is included.

// Called when the Cell's KPIs values has been received
- (void) dataReady: (id) theData clientId:(NSString *)theClientId {
    
    if ([theClientId isEqualToString:@"getTimeZone"]) {
        [self timezoneReady:theData clientId:theClientId];
        return;
    } else {
        if (self.hasFailedDuringLoading == TRUE) {
            return;
        }

        NSArray* data = theData;
        if (data == Nil) {
            self.hasFailedDuringLoading = TRUE;
            [_delegate dataLoadingFailure];
            return;
        }
        
    //NSLog(@"CellDetails data: %@", data);
        NSMutableDictionary<NSString*,NSArray<NSNumber*>*>* KPIs = [[NSMutableDictionary alloc] initWithCapacity:data.count];
        
        for (int i = 0 ; i < data.count; i++) {
            NSDictionary* currCell = data[i];
            NSString* KPIName = currCell[@"KPIName"];
            NSArray<NSNumber*> *values = currCell[@"KPIValues"];
            
            // Add in the dictionary a KPI (the Key) and the list of values (the value)
            KPIs[KPIName] = values;
            
        }
        
        // add the new KPIs in the dictionary the Key is the Monitoring Perdiod and the Value is a Dictionary 
        // indexed by KPIName and for each KPI the list of values
        self.KPIsAllMonitoringPeriod[theClientId] = KPIs;
        
        self.onGoingRequest--;
        if (self.onGoingRequest == 0) {
            [_theCell setCache:self];
            [_delegate dataIsLoaded];
        }
                
    }
}

// Called in case of failure during KPIs retrieval
- (void) connectionFailure:(NSString*) theClientId {
    // ignore failure for timezone, can still continue with KPIs
    if ([theClientId isEqualToString:@"getTimeZone"]) {
        return;
    }

    if (self.hasFailedDuringLoading == FALSE) {
        self.hasFailedDuringLoading = TRUE;
        [_delegate dataLoadingFailure];
    }
}


- (void) timezoneReady: (id) theData clientId:(NSString *)theClientId {
    if (_theCell.hasTimezone) {
        [_delegate timezoneIsLoaded:_theCell.theTimezone];
    }
    
}

- (id) init:(id<CellKPIsLoadingItf>) delegate {
    
    if (self = [super init]) {
        _delegate = delegate;
    }
    
    return self;
    
}


- (void) loadData:(CellMonitoring*) theCell {

    _theCell = theCell;
    
    _requestDate = [[NSDate alloc] init];    

    
    self.KPIsAllMonitoringPeriod = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    self.onGoingRequest = 0;
    self.hasFailedDuringLoading = FALSE;
    NSString* theClientId = [MonitoringPeriodUtility getInternalStringForMonitoringPeriod:last24HoursHourlyView];
    [RequestUtilities getCellKPIs:theCell delegate:self periodicity:last24HoursHourlyView clientId:theClientId];
    self.onGoingRequest++;
    theClientId = [MonitoringPeriodUtility getInternalStringForMonitoringPeriod:last6Hours15MnView];
    [RequestUtilities getCellKPIs:theCell delegate:self periodicity:last6Hours15MnView clientId:theClientId];
    self.onGoingRequest++;
    theClientId = [MonitoringPeriodUtility getInternalStringForMonitoringPeriod:Last4WeeksWeeklyView];
    [RequestUtilities getCellKPIs:theCell delegate:self periodicity:Last4WeeksWeeklyView clientId:theClientId];
    self.onGoingRequest++;
    theClientId = [MonitoringPeriodUtility getInternalStringForMonitoringPeriod:Last7DaysDailyView];
    [RequestUtilities getCellKPIs:theCell delegate:self periodicity:Last7DaysDailyView clientId:theClientId];
    self.onGoingRequest++;
    theClientId = [MonitoringPeriodUtility getInternalStringForMonitoringPeriod:Last6MonthsMontlyView];
    [RequestUtilities getCellKPIs:theCell delegate:self periodicity:Last6MonthsMontlyView clientId:theClientId];
    self.onGoingRequest++;
    
    if ([theCell hasTimezone] == FALSE) {
        [RequestUtilities getTimeZone:[theCell coordinate] delegate:self clientId:@"getTimeZone"];
    }

}

-(NSDictionary<NSString*,NSArray<NSNumber*>*>*) getKPIsForMonitoringPeriod:(DCMonitoringPeriodView) monitoringPeriod {
    NSString* MonitoringPeriodName = [MonitoringPeriodUtility getInternalStringForMonitoringPeriod:monitoringPeriod];
    return self.KPIsAllMonitoringPeriod[MonitoringPeriodName];
}

@end
