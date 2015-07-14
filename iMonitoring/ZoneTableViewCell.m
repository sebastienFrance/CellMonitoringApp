//
//  ZoneTableViewCell.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 08/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ZoneTableViewCell.h"
#import "Zone.h"

@implementation ZoneTableViewCell
@synthesize zoneName;
@synthesize zoneDescription;


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

-(void) initWithZone:(Zone*) currentZone {
    self.zoneName.text = currentZone.name;
    self.zoneDescription.text = currentZone.description;
}

@end
