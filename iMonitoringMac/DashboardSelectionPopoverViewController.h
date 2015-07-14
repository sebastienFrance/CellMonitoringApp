//
//  DashboardSelectionPopoverViewController.h
//  iMonitoring
//
//  Created by sébastien brugalières on 19/01/2014.
//
//

#import <Cocoa/Cocoa.h>

@class cellDataSource;

@interface DashboardSelectionPopoverViewController : NSViewController<NSTableViewDataSource, NSTableViewDelegate>

-(id) init:(cellDataSource*) datasource;

@end
