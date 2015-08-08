//
//  CellBookmarks+MarkedCell.h
//  iMonitoring
//
//  Created by sébastien brugalières on 03/03/13.
//
//

#import "CellBookmark.h"
#import <MapKit/MapKit.h>
#import "BasicTypes.h"

@class CellMonitoring;

@interface CellBookmark (MarkedCell)

#if TARGET_OS_IPHONE
+ (CellBookmark*) createCellBookmark:(CellMonitoring*) theCell comments:(NSString*) theComments color:(UIColor*) theColor;
#endif

+ (void) removeCellBookmark:(NSString*) cellId;
+ (NSArray<CellBookmark*>*) loadBookmarks;
+ (void) remove:(CellBookmark*) bookmark;

+ (Boolean) isCellMarked:(CellMonitoring*) theCell;

- (CLLocationCoordinate2D) theCellCoordinate;
- (DCTechnologyId) theTechnology;


- (NSComparisonResult)compareByName:(CellBookmark *)otherObject;
- (NSComparisonResult)compareByColor:(CellBookmark *)otherObject;
- (NSComparisonResult)compareByTechnology:(CellBookmark *)otherObject;
- (NSComparisonResult)compareByDate:(CellBookmark *)otherObject;

@end
