//
//  CellDetailsCellKPIViewCell.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 21/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellDetailsCellKPIViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* kpiValue;
@property (weak, nonatomic) IBOutlet UILabel* dateLocalTime;
@property (weak, nonatomic) IBOutlet UILabel* dateCellLocalTime;


@end
