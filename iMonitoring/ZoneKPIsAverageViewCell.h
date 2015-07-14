//
//  ZoneKPIsAverageViewCell.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 23/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZoneKPI;

@interface ZoneKPIsAverageViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* KPIName;
@property (nonatomic, weak) IBOutlet UILabel* KPIValueLastPeriod;
@property (nonatomic, weak) IBOutlet UILabel* KPIValueAverage;
@property (nonatomic, weak) IBOutlet UIView* KPIColorLastPeriod;
@property (nonatomic, weak) IBOutlet UIView* KPIColorAverage;

@property (nonatomic, weak) IBOutlet UILabel* labelLastPeriod;
@property (nonatomic, weak) IBOutlet UILabel* labelAveragePeriod;

- (void) initializeWith:(ZoneKPI*) zoneKPI;

@end
