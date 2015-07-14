//
//  CellParametersHistoricalDataSource.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 09/03/2015.
//
//

#import <Foundation/Foundation.h>
#import "RequestUtilities.h"

@protocol CellParametersHistoricalDataSourceDelegate;

@interface CellParametersHistoricalDataSource : NSObject <HTMLDataResponse>

// List of HistoricalParameters ordered by date
@property(nonatomic, readonly) NSArray* theHistoricalData;

- (id) init:(id<CellParametersHistoricalDataSourceDelegate>) delegate;
-(void) loadData:(CellMonitoring*) cell;

@end


@protocol CellParametersHistoricalDataSourceDelegate <NSObject>

-(void) cellParametersHistoricalResponse:(CellMonitoring*) cell error:(NSError*) theError;


@end