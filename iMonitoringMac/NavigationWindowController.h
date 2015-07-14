//
//  NavigationWindowController.h
//  iMonitoring
//
//  Created by sébastien brugalières on 30/12/2013.
//
//

#import <Cocoa/Cocoa.h>
#import "ReverseGeoCodeRouteDataSource.h"
#import "RouteDirectionDataSource.h"

@class MainMapWindowController;

@interface NavigationWindowController : NSWindowController<RouteDataSourceDelegate, RouteDirectionDataSourceDelegate, NSTableViewDataSource, NSTableViewDelegate>

- (id)init:(MainMapWindowController*) mainDelegate;

@end
