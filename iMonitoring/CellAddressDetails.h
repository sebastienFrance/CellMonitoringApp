//
//  CellAddressDetails.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 20/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoolButton.h"

@class CellMonitoring;

@interface CellAddressDetails : UITableViewCell




@property (weak, nonatomic) IBOutlet UILabel* cellName;
@property (weak, nonatomic) IBOutlet UILabel* techno;
@property (weak, nonatomic) IBOutlet UILabel *cellSite;
@property (weak, nonatomic) IBOutlet UILabel *cellRelease;


@property (weak, nonatomic) IBOutlet UILabel *dlFrequency;


@property (weak, nonatomic) IBOutlet UIImageView *sitePicture;

- (void) initializeWithCell:(CellMonitoring*) theCell;

@end
