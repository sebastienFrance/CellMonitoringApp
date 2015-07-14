//
//  WorstKPIsCell.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 22/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WorstKPIsCell.h"
#import "CellWithKPIValues.h"
#import "KPI.h"
#import "DataCenter.h"

@implementation WorstKPIsCell

@synthesize KPIName;
@synthesize cellName;
@synthesize KPIValue;
@synthesize KPIColor;
@synthesize cellNameAverage;
@synthesize KPIColorAverage;
@synthesize KPIValueAverage;
@synthesize lastPeriodName;
@synthesize averagePeriodName;

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

- (void) initializeWith:(CellWithKPIValues*) KPIsforACell cellAverage:(CellWithKPIValues*) KPIsforACellAverage{

    self.KPIName.text = KPIsforACell.theKPI.name;

    MonitoringPeriodUtility* dc = [MonitoringPeriodUtility sharedInstance];
    self.lastPeriodName.text = [MonitoringPeriodUtility getStringForGranularityPeriodName:dc.monitoringPeriod];
    self.averagePeriodName.text = [MonitoringPeriodUtility getStringForGranularityPeriodDuration:dc.monitoringPeriod];

    NSNumber* lastValueToBeDisplayed = KPIsforACell.lastKPIValue;
    NSNumber* averageValueToBeDisplayed = KPIsforACellAverage.averageValue;

    self.KPIValue.text = [KPIsforACell.theKPI getDisplayableValueFromNumber:lastValueToBeDisplayed];
    self.KPIValueAverage.text = [KPIsforACellAverage.theKPI getDisplayableValueFromNumber:averageValueToBeDisplayed];

    self.KPIColor.backgroundColor = [KPIsforACell.theKPI getColorValueFromNumber:lastValueToBeDisplayed];
    self.KPIColorAverage.backgroundColor = [KPIsforACellAverage.theKPI getColorValueFromNumber:averageValueToBeDisplayed];

    self.cellName.text = KPIsforACell.cellName;
    self.cellNameAverage.text = KPIsforACellAverage.cellName;

    self.backgroundColor = [KPIsforACell.theKPI getBackgroundColorValueFromNumber:averageValueToBeDisplayed];
}

@end
