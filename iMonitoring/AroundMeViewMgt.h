//
//  AroundMeViewMgt.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 04/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MarkViewController.h"
#import "LocateCellTableViewController.h"
#import "CellsOnCoverageViewController.h"
#import "MapModeItf.h"

@interface AroundMeViewMgt : NSObject <MarkedCell, DisplayRegion> 

- (id)init:(id<MapModeItf>) theMapMode map:(MKMapView*) theMapView;


@property (nonatomic, readonly) NSString* lastSearch;

@end
