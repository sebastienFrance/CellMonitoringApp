//
//  DetailsWorstKPIViewCell.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 23/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailsWorstKPIViewCell.h"
#import "CellWithKPIValues.h"
#import "KPI.h"

@implementation DetailsWorstKPIViewCell
@synthesize KPIValue;
@synthesize cellName;

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

-(void) initWithCellKPIValues:(CellWithKPIValues*) cellData isWithAverage:(Boolean) isAverageKPIs index:(NSUInteger) theIndex {
    self.cellName.text = cellData.cellName;

    NSNumber* valueToBeDisplayed;
    if (isAverageKPIs == FALSE) {
        valueToBeDisplayed = cellData.lastKPIValue;
    } else {
        valueToBeDisplayed = cellData.averageValue;
    }

    self.KPIValue.text = [cellData.theKPI getDisplayableValueFromNumber:valueToBeDisplayed];

    self.backgroundColor = [cellData.theKPI getBackgroundColorValueFromNumber:valueToBeDisplayed];

    self.KPIsButton.tag = theIndex;
    self.MapButton.tag = theIndex;

}

@end
