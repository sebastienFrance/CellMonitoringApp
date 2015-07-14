//
//  RouteDataSource.m
//  iMonitoring
//
//  Created by sébastien brugalières on 20/02/2014.
//
//

#import "RouteDirectionDataSource.h"
#import <MapKit/MapKit.h>
#import "RouteInformation.h"

@interface RouteDirectionDataSource()

@property(nonatomic, weak) id<RouteDirectionDataSourceDelegate> delegate;

@end

@implementation RouteDirectionDataSource

- (void) getDirectionsFor:(RouteInformation*) theRoute
                 delegate:(id<RouteDirectionDataSourceDelegate>) theDelegate {
    
    self.delegate = theDelegate;
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    MKPlacemark* sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:theRoute.routeStart addressDictionary:nil];
    request.source = [[MKMapItem alloc] initWithPlacemark:sourcePlacemark];
    
    MKPlacemark* destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:theRoute.routeEnd addressDictionary:nil];
    request.destination = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
    
    request.requestsAlternateRoutes = YES;
    request.transportType = theRoute.transportType;
    
    MKDirections *directions =[[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             NSError* error = [[NSError alloc] initWithDomain:@"Communication Error" code:1 userInfo:Nil];
             [self.delegate routeDirectionResponse:Nil error:error];
             
         } else {
             [self.delegate routeDirectionResponse:response.routes error:error];
         }
     }];
    
    
}


@end
