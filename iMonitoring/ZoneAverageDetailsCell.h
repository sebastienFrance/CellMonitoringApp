//
//  ZoneAverageDetailsCell.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 26/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZoneAverageDetailsCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* KPIValue;
@property (nonatomic, weak) IBOutlet UILabel* dateLocalTime;
@property (nonatomic, weak) IBOutlet UILabel* dateCellLocalTime;



@end
