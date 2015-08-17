//
//  iPadImonitoringViewController.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 18/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "RequestUtilities.h"
#import "CellsOnCoverageViewController.h"
#import "LocateCellTableViewController.h"
#import "MarkViewController.h"
#import "AroundMeViewItf.h"
#import "CellKPIsDataSource.h"
#import "WorstKPIDataSource.h"
#import "CMLocationManager.h"
#import "BasicAroundMeViewController.h"
#import "WorstViewSelection.h"

@class CellMonitoringGroup;


@interface iPadImonitoringViewController : BasicAroundMeViewController <UIPopoverPresentationControllerDelegate, DashboardSelectionDelegate>



- (void) showCellGroupOnMap:(CellMonitoringGroup *)theSelectedCellGroup annotationView:(MKAnnotationView *)view;

- (void) connectionCompleted;

- (void) dismissAllPopovers;
- (void) dismissDashboardView;

-(void) showDetailsKPIs:(CellKPIsDataSource*) cellDatasource;
-(void) showDashboard:(WorstKPIDataSource*) worstKPIs;


@end
