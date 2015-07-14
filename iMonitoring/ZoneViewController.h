//
//  ZoneViewController.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 07/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestUtilities.h"
#import "ZonesDatasSource.h"

@class Zone;

@interface ZoneViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, ZonesDatasSourceDelegate>

@property (weak, nonatomic) IBOutlet UITableView *theTable;

@end
