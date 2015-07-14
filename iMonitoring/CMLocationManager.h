//
//  AroundMeLocationManager.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 21/08/2014.
//
//

#import <MapKit/MapKit.h>
#import <Foundation/Foundation.h>

@protocol LocationManagerDelegate;

@interface CMLocationManager : NSObject<CLLocationManagerDelegate>

-(void) startLocation:(id<LocationManagerDelegate>) delegate;

@end

@protocol LocationManagerDelegate

-(void) locationAutorization:(CLAuthorizationStatus)status;

@end