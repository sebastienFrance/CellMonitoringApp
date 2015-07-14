//
//  BasicAroundMeViewController.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 22/11/2014.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "CellMonitoringGroup.h"
#import "CMLocationManager.h"
#import "MapConfigurationUpdate.h"
#import "AroundMeMapViewDelegate.h"


@interface BasicAroundMeViewController : UIViewController<LocationManagerDelegate, NSUserActivityDelegate, NSStreamDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *theMapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *infoButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;

@property(nonatomic) id<configurationUpdated> mapConfUpdate;

- (void) showCellGroupOnMap:(CellMonitoringGroup *)theSelectedCellGroup annotationView:(MKAnnotationView *)view;
- (void) refreshMapDisplayOptions;
- (MKMapView*) getMapView;

-(void) updateUserActivity;

- (void) connectionCompleted; // Should be overloaded in subclasses
- (void) dismissAllPopovers;

-(AroundMeMapViewDelegate*) initializeMapViewDelegate:(id<MapDelegateItf>) mapDelegate mapMode:(id<MapModeItf>) mode;


-(id<configurationUpdated>) initializeMapConfigurationUpdate:(id<MapModeItf>) theMapMode refresh:(id<MapRefreshItf>) theMapRefresh map:(MKMapView*) theMapView;

-(void) showToolbar;


@end
