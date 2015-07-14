//
//  MailCellNeighborsRelationsWithDiffs.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 15/02/2015.
//
//

#import "MailAbstract.h"

@class HistoricalCellNeighborsData;

@interface MailCellNeighborsRelationsWithDiffs : MailAbstract

-(instancetype) init:(HistoricalCellNeighborsData*) historicalCellNR;

@end
