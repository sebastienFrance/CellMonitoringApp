//
//  CellKPis.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 22/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KPI;

@interface CellWithKPIValues : NSObject


@property (nonatomic, readonly) KPI* theKPI;
@property (nonatomic, readonly) NSString* cellName;
@property (nonatomic, readonly) NSNumber* worstValueOnPeriod;
@property (nonatomic, readonly) NSNumber* averageValue;
@property (nonatomic, readonly) NSNumber* lastKPIValue;

@property (nonatomic, readonly) float lastKPIValueFloat;
@property (nonatomic, readonly) float averageValueFloat;


@property (nonatomic, readonly) float* valuesOfTheKPIFloat;
@property (nonatomic, readonly) NSUInteger valuesOfTheKPISize;


- (id) init:(NSString*) theCellName kpi:(KPI*) theKPI values:(NSArray*) theKPIValues;

- (NSComparisonResult) compareWithLastKPIValue:(CellWithKPIValues *)otherObject;
- (NSComparisonResult) compareWithAverageKPIValue:(CellWithKPIValues *)otherObject;
- (NSComparisonResult) compareReverseWithLastKPIValue:(CellWithKPIValues *)otherObject;
- (NSComparisonResult) compareReverseWithAverageKPIValue:(CellWithKPIValues *)otherObject;
- (NSComparisonResult) compareWithCellName:(CellWithKPIValues *)otherObject;

- (NSString*) export2HTML:(Boolean) isAverageKPIs;

@end
