//
//  MapConfigurationUpdate.h
//  iMonitoring
//
//  Created by sébastien brugalières on 18/12/2013.
//
//

#import <Foundation/Foundation.h>
#import "configurationUpdated.h"
#import "MapModeItf.h"
#import "MapRefreshItf.h"
#import <MapKit/MapKit.h>

@interface MapConfigurationUpdate : NSObject<configurationUpdated>

- (id)init:(id<MapModeItf>) theMapMode refresh:(id<MapRefreshItf>) theMapRefresh map:(MKMapView*) theMapView;

@end
