//
//  MapUtilities.m
//  iMonitoring
//
//  Created by sébastien brugalières on 11/11/2013.
//
//

#import "BasicMapViewDelegate.h"
#import <MapKit/MapKit.h>
#import "CellMonitoringGroup.h"
#import "NeighborOverlay.h"
#import "AzimuthsOverlay.h"
#import "CellGroupAnnotationView.h"

@implementation BasicMapViewDelegate


- (id)init:(id<MapDelegateItf>) mapDelegate mapMode:(id<MapModeItf>) mode {
    if (self = [super init]) {
        _delegate = mapDelegate;
        _delegateMode = mode;
    }
    return self;
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    if ([annotation isKindOfClass:[CellMonitoringGroup class]]) {
        // try to dequeue an existing pin view first
        
        CellMonitoringGroup* currCellGroup = (CellMonitoringGroup*) annotation;
        
        
        NSString*   reuseId = currCellGroup.annotationIdentifier;
        
#if TARGET_OS_IPHONE
        MKAnnotationView* pinView = (MKAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
        
        if (!pinView) {
            
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
            
            // required to detect when user select the annotation to display the call out
            pinView.frame = CGRectMake(0, 0, 28, 51);
            pinView.canShowCallout = YES;
            UIButton* rightButton = [self getCalloutAccessoryFor:currCellGroup];
            if (rightButton != Nil) {
                pinView.rightCalloutAccessoryView = rightButton;
            }
            
           [currCellGroup setPinImageAnnotation:FALSE pinView:pinView];

        }

#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
        CellGroupAnnotationView* pinView = (CellGroupAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
        
        if (!pinView) {
            
            pinView = [[CellGroupAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
 
            pinView.theMapView = theMapView;
            pinView.mapDelegate = self.delegate;
            
            // required to detect when user select the annotation to display the call out
            pinView.frame = CGRectMake(0, 0, 28, 51);
            pinView.canShowCallout = YES;
            NSButton* rightButton = [self getCalloutAccessoryFor:pinView];
                        
            if (rightButton != Nil) {
                pinView.rightCalloutAccessoryView = rightButton;
            }
            
            [currCellGroup setPinImageAnnotation:FALSE pinView:pinView];

        } else {
            pinView.theMapView = theMapView;
            pinView.mapDelegate = self.delegate;
        }
        

#endif

        return pinView;
        
    } else {
        return Nil;
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *) view {
    NSLog(@"didSelectAnnotationView called");
    if ([view.annotation isKindOfClass:[CellMonitoringGroup class]]) {
        NSLog(@"didSelectAnnotationView Group");
        [self configureDetailView:view];
    }
}

-(void) configureDetailView:(MKAnnotationView*) annotationView {
    NSLog(@"configureDetailView called");
    UIView* snapshotView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];

    MKMapSnapshotOptions* options = [[MKMapSnapshotOptions alloc] init];
    options.size = CGSizeMake(300, 300);
    options.mapType = MKMapTypeSatelliteFlyover;


    MKMapCamera* camera = [MKMapCamera cameraLookingAtCenterCoordinate:annotationView.annotation.coordinate
                                                          fromDistance:500
                                                                 pitch:65
                                                               heading:0];
    options.camera = camera;

    MKMapSnapshotter* snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    [snapshotter startWithCompletionHandler:^(MKMapSnapshot * _Nullable snapshot, NSError * _Nullable error) {
        if (snapshot != nil) {
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
            imageView.image = snapshot.image;
            [snapshotView addSubview:imageView];
        }
    }];

    annotationView.detailCalloutAccessoryView = snapshotView;

}

#if TARGET_OS_IPHONE
- (UIButton*) getCalloutAccessoryFor:(CellMonitoringGroup*) currCellGroup {
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
- (NSButton*) getCalloutAccessoryFor:(CellMonitoringGroup*) currCellGroup {
#endif
    return Nil;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay {
    if ([overlay isKindOfClass:[NeighborOverlay class]]) {
        NeighborOverlay* AzmuthPoly = (NeighborOverlay*) overlay;
        return AzmuthPoly.polylineView;
    } else if ([overlay isKindOfClass:[AzimuthsOverlay class]]) {
        AzimuthsOverlay* AzmuthPoly = (AzimuthsOverlay*) overlay;
        return [AzmuthPoly getAzimuthOverlay];
    } else if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
#if TARGET_OS_IPHONE
        renderer.strokeColor = [UIColor blueColor];
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
        renderer.strokeColor = [NSColor blueColor];
#endif
        renderer.lineWidth = 5.0;
        return renderer;
    } else if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircle* theCircle = overlay;
        MKCircleRenderer*    theCircleView = [[MKCircleRenderer alloc] initWithCircle:theCircle];
        
        if (mapView.mapType == MKMapTypeHybridFlyover) {
#if TARGET_OS_IPHONE
            theCircleView.fillColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
            theCircleView.fillColor = [[NSColor whiteColor] colorWithAlphaComponent:0.3];
#endif
        } else {
#if TARGET_OS_IPHONE
            theCircleView.fillColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
            theCircleView.fillColor = [[NSColor blackColor] colorWithAlphaComponent:0.3];
#endif
        }
#if TARGET_OS_IPHONE
        theCircleView.strokeColor = [[UIColor redColor] colorWithAlphaComponent:0.6];
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
        theCircleView.strokeColor = [[NSColor redColor] colorWithAlphaComponent:0.6];
#endif
       theCircleView.lineWidth = 3;
        return theCircleView;
    } else {
        return Nil;
    }
}


@end
