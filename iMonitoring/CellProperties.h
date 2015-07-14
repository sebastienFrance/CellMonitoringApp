//
//  CellProperties.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 13/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellProperties : UITableViewCell


@property (nonatomic, weak) IBOutlet UILabel* textCellLabel;
@property (nonatomic, weak) IBOutlet UILabel* detailedCellLabel;

@end
