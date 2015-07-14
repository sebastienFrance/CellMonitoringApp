//
//  KPIPrefConfiguration.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 13/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class KPI;

@interface KPIPrefConfiguration : UITableViewCell {
    KPI* _theKPI;
}


@property (weak, nonatomic) IBOutlet UISwitch* kpiSwitch;
@property (weak, nonatomic) IBOutlet UILabel* kpiName;
@property (weak, nonatomic) IBOutlet UILabel* kpiShortDescription;
@property (weak, nonatomic) IBOutlet UILabel* kpiformula;
@property (weak, nonatomic) IBOutlet UILabel* kpiUnit;


- (void) initWithKPI:(KPI*) theKPI;

@end
