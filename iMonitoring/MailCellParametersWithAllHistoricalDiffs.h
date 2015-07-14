//
//  MailCellParametersWithAllHistoricalDiffs.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 20/03/2015.
//
//

#import <Foundation/Foundation.h>
#import "MailAbstract.h"

@class HistoricalParameters;
@class CellMonitoring;

@interface MailCellParametersWithAllHistoricalDiffs: MailAbstract

-(instancetype) init:(NSArray*) allHistorical cell:(CellMonitoring*) sourceCell;

@end

