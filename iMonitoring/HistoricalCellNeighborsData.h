//
//  HistoricalCellNeighborsData.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 27/01/2015.
//
//

#import <Foundation/Foundation.h>
#import "NeighborsDataSourceUtility.h"

@interface HistoricalCellNeighborsData : NSObject

@property(nonatomic, readonly) NeighborsDataSourceUtility* currentNeighbors;
@property(nonatomic, readonly) NSDate* currentDate;


-(instancetype) initWithDateAndNeighbors:(NSDate*) date neighbors:(NeighborsDataSourceUtility*) theNeighbors;

-(NSComparisonResult) compareWithCurrentDate:(HistoricalCellNeighborsData *)otherObject;
-(void) buildDiffWithPrevious:(HistoricalCellNeighborsData*) previousHistoricalNRs;

// all data are ordered by Distance

-(NSArray*) removedNRs:(NeighborModeChoiceId) theMode;
-(NSArray*) addedNRs:(NeighborModeChoiceId) theMode;

@end
