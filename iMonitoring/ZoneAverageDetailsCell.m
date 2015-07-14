//
//  ZoneAverageDetailsCell.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 26/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ZoneAverageDetailsCell.h"

@implementation ZoneAverageDetailsCell
@synthesize KPIValue;
@synthesize dateCellLocalTime;
@synthesize dateLocalTime;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
