//
//  UserActivityHelper.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 18/11/2014.
//
//

#import "UserActivityHelper.h"
#import "AroundMeViewItf.h"
#import "CellMonitoring.h"

@implementation UserActivityHelper

NSString *const ActivityTypeViewingCells = @"SebCompany.CellMonitoring.viewing-cells";
NSString *const ActivityTypeViewingCellsLatitude = @"latitude";
NSString *const ActivityTypeViewingCellsLongitude = @"longitude";
NSString *const ActivityTypeViewingCellsHeading = @"heading";
NSString *const ActivityTypeViewingCellsPitch = @"pitch";
NSString *const ActivityTypeViewingCellsAltitude = @"altitude";
NSString *const ActivityTypeMapMode = @"mapMode";
NSString *const ActivityTypeZoneName = @"zoneName";
NSString *const ActivityTypeCenterCellNeighbor = @"centerCellNeighbor";
NSString *const ActivityTypeVersion = @"version";


+(NSUserActivity*) initializeUserActivity:(id<NSUserActivityDelegate>) delegate {
    NSUserActivity* userActivity = [[NSUserActivity alloc] initWithActivityType:@"SebCompany.CellMonitoring.viewing-cells"];
    userActivity.title = @"Viewing cells";
    userActivity.supportsContinuationStreams = FALSE;
    userActivity.delegate = delegate;
    
    return userActivity;
}

+(NSDictionary*) arrayForViewingCells:(id<AroundMeViewItf>) aroundMe {
    
    MKMapView* theMapView = [aroundMe getMapView];
    
    NSNumber* heading = @(theMapView.camera.heading);
    NSNumber* pitch = @(theMapView.camera.pitch);
    NSNumber* altitude = @(theMapView.camera.altitude);
    NSNumber* latitude = @(theMapView.camera.centerCoordinate.latitude);
    NSNumber* longitude = @(theMapView.camera.centerCoordinate.longitude);
    NSNumber* mapMode = @(aroundMe.currentMapMode);
    
    switch (aroundMe.currentMapMode) {
        case MapModeZone: {
            return @{ActivityTypeViewingCellsLatitude : latitude,
                     ActivityTypeViewingCellsLongitude : longitude,
                     ActivityTypeViewingCellsHeading : heading,
                     ActivityTypeViewingCellsPitch : pitch,
                     ActivityTypeViewingCellsAltitude : altitude,
                     ActivityTypeMapMode : mapMode,
                     ActivityTypeZoneName : aroundMe.zoneName,
                     ActivityTypeVersion : @"1.0"};
        }
        case MapModeNeighbors: {
            return @{ActivityTypeViewingCellsLatitude : latitude,
                     ActivityTypeViewingCellsLongitude : longitude,
                     ActivityTypeViewingCellsHeading : heading,
                     ActivityTypeViewingCellsPitch : pitch,
                     ActivityTypeViewingCellsAltitude : altitude,
                     ActivityTypeMapMode : mapMode,
                     ActivityTypeCenterCellNeighbor : aroundMe.neighborCenterCell.id,
                     ActivityTypeVersion : @"1.0"};
        }
        default: {
            return @{ActivityTypeViewingCellsLatitude : latitude,
                     ActivityTypeViewingCellsLongitude : longitude,
                     ActivityTypeViewingCellsHeading : heading,
                     ActivityTypeViewingCellsPitch : pitch,
                     ActivityTypeViewingCellsAltitude : altitude,
                     ActivityTypeMapMode : mapMode,
                     ActivityTypeVersion : @"1.0"};
            
        }
    }
    
 }



+(MKMapCamera*) mapCameraFromViewingCells:(NSUserActivity*) activity {
    MKMapCamera* camera = [MKMapCamera camera];
    
    
    CLLocationCoordinate2D centerCoordinate;
    NSNumber* value = activity.userInfo[ActivityTypeViewingCellsLatitude];
    centerCoordinate.latitude = [value doubleValue];
    value = activity.userInfo[ActivityTypeViewingCellsLongitude];
    centerCoordinate.longitude = [value doubleValue];
    camera.centerCoordinate = centerCoordinate;
    
    value = activity.userInfo[ActivityTypeViewingCellsHeading];
    camera.heading = [value doubleValue];

    value = activity.userInfo[ActivityTypeViewingCellsPitch];
    camera.pitch = [value doubleValue];

    value = activity.userInfo[ActivityTypeViewingCellsAltitude];
    camera.altitude = [value doubleValue];

    return camera;
}

+(MapModeEnabled) mapMode:(NSUserActivity*) activity {
    NSNumber* mapModeValue = activity.userInfo[ActivityTypeMapMode];
    
    MapModeEnabled activityMapMode = MapModeDefault;
    if (mapModeValue != Nil) {
        activityMapMode = [mapModeValue unsignedIntegerValue];
    }
    
    return activityMapMode;
}

+(NSString*) zoneName:(NSUserActivity*) activity {
    MapModeEnabled theMapMode = [UserActivityHelper mapMode:activity];
    if (theMapMode == MapModeZone) {
        return activity.userInfo[ActivityTypeZoneName];
    } else {
        return Nil;
    }
}

+(NSString*) centerCellNeighbor:(NSUserActivity*) activity {
    MapModeEnabled theMapMode = [UserActivityHelper mapMode:activity];
    if (theMapMode == MapModeNeighbors) {
        return activity.userInfo[ActivityTypeCenterCellNeighbor];
    } else {
        return Nil;
    }
   
}



@end
