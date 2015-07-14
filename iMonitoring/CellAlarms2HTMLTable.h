//
//  CellAlarms2HTMLTable.h
//  iMonitoring
//
//  Created by sébastien brugalières on 11/09/13.
//
//

#import <Foundation/Foundation.h>
#import "CellAlarm.h"
#import "CellMonitoring.h"

@interface CellAlarms2HTMLTable : NSObject

+(NSString*) exportCellAlarms:(NSArray*) cellAlarms cell:(CellMonitoring*) theCell;

@end
