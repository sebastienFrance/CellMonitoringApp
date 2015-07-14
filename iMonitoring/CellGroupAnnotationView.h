//
//  CellGroupAnnotationView.h
//  iMonitoring
//
//  Created by sébastien brugalières on 21/12/2013.
//
//

#import <MapKit/MapKit.h>

#import "CellMonitoringGroup.h"

@protocol MapDelegateItf;

@interface CellGroupAnnotationView : MKAnnotationView

@property(nonatomic,weak) MKMapView* theMapView;
@property(nonatomic, weak) id<MapDelegateItf> mapDelegate;

@property(nonatomic, readonly) CellMonitoringGroup *cellGroup;

- (void)showDetails:(id)sender;
@end
