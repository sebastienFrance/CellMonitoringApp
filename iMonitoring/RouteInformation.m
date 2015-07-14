//
//  RouteInformation.m
//  iMonitoring
//
//  Created by sébastien brugalières on 27/12/2013.
//
//

#import "RouteInformation.h"

@implementation RouteInformation

-(id) initWithRouteInfo:(CLLocationCoordinate2D) start destination:(CLLocationCoordinate2D) end
               distance:(NSUInteger) distanceLookup
          transportType:(MKDirectionsTransportType) transport {

    if (self = [super init] ) {
        _routeStart = start;
        _routeEnd = end;
        _distanceLookup = distanceLookup;
        _transportType = transport;
    }
    
    return self;

}



@end
