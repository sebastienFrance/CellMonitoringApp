//
//  AzimuthsOverlay.m
//  CellMonitoring
//
//  Created by sébastien brugalières on 30/03/2014.
//
//

#import "AzimuthsOverlay.h"
#import "CellMonitoring.h"
#import "UserPreferences.h"
#import "AzimuthsOverlayRenderer.h"

@interface AzimuthsOverlay ()

@property(nonatomic) CLLocationCoordinate2D theCoordinate;
@property (nonatomic) AzimuthsOverlayRenderer* renderer;
@property (nonatomic) MKMapRect polygonRect;
@property (nonatomic) NSUInteger radius;
@end


@implementation AzimuthsOverlay


- (id) initWithCell:(NSArray*) theCells azimuthRadius:(NSUInteger) radius displaySectorAngle:(Boolean) displaySectorAngle {
    if (self = [super init]) {
        CellMonitoring* thefirstCell = theCells[0];
        _theCoordinate = thefirstCell.coordinate;
        
        _renderer = [[AzimuthsOverlayRenderer alloc] initWithOverlay:self cells:theCells displaySectorAngle:displaySectorAngle];
        
        _radius = radius;
        
        [self createPolygonForAzimtuh];
    }
    return self;
}


#pragma mark - MKOverlay protocol

// Coordinate used to display the annotation on the Map. Offset is not 0 if several cells have the same coordinates
- (CLLocationCoordinate2D)coordinate;
{
    return self.theCoordinate;
}

// Implement protocol MKOverlay
- (MKMapRect) boundingMapRect {
    return self.polygonRect;
}


- (void) createPolygonForAzimtuh {
    
    CLLocationDistance metersPerPoint = MKMetersPerMapPointAtLatitude(self.coordinate.latitude);
    CGFloat unit = self.radius/metersPerPoint;
    
    MKMapPoint initialCoordinate = MKMapPointForCoordinate(self.coordinate);
    MKMapRect mr = MKMapRectMake(initialCoordinate.x - (unit * 2.0), initialCoordinate.y - (unit * 2.0),  unit * 4.0, unit * 4.0);
    self.polygonRect = mr;
}

- (MKOverlayRenderer*) getAzimuthOverlay {
    return self.renderer;
}



@end
