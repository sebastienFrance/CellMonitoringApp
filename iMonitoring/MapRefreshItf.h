//
//  MapRefresh.h
//  iMonitoring
//
//  Created by sébastien brugalières on 18/12/2013.
//
//

#import <Foundation/Foundation.h>

@class MKRoute;
@class CellMonitoring;
@class RouteInformation;

@protocol MapRefreshItf <NSObject>

- (void) refreshMapWithFilter:(Boolean) refreshAnnotations overlays:(Boolean) refreshOverlays;
- (void) reloadCellsFromServer;

- (void) displayCoverage;

- (void) reloadCellsFromServerWithRouteAndDirection:(RouteInformation*) theRoute direction:(MKRoute*) theDirection;

- (NSArray*) getCellsFromMap;
- (void) showSelectedCellOnMap:(CellMonitoring*) cell;

@end
