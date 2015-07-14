//
//  CellFilter.h
//  iMonitoring
//
//  Created by sébastien brugalières on 03/08/13.
//
//

#import <Foundation/Foundation.h>

@class CellMonitoring;

@interface CellFilter : NSObject

-(Boolean) isFiltered:(CellMonitoring*) theCell;


@end
