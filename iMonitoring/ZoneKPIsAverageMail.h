//
//  ZoneKPIsAverageMail.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 16/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MailAbstract.h"
#import "WorstKPIItf.h"
@class WorstKPIDataSource;
@class ZoneKPI;

@interface ZoneKPIsAverageMail :  MailAbstract {

@private
    WorstKPIDataSource* _datasource;
}

- (id) init:(WorstKPIDataSource*) theDatasource; 

+ (NSString*) convertZoneKPIToHTML:(ZoneKPI*) theZoneKPI dataSource:(WorstKPIDataSource*) theDatasource;
- (NSData*) buildNavigationData;

@end