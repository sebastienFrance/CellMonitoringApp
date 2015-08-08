//
//  AroundMeMapViewDelegate.m
//  iMonitoring
//
//  Created by sébastien brugalières on 31/03/13.
//
//

#import "AroundMeMapViewDelegate.h"
#import "UserPreferences.h"
#import "CellMonitoring.h"
#import "NeighborOverlay.h"
#import "CellMonitoringGroup.h"
#import "BasicMapViewDelegate.h"
#import "MapDelegateItf.h"
#if TARGET_OS_MAC && !TARGET_OS_IPHONE
#import <Quartz/Quartz.h>
#endif

@interface AroundMeMapViewDelegate ()

@property (nonatomic) Boolean hasToReloadCells;
@property (nonatomic) NSMutableArray* animationCameras;

@end


@implementation AroundMeMapViewDelegate



- (void) goToCoordinate:(MKMapCamera*) endCamera MapView:(MKMapView*) theMapView reloadCells:(Boolean) forceToReloadCells {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    if (userPrefs.isMapAnimation) {
        [self goToCoordinateWithAnimation:endCamera MapView:theMapView reloadCells:forceToReloadCells];
    } else {
        [self goToCoordinateWithoutAnimation:endCamera MapView:theMapView reloadCells:forceToReloadCells];
    }
}


- (void) goToCoordinateWithoutAnimation:(MKMapCamera*) endCamera MapView:(MKMapView*) theMapView reloadCells:(Boolean) forceToReloadCells {
    self.hasToReloadCells = forceToReloadCells;
    [theMapView setCamera:endCamera animated:FALSE];
}

- (void) goToCoordinateWithAnimation:(MKMapCamera*) endCamera MapView:(MKMapView*) theMapView reloadCells:(Boolean) forceToReloadCells {
    
    self.hasToReloadCells = forceToReloadCells;
    
    MKMapCamera *startCamera = theMapView.camera;
    
    CLLocation* endLocation = [[CLLocation alloc] initWithCoordinate:endCamera.centerCoordinate
                                                            altitude:endCamera.altitude
                                                  horizontalAccuracy:0
                                                    verticalAccuracy:0
                                                           timestamp:[NSDate date]];
    CLLocation* startLocation = [[CLLocation alloc] initWithCoordinate:startCamera.centerCoordinate
                                                              altitude:startCamera.altitude
                                                    horizontalAccuracy:0
                                                      verticalAccuracy:0
                                                             timestamp:[NSDate date]];
    
    CLLocationDistance distance = [endLocation distanceFromLocation:startLocation];
    if (distance < 1000.0) {
        [self performsVeryShortCameraAnimation:endCamera MapView:theMapView];
    } else if (distance < 50000.0) {
        [self performsShortCameraAnimation:endCamera MapView:theMapView];
    } else {
        [self performsLongCameraAnimation:endCamera MapView:theMapView];
    }
    
}



- (void) performsVeryShortCameraAnimation:(MKMapCamera*) endCamera MapView:(MKMapView*) theMapView {
  
    self.animationCameras = [[NSMutableArray alloc] init];
    [theMapView setCamera:endCamera animated:TRUE];
}

- (void) performsShortCameraAnimation:(MKMapCamera*) endCamera MapView:(MKMapView*) theMapView {
    CLLocationCoordinate2D startCoordinate = theMapView.centerCoordinate;
    
    MKMapPoint startingPoint = MKMapPointForCoordinate(startCoordinate);
    MKMapPoint endingPoint = MKMapPointForCoordinate(endCamera.centerCoordinate);
    
    MKMapPoint midPoint = MKMapPointMake(startingPoint.x + ((startingPoint.x - endingPoint.x) / 2.0),
                                         startingPoint.y + ((startingPoint.y - endingPoint.y) / 2.0));
    
    CLLocationCoordinate2D midCoordinate = MKCoordinateForMapPoint(midPoint);
    CLLocationDistance midAltitude = endCamera.altitude * 4;
    
    MKMapCamera *midCamera = [MKMapCamera cameraLookingAtCenterCoordinate:endCamera.centerCoordinate
                                                        fromEyeCoordinate:midCoordinate
                                                              eyeAltitude:midAltitude];
    
    self.animationCameras = [[NSMutableArray alloc] init];
    [self.animationCameras addObject:midCamera];
    [self.animationCameras addObject:endCamera];
    
    [self goToNextCamera:theMapView];

}

- (void) performsLongCameraAnimation:(MKMapCamera*) endCamera MapView:(MKMapView*) theMapView {
 
    MKMapCamera* startCamera = theMapView.camera;
    CLLocation* startLocation = [[CLLocation alloc] initWithCoordinate:startCamera.centerCoordinate
                                                              altitude:startCamera.altitude
                                                    horizontalAccuracy:0
                                                      verticalAccuracy:0
                                                             timestamp:[NSDate date]];
   
    CLLocation* endLocation = [[CLLocation alloc] initWithCoordinate:endCamera.centerCoordinate
                                                            altitude:endCamera.altitude
                                                  horizontalAccuracy:0
                                                    verticalAccuracy:0
                                                           timestamp:[NSDate date]];

    CLLocationDistance distance = [endLocation distanceFromLocation:startLocation];

    CLLocationDistance midAltitude = distance;
    
    
    MKMapCamera *midCamera1 = [MKMapCamera cameraLookingAtCenterCoordinate:startCamera.centerCoordinate
                                                        fromEyeCoordinate:startCamera.centerCoordinate
                                                              eyeAltitude:midAltitude];
    MKMapCamera *midCamera2 = [MKMapCamera cameraLookingAtCenterCoordinate:endCamera.centerCoordinate
                                                         fromEyeCoordinate:endCamera.centerCoordinate
                                                               eyeAltitude:midAltitude];

    
    self.animationCameras = [[NSMutableArray alloc] init];
    [self.animationCameras addObject:midCamera1];
    [self.animationCameras addObject:midCamera2];
    [self.animationCameras addObject:endCamera];
    
    [self goToNextCamera:theMapView];
}

- (void) reloadCellsIfRequired {
    if (self.hasToReloadCells) {
        
        self.hasToReloadCells = FALSE;
        
        MapModeEnabled currentMapMode = self.delegateMode.currentMapMode;
        
        if (currentMapMode == MapModeDefault) {
            [self.delegate refreshMapContent];
        }
    } else {
        if ([UserPreferences sharedInstance].isAutomaticRefresh) {
            [self.delegate refreshMapContent];
        }
    }
    
    [self.delegate mapViewUpdated];
}

- (void) goToNextCamera:(MKMapView *)mapView  {
    if (self.animationCameras == Nil || self.animationCameras.count == 0) {
        [self reloadCellsIfRequired];
        return;
    }
    
    MKMapCamera *nextCamera = [self.animationCameras firstObject];
    [self.animationCameras removeObjectAtIndex:0];
#if TARGET_OS_IPHONE
    [UIView animateWithDuration:1.7
                     animations:^{
                         mapView.camera = nextCamera;
                     }];
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 1.0;
        context.allowsImplicitAnimation = YES;
        CAMediaTimingFunction *f = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        context.timingFunction = f;
        mapView.camera = nextCamera;
    }completionHandler:NULL];
#endif
    

}

#pragma mark - MKMapViewDelegate protocol
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (animated) {
        [self goToNextCamera:mapView];
    } else {
        if (self.animationCameras == Nil || self.animationCameras.count == 0) {
            [self reloadCellsIfRequired];
        }
    }
}



- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
  
}

#if TARGET_OS_IPHONE

- (UIButton*) getCalloutAccessoryFor:(CellMonitoringGroup*) currCellGroup {
    if (currCellGroup.hasVisibleCells) {
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        [rightButton addTarget:self
                        action:@selector(showDetails:)
              forControlEvents:UIControlEventTouchUpInside];
        return rightButton;
    } else {
        return Nil;
    }
}
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
- (NSButton*) getCalloutAccessoryFor:(CellGroupAnnotationView*) currCellGroup {
    if (currCellGroup.cellGroup.hasVisibleCells) {
        NSButton* rightButton = [[NSButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [rightButton setButtonType:NSMomentaryLightButton];
        [rightButton setBezelStyle:NSInlineBezelStyle];
        [rightButton setTitle:@"Cells"];
        [rightButton setTarget:currCellGroup];
        [rightButton setAction:@selector(showDetails:)];
        return rightButton;
    } else {
        return Nil;
    }
}
#endif

#if TARGET_OS_IPHONE

- (void)showDetails:(id)sender
{
    // Mandatory called by the accessory callout from the pin even if it's empty!
}
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
- (void)showDetails:(id)sender
{
    
    // Mandatory called by the accessory callout from the pin even if it's empty!
}

#endif

#if TARGET_OS_IPHONE
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    [mapView deselectAnnotation:view.annotation animated:YES];
    
    CellMonitoringGroup* theSelectedCell = (CellMonitoringGroup*) view.annotation;
    [self.delegate cellGroupSelectedOnMap:theSelectedCell annotationView:view];
}

#endif


@end
