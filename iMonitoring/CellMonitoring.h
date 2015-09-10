//
//  CellMonitoring.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 17/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "BasicTypes.h"
#import "Parameters.h"

@class CellMonitoringGroup;
@class CellKPIsDataSource;

@interface CellMonitoring : NSObject

@property (nonatomic, readonly) NSString* id;
@property (nonatomic, readonly) NSString* azimuth;
@property (nonatomic, readonly) NSString* techno;
@property (nonatomic, readonly) NSString* site;
@property (nonatomic, readonly) NSString* siteId;
@property (nonatomic, readonly) NSString* fullSiteName;
@property (nonatomic, readonly) NSString* releaseName;
@property (nonatomic, readonly) NSString* dlFrequency;
@property (nonatomic, readonly) float normalizedDLFrequency;
@property (nonatomic, readonly) NSString* telecomId;
@property (nonatomic, readonly) NSUInteger numberIntraFreqNR;
@property (nonatomic, readonly) NSUInteger numberInterFreqNR;
@property (nonatomic, readonly) NSUInteger numberInterRATNR;
@property (nonatomic, readonly) NSUInteger radius;
@property (nonatomic, readonly) Parameters* parametersBySection;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property (nonatomic, readonly) Boolean hasAddress;
@property (nonatomic, readonly) NSString* street;
@property (nonatomic, readonly) NSString* city;
@property (nonatomic, readonly) NSString* country;

@property (nonatomic) NSTimeZone* theTimezone;
@property (nonatomic, readonly) Boolean hasTimezone;

@property (nonatomic, readonly) MKPolygon* thePolygon;

@property (nonatomic, readonly) DCTechnologyId cellTechnology;

@property (nonatomic, readonly) MKPlacemark* cellPlacemark;

@property (weak, nonatomic) CellMonitoringGroup* parentGroup;

#pragma  mark - Constructor
- (id) initWithDictionary:(NSDictionary*) cellDictionary;

#pragma mark - Getter

- (CellKPIsDataSource*) getCache;


#pragma mark - Setter
- (void) setCache:(CellKPIsDataSource*) cache;

- (void) initialiazeAddress:(CLPlacemark*) placemark;

- (void) initializeCellParameters:(Parameters*) cellParameters;


#pragma mark - Utilities

- (void) showDirection;
- (NSString*) cellInfoToHTML;
@property (nonatomic, readonly) NSString* cellShortInfoToHTML;


+ (MKCoordinateRegion) getRegionThatFitsCells:(NSArray*) theCellList;

- (NSComparisonResult)compareByName:(CellMonitoring *)otherObject;


#if TARGET_OS_IPHONE
- (UIImageView*) getPinImageView;
#else
- (NSImageView*) getPinImageView;
#endif

#if TARGET_OS_IPHONE
- (UIImage*) getPinImage;
#else
- (NSImage*) getPinImage;
#endif


@end


