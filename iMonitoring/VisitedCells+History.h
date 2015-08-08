//
//  VisitedCells+History.h
//  iMonitoring
//
//  Created by sébastien brugalières on 30/04/13.
//
//

#import "VisitedCells.h"
#import <MapKit/MapKit.h>
#import "BasicTypes.h"

@class CellMonitoring;

@interface VisitedCells (History)

+ (VisitedCells*) createVisitedCells:(CellMonitoring*) theCell;

+ (NSArray<VisitedCells*>*) loadVisitedCells;
+ (VisitedCells*) findVisitedCells:(NSString*) cellInternalName;

- (CLLocationCoordinate2D) theCellCoordinate;
- (DCTechnologyId) theTechnology;

- (NSComparisonResult)compareByName:(VisitedCells *)otherObject;
- (NSComparisonResult)compareByMostVisited:(VisitedCells *)otherObject;
- (NSComparisonResult)compareByTechnology:(VisitedCells *)otherObject;
- (NSComparisonResult)compareByLastVisited:(VisitedCells *)otherObject;

@end
