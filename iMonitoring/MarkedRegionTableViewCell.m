//
//  MarkedRegionTableViewCell.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 31/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MarkedRegionTableViewCell.h"
#import "RegionBookmark.h"
#import "DateUtility.h"
#import "Utility.h"

@interface MarkedRegionTableViewCell()

@property (weak, nonatomic) IBOutlet UIView* theView;
@property (weak, nonatomic) IBOutlet UILabel* theRegionName;
@property (weak, nonatomic) IBOutlet UILabel* theDate;

@end

@implementation MarkedRegionTableViewCell



-(void) initWithRegionBookmark:(RegionBookmark*) currentRegion {
    self.theRegionName.text = currentRegion.name;
    self.backgroundColor = [Utility getLightColorForBookmark:currentRegion.color];
    self.theDate.text = [DateUtility getDate:currentRegion.creationDate option:withHHmm];
}

@end
