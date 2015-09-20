//
//  iPadDashboardViewController.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 07/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorstKPIDataSource.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "CorePlot-CocoaTouch.h"
#import "iPadDashboardZoneAverageViewController.h"
#import "ZoneKPIDataSource.h"


@interface iPadDashboardViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, CellKPIsLoadingItf, UIPopoverPresentationControllerDelegate>



@property (nonatomic) WorstKPIDataSource* theDatasource;

- (void) updateDashboardScope;

- (void) displayCellOnMap:(CellMonitoring*) theCellonMap;
- (void) displayCellKPIs:(CellMonitoring*) theCell;


@end
