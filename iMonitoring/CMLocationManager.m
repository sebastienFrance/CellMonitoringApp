//
//  AroundMeLocationManager.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 21/08/2014.
//
//

#import "CMLocationManager.h"

@interface CMLocationManager()

@property(nonatomic) CLLocationManager* locationManager;
@property(nonatomic) id<LocationManagerDelegate> delegate;

@end

@implementation CMLocationManager



-(void) startLocation:(id<LocationManagerDelegate>) delegate {
    self.delegate = delegate;
    if ([CLLocationManager locationServicesEnabled] == FALSE) {
        [self raiseAlertForLocation:@"Please, enable location Services"];
    }

    if (self.locationManager == Nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }

    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
    } else {

        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status != kCLAuthorizationStatusAuthorizedWhenInUse) {
            [self raiseAlertForLocation:@"Please, enable Cell Monitoring in location Services"];
        }
    }
}


- (void) raiseAlertForLocation:(NSString*) theMessage {
#if TARGET_OS_IPHONE
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Localization failure"
                                                    message:theMessage
                                                   delegate:Nil
                                          cancelButtonTitle:@"ok"
                                          otherButtonTitles:nil];
    [alert show];
#else
    NSAlert* alert = [NSAlert alertWithMessageText:@"Localization failure"
                                     defaultButton:@"Cancel"
                                   alternateButton:Nil otherButton:Nil
                         informativeTextWithFormat:@"%@",theMessage];
    [alert runModal];
#endif

}

#pragma mark - CLLocationManagerDelegate protocol
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  //  NSLog(@"%s called", __PRETTY_FUNCTION__);
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%s called: %@", __PRETTY_FUNCTION__, error.localizedDescription);

}
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"%s called", __PRETTY_FUNCTION__);

    [self.delegate locationAutorization:status];
}

@end
