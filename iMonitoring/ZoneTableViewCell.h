//
//  ZoneTableViewCell.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 08/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Zone;

@interface ZoneTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* zoneName;
@property (weak, nonatomic) IBOutlet UILabel* zoneDescription;

-(void) initWithZone:(Zone*) currentZone;

@end
