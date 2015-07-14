//
//  KPIsPrefListViewController.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 13/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataCenter.h"

@class iMonitoringMainViewController;

@interface KPIsPrefListViewController : UITableViewController {
@private
    NSArray* _sectionsHeader;
    NSDictionary* _KPIDictionary;
}

- (void) initTechno:(DCTechnologyId) theTechno;


@end


