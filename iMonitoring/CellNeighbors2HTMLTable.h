//
//  CellNeighbors2HTMLTable.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 15/02/2015.
//
//

#import <Foundation/Foundation.h>
@class HistoricalCellNeighborsData;
@class NeighborsDataSourceUtility;

@interface CellNeighbors2HTMLTable : NSObject

+(NSString*) exportCellNeighbors:(NSArray*) neighbors sectionTitle:(NSString*) title;
+(NSString*) exportCellNeighborsHistorical:(HistoricalCellNeighborsData*) historicalNeighbor;
+(NSString*) exportCellNeighborsDatasource:(NeighborsDataSourceUtility*) neighborDatasource sectionTitle:(NSString*) theTitle;

@end
