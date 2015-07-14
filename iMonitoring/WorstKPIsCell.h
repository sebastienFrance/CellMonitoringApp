//
//  WorstKPIsCell.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 22/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CellWithKPIValues;


@interface WorstKPIsCell : UITableViewCell


@property (nonatomic, weak) IBOutlet UILabel* KPIName;
@property (nonatomic, weak) IBOutlet UILabel* cellName;
@property (nonatomic, weak) IBOutlet UILabel* KPIValue;
@property (nonatomic, weak) IBOutlet UILabel* lastPeriodName;

@property (nonatomic, weak) IBOutlet UILabel* cellNameAverage;
@property (nonatomic, weak) IBOutlet UILabel* KPIValueAverage;
@property (nonatomic, weak) IBOutlet UIView* KPIColorAverage;
@property (nonatomic, weak) IBOutlet UILabel* averagePeriodName;

@property (nonatomic, weak) IBOutlet UIView* KPIColor;

- (void) initializeWith:(CellWithKPIValues*) KPIsforACell cellAverage:(CellWithKPIValues*) KPIsforACellAverage;

@end
