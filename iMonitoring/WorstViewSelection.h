//
//  WorstViewSelection.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 14/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AroundMeViewItf.h"

@class WorstKPIDataSource;

@interface WorstViewSelection : NSObject<UIAlertViewDelegate> 
- (id) init:(id<AroundMeViewItf>) aroundMeVC viewController:(UIViewController*) viewControllerDelegate;
- (void) openView:(WorstKPIDataSource*) lastWorstKPIs;

@end
