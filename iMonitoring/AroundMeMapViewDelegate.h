//
//  AroundMeMapViewDelegate.h
//  iMonitoring
//
//  Created by sébastien brugalières on 31/03/13.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "BasicMapViewDelegate.h"
#import "MapModeItf.h"

@protocol MapDelegateItf;

@interface AroundMeMapViewDelegate : BasicMapViewDelegate


// animate depending on user preferences
- (void) goToCoordinate:(MKMapCamera*) endCamera MapView:(MKMapView*) theMapView reloadCells:(Boolean) forceToReloadCells;

// go to coordinate always with animation
- (void) goToCoordinateWithAnimation:(MKMapCamera*) endCamera MapView:(MKMapView*) theMapView reloadCells:(Boolean) forceToReloadCells;

// go to coordinate without animation
- (void) goToCoordinateWithoutAnimation:(MKMapCamera*) endCamera MapView:(MKMapView*) theMapView reloadCells:(Boolean) forceToReloadCells;

@end



