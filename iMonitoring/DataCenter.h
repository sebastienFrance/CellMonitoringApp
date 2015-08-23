//
//  DataCenter.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 13/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "AroundMeViewItf.h"
#import "MonitoringPeriodUtility.h"
#import "SWRevealViewController/SWRevealViewController.h"
#import "BasicTypes.h"

@class AroundMeViewController;
@class CellMonitoring;
@class KPI;
@class CellBookmark;
@class RegionBookmark;
@class KPIDictionary;


@interface DataCenter : NSObject

@property (nonatomic) Boolean  isAdminUser;

@property (nonatomic, assign) Boolean isAppStarting;

@property (nonatomic) id<AroundMeViewItf> aroundMeItf;
@property (nonatomic) SWRevealViewController* slidingViewController;



+ (DataCenter*) sharedInstance;

@end
