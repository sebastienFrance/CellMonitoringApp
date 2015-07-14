//
//  AzimuthsOverlay.h
//  CellMonitoring
//
//  Created by sébastien brugalières on 30/03/2014.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class CellMonitoring;


@interface AzimuthsOverlay : NSObject <MKOverlay>
@property (nonatomic, readonly) MKPolygon* thePolygon;

- (id) initWithCell:(NSArray*) theCells azimuthRadius:(NSUInteger) radius displaySectorAngle:(Boolean) displaySectorAngle;

- (MKOverlayRenderer*) getAzimuthOverlay;
@end
