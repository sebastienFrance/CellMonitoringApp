//
//  iPadDashboardScopeViewCell.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 09/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "iPadDashboardScopeViewCell.h"

@implementation iPadDashboardScopeViewCell
@synthesize theTitleName;
@synthesize theShortComment;

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
