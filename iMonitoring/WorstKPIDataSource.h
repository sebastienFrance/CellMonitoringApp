//
//  WorstKPIDataSource.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 12/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestUtilities.h"
#import "BasicTypes.h"

@protocol WorstKPIDataLoadingItf;

@interface WorstKPIDataSource : NSObject<HTMLDataResponse>

@property (nonatomic, readonly) NSDictionary* KPIs;
@property (nonatomic, readonly) NSDictionary* worstAverageKPIs;

@property (nonatomic, readonly) NSDictionary* cellIndexedByName;
@property (nonatomic, readonly) DCTechnologyId technology;
@property (nonatomic, readonly) NSDate* requestDate;
@property (nonatomic, readonly) NSDictionary* zoneKPIs;
@property (nonatomic, readonly) NSTimeZone* timezone;

@property (nonatomic, weak) id<WorstKPIDataLoadingItf> delegate;


- (id) init:(id<WorstKPIDataLoadingItf>) delegate;
- (void) initialize:(NSArray*) cells techno:(DCTechnologyId) theTechno centerCoordinate:(CLLocationCoordinate2D) coordinate;
- (void) loadData:(DCMonitoringPeriodView) monitoringPeriod;

- (Boolean) hasTimezone;

@end

@protocol WorstKPIDataLoadingItf 
- (void) worstDataIsLoaded:(NSError*) theError;
@end
