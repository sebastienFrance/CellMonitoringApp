//
//  RouteInformation.h
//  iMonitoring
//
//  Created by sébastien brugalières on 27/12/2013.
//
//
#import <MapKit/MapKit.h>

@interface RouteInformation : NSObject

@property (nonatomic, readonly) CLLocationCoordinate2D routeStart;
@property (nonatomic, readonly) CLLocationCoordinate2D routeEnd;
@property (nonatomic, readonly) NSUInteger distanceLookup;
@property (nonatomic, readonly) MKDirectionsTransportType transportType;


-(id) initWithRouteInfo:(CLLocationCoordinate2D) start destination:(CLLocationCoordinate2D) end
               distance:(NSUInteger) distanceLookup
          transportType:(MKDirectionsTransportType) transport;

@end
