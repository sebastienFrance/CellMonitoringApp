//
//  DashboardViewSelection.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 07/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AroundMeViewItf.h"

@class WorstKPIDataSource;

@interface DashboardViewSelection : NSObject<UIActionSheetDelegate>



- (void) openView:(UIBarButtonItem*) sourceButton;
- (void) dismiss;

@end
