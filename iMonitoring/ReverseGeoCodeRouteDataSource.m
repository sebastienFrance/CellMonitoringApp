//
//  RouteDataSource.m
//  iMonitoring
//
//  Created by sébastien brugalières on 30/12/2013.
//
//

#import "ReverseGeoCodeRouteDataSource.h"
#import "AroundMeMapViewMgt.h"
#import "RouteInformation.h"


@interface ReverseGeoCodeRouteDataSource()

@property (nonatomic, weak) id<RouteDataSourceDelegate> delegate;
@property (nonatomic, weak) AroundMeMapViewMgt* aroundMeMapVC;


@property (nonatomic) CLLocation* sourceLocation;
@property (nonatomic) CLLocation* destinationaLocation;
@property (nonatomic) MKDirectionsTransportType transportType;
@property (nonatomic) NSUInteger lookUpBorder;

@end

@implementation ReverseGeoCodeRouteDataSource

- (id)init:(AroundMeMapViewMgt*) aroundMeMap delegate:(id<RouteDataSourceDelegate>) theDelegate {
    if (self = [super init] ) {
        _aroundMeMapVC = aroundMeMap;
        _delegate = theDelegate;
    }
    
    return self;
}


-(void) reverseGeoCodeRoute:(NSString*) startFrom destination:(NSString*) destination transportType:(MKDirectionsTransportType) theTransportType border:(NSUInteger) theBorder{

    
    self.transportType = theTransportType;
    self.lookUpBorder = theBorder;

    
    if ([startFrom isEqualToString:@"here"]) {
        MKUserLocation* userLocation = [self.aroundMeMapVC getUserLocation];
        self.sourceLocation = userLocation.location;
        [self reverseGeoCodeDestination:destination];
    } else {
        [self reverseGeoCodeSource:startFrom destination:destination];
    }
}

-(void) reverseGeoCodeSource:(NSString*) startFrom destination:(NSString*) destination {
    MKMapView* currentMap = self.aroundMeMapVC.theMapView;
    
#if TARGET_OS_IPHONE
    CLCircularRegion* aroundRegion = [[CLCircularRegion alloc] initWithCenter:currentMap.region.center
                                                                       radius:100000.0
                                                                   identifier:@"AreaRegion"];
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
    CLRegion* aroundRegion = [[CLRegion alloc] initCircularRegionWithCenter:currentMap.region.center
                                                                     radius:100000.0
                                                                 identifier:@"AreaRegion"];
#endif
    
    CLGeocoder* reverseGeoCoder = [[CLGeocoder alloc] init];
    [reverseGeoCoder geocodeAddressString:startFrom inRegion:aroundRegion completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error){
            NSError* error = [[NSError alloc] initWithDomain:@"Communication Error" code:1 userInfo:Nil];
            [self.delegate reverseGeoCodeRouteResponse:Nil error:error];
            return;
        }
        CLPlacemark* currentPlacemark = [placemarks lastObject];
        self.sourceLocation = currentPlacemark.location;
        
        [self reverseGeoCodeDestination:destination];
        
    }];
}

- (void) reverseGeoCodeDestination:(NSString*) destination {
    if ([destination isEqualToString:@"here"]) {
        MKUserLocation* userLocation = [self.aroundMeMapVC getUserLocation];
        self.destinationaLocation = userLocation.location;
        
        [self RequestCellsOnRoute];
    } else {
        MKMapView* currentMap = self.aroundMeMapVC.theMapView;
        
#if TARGET_OS_IPHONE
        CLCircularRegion* aroundRegion = [[CLCircularRegion alloc] initWithCenter:currentMap.region.center
                                                                           radius:100000.0
                                                                       identifier:@"AreaRegion"];
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
        CLRegion* aroundRegion = [[CLRegion alloc] initCircularRegionWithCenter:currentMap.region.center
                                                                         radius:100000.0
                                                                     identifier:@"AreaRegion"];
#endif
        
        CLGeocoder* reverseGeoCoder = [[CLGeocoder alloc] init];
        [reverseGeoCoder geocodeAddressString:destination inRegion:aroundRegion completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error){
                NSError* error = [[NSError alloc] initWithDomain:@"Communication Error" code:1 userInfo:Nil];
                [self.delegate reverseGeoCodeRouteResponse:Nil error:error];
                return;
            }
            
            
            CLPlacemark* currentPlacemark = [placemarks lastObject];
            self.destinationaLocation = currentPlacemark.location;
            
            [self RequestCellsOnRoute];
        }];
    }
}


- (void) RequestCellsOnRoute {
    RouteInformation* theRoute = [[RouteInformation alloc]
                                  initWithRouteInfo:self.sourceLocation.coordinate
                                  destination:self.destinationaLocation.coordinate
                                  distance:self.lookUpBorder
                                  transportType:self.transportType];

    [self.delegate reverseGeoCodeRouteResponse:theRoute error:Nil];
}


@end
