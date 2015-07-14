//
//  CellDetailsPeriodCellKPIViewCell.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 03/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CellDetailsPeriodCellKPIViewCell.h"

@implementation CellDetailsPeriodCellKPIViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }

    _kpiValue.numberOfLines = 0;
    _period.numberOfLines = 0;
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
