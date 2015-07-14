//
//  MailZoneKPIDetails.h
//  iMonitoring
//
//  Created by sébastien brugalières on 06/10/12.
//
//

#import <Foundation/Foundation.h>
#import "MailAbstract.h"
#import "WorstKPIItf.h"

@protocol ZoneKPIDataSource;

@interface MailZoneKPIDetails : MailAbstract {
@private
    id<ZoneKPIDataSource> _dataSource;
}

- (id) init:(id<ZoneKPIDataSource>) dataSource;
- (NSData*) buildNavigationData;
@end
