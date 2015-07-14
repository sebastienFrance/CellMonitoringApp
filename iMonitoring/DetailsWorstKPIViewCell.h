//
//  DetailsWorstKPIViewCell.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 23/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CellWithKPIValues;

@interface DetailsWorstKPIViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* cellName;
@property (nonatomic, weak) IBOutlet UILabel* KPIValue;
@property (weak, nonatomic) IBOutlet UIButton *MapButton;
@property (weak, nonatomic) IBOutlet UIButton *KPIsButton;


-(void) initWithCellKPIValues:(CellWithKPIValues*) cellData isWithAverage:(Boolean) isAverageKPIs index:(NSUInteger) theIndex;

@end
