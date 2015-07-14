//
//  MailCellParametersWithDiffs.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 19/03/2015.
//
//

#import <Foundation/Foundation.h>
#import "MailAbstract.h"

@class HistoricalParameters;
@class CellMonitoring;

@interface MailCellParametersWithDiffs : MailAbstract

-(instancetype) init:(HistoricalParameters*) cellHistorical cell:(CellMonitoring*) sourceCell;

@end
