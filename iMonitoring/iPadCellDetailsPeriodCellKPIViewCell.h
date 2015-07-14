//
//  iPadCellDetailsPeriodCellKPIViewCell.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 31/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iPadCellDetailsPeriodCellKPIViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* kpiValue;
@property (weak, nonatomic) IBOutlet UILabel* period;
@property (weak, nonatomic) IBOutlet UIView* severity;

@end
