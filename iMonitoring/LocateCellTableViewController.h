//
//  LocateCellTableViewController.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 19/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RequestUtilities.h"
#import "AroundMeProtocols.h"
#import <MapKit/MapKit.h>
#import "LocateCellDataSource.h"

@protocol DisplayRegion;

@interface LocateCellTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, LocateCellDelegate, UISearchResultsUpdating, UISearchBarDelegate>

@property (nonatomic, weak) id<DisplayRegion> delegate;

@end

