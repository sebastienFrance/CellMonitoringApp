//
//  DisplayKPICell.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 21/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DisplayKPICell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* kpiName;

@property (weak, nonatomic) IBOutlet UILabel* kpiValue;

@property (weak, nonatomic) IBOutlet UILabel* kpiDescription;
@property (weak, nonatomic) IBOutlet UIView* severity;

@end
