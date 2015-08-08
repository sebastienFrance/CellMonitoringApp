//
//  MarkedRegionTableViewCell.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 31/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RegionBookmark;

@interface MarkedRegionTableViewCell : UITableViewCell

-(void) initWithRegionBookmark:(RegionBookmark*) currentRegion;

@end
