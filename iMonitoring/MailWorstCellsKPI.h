//
//  MailWorstCellsKPI.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 20/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MailAbstract.h"
#import "WorstKPIItf.h"

@interface MailWorstCellsKPI : MailAbstract


- (id) init:(NSArray*) KPIValuesPerCell isAverageKPIs:(Boolean) isTheAverageKPIs worstItf:(id<WorstKPIItf>) theWorstItf KPIName:(NSString*) theKPIName;

- (NSData*) buildNavigationData;
@end
