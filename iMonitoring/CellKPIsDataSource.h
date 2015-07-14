//
//  CellDetailsDataSource.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 12/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestUtilities.h"

@protocol CellKPIsLoadingItf;

@interface CellKPIsDataSource : NSObject <HTMLDataResponse>

@property (nonatomic, readonly) NSDate* requestDate;
@property (nonatomic, readonly) CellMonitoring* theCell;

- (id) init:(id<CellKPIsLoadingItf>) delegate;
- (void) loadData:(CellMonitoring*) theCell;
- (NSDictionary*) getKPIsForMonitoringPeriod:(DCMonitoringPeriodView) monitoringPeriod;

@end

@protocol CellKPIsLoadingItf 
- (void) dataIsLoaded;
- (void) dataLoadingFailure;
- (void) timezoneIsLoaded:(NSString*) theTimeZone;
@end