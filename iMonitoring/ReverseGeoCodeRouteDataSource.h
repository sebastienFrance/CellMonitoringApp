//
//  RouteDataSource.h
//  iMonitoring
//
//  Created by sébastien brugalières on 30/12/2013.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class AroundMeMapViewMgt;
@class RouteInformation;

@protocol RouteDataSourceDelegate;

@interface ReverseGeoCodeRouteDataSource : NSObject

-(id) init:(AroundMeMapViewMgt*) aroundMeMap delegate:(id<RouteDataSourceDelegate>) theDelegate;
-(void) reverseGeoCodeRoute:(NSString*) startFrom destination:(NSString*) destination
              transportType:(MKDirectionsTransportType) theTransportType border:(NSUInteger) theBorder;

@end


@protocol RouteDataSourceDelegate <NSObject>

-(void) reverseGeoCodeRouteResponse:(RouteInformation*) route error:(NSError*) theError;


@end