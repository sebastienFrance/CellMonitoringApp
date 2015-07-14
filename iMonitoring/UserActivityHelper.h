//
//  UserActivityHelper.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 18/11/2014.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "MapModeItf.h"
#import "AroundMeViewItf.h"

FOUNDATION_EXPORT  NSString *const ActivityTypeViewingCells;



@interface UserActivityHelper : NSObject

+(NSUserActivity*) initializeUserActivity:(id<NSUserActivityDelegate>) delegate;

+(NSDictionary*) arrayForViewingCells:(id<AroundMeViewItf>) aroundMe;
+(MKMapCamera*) mapCameraFromViewingCells:(NSUserActivity*) activity;
+(MapModeEnabled) mapMode:(NSUserActivity*) activity;
+(NSString*) zoneName:(NSUserActivity*) activity;
+(NSString*) centerCellNeighbor:(NSUserActivity*) activity;

@end
