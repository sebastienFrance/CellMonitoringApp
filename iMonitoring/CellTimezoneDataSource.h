//
//  CellTimezoneDataSource.h
//  iMonitoring
//
//  Created by sébastien brugalières on 23/12/2013.
//
//

#import <Foundation/Foundation.h>
#import "HTMLRequest.h"

@class CellMonitoring;

@protocol CellTimezoneDataSourceDelegate <NSObject>

- (void) cellTimezoneResponse:(CellMonitoring*) cell error:(NSError*) theError;

@end



@interface CellTimezoneDataSource : NSObject<HTMLDataResponse>

- (id) initWithDelegate:(id<CellTimezoneDataSourceDelegate>) delegate cell:(CellMonitoring*) theCell;

-(void) loadTimeZone;


@end
