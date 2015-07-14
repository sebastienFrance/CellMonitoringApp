//
//  AzimuthsOverlayRenderer.h
//  CellMonitoring
//
//  Created by sébastien brugalières on 05/04/2014.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface AzimuthsOverlayRenderer : MKOverlayRenderer

- (id) initWithOverlay:(id <MKOverlay>)overlay cells:(NSArray*) theCells displaySectorAngle:(Boolean) displaySectorAngle;

@end