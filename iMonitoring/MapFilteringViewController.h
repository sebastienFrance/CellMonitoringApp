//
//  MapFilteringViewController.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 14/09/2014.
//
//

#import <UIKit/UIKit.h>
#import "configurationUpdated.h"

@interface MapFilteringViewController : UITableViewController



@property (nonatomic, weak) id<configurationUpdated> delegate;

- (void) initFromPopover:(id<configurationUpdated>) theDelegate;

@end
