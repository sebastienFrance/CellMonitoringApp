//
//  ZoneKPIsAverageViewCell.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 23/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ZoneKPIsAverageViewCell.h"
#import "KPI.h"
#import "ZoneKPI.h"
#import "DataCenter.h"


@implementation ZoneKPIsAverageViewCell

@synthesize KPIName;
@synthesize KPIValueLastPeriod;
@synthesize KPIValueAverage;
@synthesize KPIColorAverage;
@synthesize KPIColorLastPeriod;
@synthesize labelAveragePeriod;
@synthesize labelLastPeriod;

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

- (void) initializeWith:(ZoneKPI*) zoneKPI {

    KPI* theKPI = zoneKPI.theKPI;

    self.KPIName.text = theKPI.name;
    self.KPIValueLastPeriod.text = [theKPI getDisplayableValueFromNumber:[zoneKPI getLastValue]];
    self.KPIValueAverage.text = [theKPI getDisplayableValueFromNumber:[zoneKPI getAverageValue]];
    self.KPIColorLastPeriod.backgroundColor = [theKPI getColorValueFromNumber:[zoneKPI getLastValue]];
    self.KPIColorAverage.backgroundColor = [theKPI getColorValueFromNumber:[zoneKPI getAverageValue]];

    MonitoringPeriodUtility* dc = [MonitoringPeriodUtility sharedInstance];
    self.labelLastPeriod.text = [MonitoringPeriodUtility getStringForGranularityPeriodName:dc.monitoringPeriod];
    self.labelAveragePeriod.text = [MonitoringPeriodUtility getStringForGranularityPeriodDuration:dc.monitoringPeriod];
    
    
    self.backgroundColor = [theKPI getBackgroundColorValueFromNumber:[zoneKPI getAverageValue]];

}

@end
