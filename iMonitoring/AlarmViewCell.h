//
//  AlarmViewCell.h
//  iMonitoring
//
//  Created by sébastien brugalières on 05/09/13.
//
//

#import <UIKit/UIKit.h>
#import "CellAlarm.h"
#import "CellMonitoring.h"

@interface AlarmViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *severityLabel;
@property (weak, nonatomic) IBOutlet UILabel *probableCauseLabel;
@property (weak, nonatomic) IBOutlet UILabel *alarmTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateAndTimeLocalTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateAndTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *isAcknowledgedLabel;
@property (weak, nonatomic) IBOutlet UILabel *additionalTextLabel;


- (void) initializeWithAlarm:(CellAlarm*) theAlarm cell:(CellMonitoring*) theCell;

@end
