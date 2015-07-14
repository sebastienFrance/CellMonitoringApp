//
//  CellParametersDataSource.h
//  iMonitoring
//
//  Created by sébastien brugalières on 22/12/2013.
//
//

#import <Foundation/Foundation.h>
#import "RequestUtilities.h"

@protocol CellParametersDataSourceDelegate; 

@interface CellParametersDataSource : NSObject <HTMLDataResponse>

- (id) init:(id<CellParametersDataSourceDelegate>) delegate;
-(void) loadData:(CellMonitoring*) cell;


@end

@protocol CellParametersDataSourceDelegate <NSObject>

-(void) cellParametersWithResponse:(CellMonitoring*) cell error:(NSError*) theError;


@end