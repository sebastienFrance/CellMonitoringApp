//
//  RouteDataSource.h
//  iMonitoring
//
//  Created by sébastien brugalières on 20/02/2014.
//
//

#import <Foundation/Foundation.h>

@class RouteInformation;
@protocol RouteDirectionDataSourceDelegate;

@interface RouteDirectionDataSource : NSObject


- (void) getDirectionsFor:(RouteInformation*) theRoute
                     delegate:(id<RouteDirectionDataSourceDelegate>) theDelegate;

@end


@protocol RouteDirectionDataSourceDelegate <NSObject>

-(void) routeDirectionResponse:(NSArray*) routes error:(NSError*) theError;


@end