//
//  HistoricalNRsOverviewCell.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 25/01/2015.
//
//

#import <UIKit/UIKit.h>

@class HistoricalCellNeighborsData;

@interface HistoricalNRsOverviewCell : UITableViewCell

-(void) initializeWith:(HistoricalCellNeighborsData*) theNeighbors
                     index:(NSUInteger) theIndex;

@end
