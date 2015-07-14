//
//  WorstCellSource.h
//  iMonitoring
//
//  Created by sébastien brugalières on 12/01/2014.
//
//

#import <Foundation/Foundation.h>
#import "WorstKPIItf.h"
#import "WorstKPIDataSource.h"

@interface WorstCellSource : NSObject<WorstKPIItf>

- (id) init:(WorstKPIDataSource*) theDatasource initialIndex:(NSUInteger) index isAverage:(Boolean) isAverageKPIs;
- (void) goToIndex:(NSUInteger) index;

@end
