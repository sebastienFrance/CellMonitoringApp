//
//  ZoneKPI.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 22/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KPI;
@class CellWithKPIValues;


@interface ZoneKPI : NSObject


@property (nonatomic, readonly) KPI* theKPI;


- (id) init:(KPI*) theKPI;

- (void) addNewKPIsValues:(CellWithKPIValues*) theCellKPI; 

// Returns for each GP of the period the average value of the KPI on the zone
// The NSArray contains NSNumber*
- (NSArray*) getKPIAverage;

// Returns the value of the KPI on the zone for the last GP
- (NSNumber*) getLastValue;

// Returns the average of the KPI over the full perion on the zone
- (NSNumber*) getAverageValue;

- (NSString*) export2HTML;
@end
