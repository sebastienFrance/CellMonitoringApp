//
//  ZoneKPISource.h
//  iMonitoring
//
//  Created by sébastien brugalières on 11/01/2014.
//
//

#import <Foundation/Foundation.h>
#import "ZoneKPIDataSource.h"

@interface ZoneKPISource : NSObject<ZoneKPIDataSource>

- (id) init:(WorstKPIDataSource*) theDatasource initialIndex:(NSUInteger) index;

@end
