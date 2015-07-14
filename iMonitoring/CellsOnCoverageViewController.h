//
//  CellsOnCoverageViewController.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 18/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MapRefreshItf;
@class CellMonitoring;

@interface CellsOnCoverageViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate>

@property (nonatomic, retain) id<MapRefreshItf> delegate;

@end


