//
//  DashboardWorstCellWindowController.h
//  iMonitoring
//
//  Created by sébastien brugalières on 03/01/2014.
//
//

#import <Cocoa/Cocoa.h>
#import "ExtendedTableView.h"
#import "ZoneKPIDataSource.h"

@class MainMapWindowController;
@class WorstKPIDataSource;


@interface DashboardWorstCellWindowController : NSWindowController<ExtendedTableViewDelegate, NSTableViewDataSource, NSTableViewDelegate,  NSWindowDelegate>

- (id)init:(MainMapWindowController*) theDelegate datasource:(WorstKPIDataSource*) theDatasource;


@end
