//
//  MailOverviewWorstCellsKPIs.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 16/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MailAbstract.h"

@class WorstKPIDataSource;

@interface MailOverviewWorstCellsKPIs :  MailAbstract {
    
@private
    WorstKPIDataSource* _datasource;
}

- (id) init:(WorstKPIDataSource*) theDatasource; 
- (NSData*) buildNavigationData;

@end