//
//  AroundMeViewController.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 07/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CMLocationManager.h"
#import "BasicAroundMeViewController.h"

@class CellMonitoringGroup;

@interface AroundMeViewController : BasicAroundMeViewController 


- (void) showCellGroupOnMap:(CellMonitoringGroup *)theSelectedCellGroup annotationView:(MKAnnotationView *)view;
- (void) connectionCompleted;
@end
