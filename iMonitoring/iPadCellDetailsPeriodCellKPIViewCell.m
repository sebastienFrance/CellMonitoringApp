//
//  iPadCellDetailsPeriodCellKPIViewCell.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 31/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "iPadCellDetailsPeriodCellKPIViewCell.h"

@implementation iPadCellDetailsPeriodCellKPIViewCell
@synthesize kpiValue;
@synthesize period;
@synthesize severity;

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
