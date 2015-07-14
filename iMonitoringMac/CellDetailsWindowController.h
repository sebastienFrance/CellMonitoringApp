//
//  CellDetailsWindowController.h
//  iMonitoring
//
//  Created by sébastien brugalières on 22/12/2013.
//
//

#import <Cocoa/Cocoa.h>
#import "CellParametersDataSource.h"
#import "CellAlarmDatasource.h"
#import "CellTimezoneDataSource.h"
#import "CellKPIsDataSource.h"
#import "ExtendedTableView.h"

@class CellMonitoring;
@class MainMapWindowController;

@interface CellDetailsWindowController : NSWindowController<CellAlarmListener, CellTimezoneDataSourceDelegate, CellParametersDataSourceDelegate, CellKPIsLoadingItf, NSTableViewDataSource, ExtendedTableViewDelegate, NSTableViewDelegate,NSTabViewDelegate>

- (id)initWithCell:(CellMonitoring*) cell mapWindowController:(MainMapWindowController*) delegate;

@end
