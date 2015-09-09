//
//  CellMonitoringGroup.h
//  iMonitoring
//
//  Created by sébastien brugalières on 11/04/13.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "BasicTypes.h"

@class CellMonitoring;
@class CellFilter;
@class AzimuthsOverlay;

@interface CellMonitoringGroup : NSObject<MKAnnotation>


@property (nonatomic, readonly) AzimuthsOverlay* azimuthOverlays;
@property (nonatomic, readonly) NSArray* filteredCells;
@property (nonatomic, readonly) NSString* annotationIdentifier;
@property (nonatomic, readonly, getter = hasVisibleCells) Boolean visibleCells;
@property (nonatomic, readonly) NSString* timezoneRegion;
@property (nonatomic, readonly) NSString* timezone;
@property (nonatomic, readonly) NSString* timezoneAbbreviation;
@property (nonatomic, readonly) Boolean hasTimezone;


@property (nonatomic, readonly) NSString* street;
@property (nonatomic, readonly) NSString* city;
@property (nonatomic, readonly) NSString* country;
@property (nonatomic, readonly) Boolean hasAddress;
@property (nonatomic, readonly) MKPlacemark* cellPlacemark;


- (id) initWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (void) addCell:(CellMonitoring*) theCell;
- (void) commit;

- (void) initialiazeAddress:(CLPlacemark*) placemark;

- (void) setPinImageAnnotation:(Boolean) isCenterCell pinView:(MKAnnotationView*) thePinView;
- (NSArray*) refreshCellGroupFromFilter:(CellFilter*) cellFilter;

- (NSUInteger) getFilteredCellCountForTechnoId:(DCTechnologyId) technology;
- (NSArray*) getFilteredCellsForTechnoId:(DCTechnologyId) technology;
- (NSArray*) getAllCellsForTechnoId:(DCTechnologyId) technology;

+ (MKCoordinateRegion) getRegionThatFitsCells:(NSArray*) theCellList;
@end
