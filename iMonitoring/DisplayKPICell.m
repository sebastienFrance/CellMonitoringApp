//
//  DisplayKPICell.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 21/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DisplayKPICell.h"
#import "KPI.h"

@interface DisplayKPICell()

@property (weak, nonatomic) IBOutlet UILabel* kpiName;

@property (weak, nonatomic) IBOutlet UILabel* kpiValue;

@property (weak, nonatomic) IBOutlet UILabel* kpiDescription;
@property (weak, nonatomic) IBOutlet UIView* severity;

@end

@implementation DisplayKPICell


-(void) initWith:(KPI*) cellKPI monitoringPeriod:(DCMonitoringPeriodView) monitoringPeriod KPIValues:(NSArray<NSNumber*>*) kpiValues date:(NSDate*) requestDate {
    self.kpiName.text = cellKPI.name;
    self.kpiDescription.text = cellKPI.shortDescription;

    if (kpiValues != Nil) {
        NSString* lastValue = [cellKPI getDisplayableValueFromNumber:[kpiValues lastObject]];
        NSString* beforeLastValue = Nil;
        if (kpiValues.count > 1) {
            beforeLastValue = [cellKPI getDisplayableValueFromNumber:kpiValues[(kpiValues.count - 2)]];
        }
        self.kpiValue.text = [KPI displayCurrentAndPreviousValue:lastValue
                                                        preValue:beforeLastValue
                                                monitoringPeriod:monitoringPeriod
                                                     requestDate:requestDate];

        if (cellKPI.hasDirection) {
            self.severity.hidden = FALSE;
            self.severity.backgroundColor = [cellKPI getColorValueFromNumber:[kpiValues lastObject]];
        } else {
            self.severity.hidden = TRUE;
        }

    } else {
        self.kpiValue.text = @"No value";
        self.severity.hidden = TRUE;
    }

}

-(void) isStillLoading {
    self.kpiValue.text = @"KPI is loading...";
    self.severity.hidden = TRUE;
}

@end
