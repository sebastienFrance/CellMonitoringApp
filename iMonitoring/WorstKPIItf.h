//
//  WorstKPIItf.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 09/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CellMonitoring;

@protocol WorstKPIItf 

@required
- (NSArray*) getKPIValues;
- (void) moveToNextKPI;
- (void) moveToPreviousKPI;
- (CellMonitoring*) getCellbyName:(NSString*) theCellName;

@end

