//
//  WorstViewSelection.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 14/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AroundMeViewItf.h"

@protocol DashboardSelectionDelegate<NSObject>

-(void) cancel;
-(void) showSelectedDashboard:(DCTechnologyId) selectedTechno;
-(UIViewController*) getViewController;

@end

@class WorstKPIDataSource;


@interface WorstViewSelection : NSObject 

- (void) openView:(UIBarButtonItem*) sourceButton viewController:(id<DashboardSelectionDelegate>) theDelegate cancelButton:(Boolean) hasCancelButton;

@end
