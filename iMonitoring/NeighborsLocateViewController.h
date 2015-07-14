//
//  NeighborsLocateViewController.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 19/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AroundMeProtocols.h"
#import <MapKit/MapKit.h>
#import "KNPathTableViewController.h"

@class NeighborsDataSourceUtility;
@class HistoricalCellNeighborsData;

@interface NeighborsLocateViewController : KNPathTableViewController 



-(void) initiliazeWith:(NeighborsDataSourceUtility*) theDatasource delegate:(id<DisplayRegion>) theDelegate;

-(void) initializeWith:(HistoricalCellNeighborsData*) theHistoricalCellNR;



@end
