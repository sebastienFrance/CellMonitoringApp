//
//  iPadAroundMeImpl.h
//  iMonitoring
//
//  Created by sébastien brugalières on 26/03/13.
//
//

#import <Foundation/Foundation.h>
#import "BasicAroundMeImpl.h"
#import "CellKPIsDataSource.h"
#import "WorstKPIDataSource.h"
#import "BasicAroundMeViewController.h"

@class iPadImonitoringViewController;

@interface iPadAroundMeImpl : BasicAroundMeImpl<CellKPIsLoadingItf, WorstKPIDataLoadingItf>

- (id) init:(BasicAroundMeViewController*) theViewController;

- (void) openDashboardView:(DCTechnologyId) technoId;
- (void) cancelDashboardView;

//- (void) dismissAllPopovers;

- (void) openDetailedKPIsView:(CellMonitoring*) theSelectedCell;

@end
