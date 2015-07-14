//
//  TechnoFilteringTableViewController.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 30/08/2014.
//
//

#import <UIKit/UIKit.h>
#import "BasicTypes.h"

@interface TechnoFilteringTableViewController : UITableViewController

-(void) initializeWith:(NSArray*) theCells techno:(DCTechnologyId) theTechno;

+(Boolean) hasSubFilter:(DCTechnologyId) theTechno;

@end
