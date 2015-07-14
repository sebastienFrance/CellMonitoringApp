//
//  KPIPrefConfiguration.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 13/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KPIPrefConfiguration.h"
#import "KPI.h"

@implementation KPIPrefConfiguration

@synthesize kpiformula;
@synthesize kpiName;
@synthesize kpiSwitch;
@synthesize kpiShortDescription;
@synthesize kpiUnit;

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

- (IBAction)switchControlPushed {
}

- (void) initWithKPI:(KPI *)theKPI {
    
    _theKPI = theKPI;
    
    kpiName.text = theKPI.name;
    kpiformula.text = theKPI.formula;
    kpiShortDescription.text = theKPI.shortDescription;
    kpiUnit.text = [NSString stringWithFormat:@"Unit: %@", theKPI.unit];
}

@end
