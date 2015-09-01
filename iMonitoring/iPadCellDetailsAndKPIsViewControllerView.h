//
//  iPadCellDetailsAndKPIsViewControllerView.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 17/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellKPIsDataSource.h"
#import "CorePlot-CocoaTouch.h"
#import "MarkViewController.h"

@class KPIChart;
@interface iPadCellDetailsAndKPIsViewControllerView : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, MarkedCell,UIPopoverPresentationControllerDelegate>

@property (nonatomic) CellMonitoring* theCell;
@property (nonatomic) CellKPIsDataSource* theDatasource;



- (void) updateDashboardScope;

@end
