//
//  MapUtilities.h
//  iMonitoring
//
//  Created by sébastien brugalières on 11/11/2013.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "CellGroupAnnotationView.h"
#import "MapModeItf.h"

@class CellMonitoringGroup;
@protocol MapDelegateItf;


@interface BasicMapViewDelegate : NSObject<MKMapViewDelegate>

- (id)init:(id<MapDelegateItf>) mapDelegate mapMode:(id<MapModeItf>) mode;

// only these 2 methods are implemented from MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation;
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay;

// default implementation return Nil;

#if TARGET_OS_IPHONE
- (UIButton*) getCalloutAccessoryFor:(CellMonitoringGroup*) currCellGroup;
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
- (NSButton*) getCalloutAccessoryFor:(CellGroupAnnotationView*) currCellGroup;
#endif

@property (nonatomic, weak, readonly) id<MapDelegateItf> delegate;
@property (nonatomic, weak, readonly) id<MapModeItf> delegateMode;


@end

