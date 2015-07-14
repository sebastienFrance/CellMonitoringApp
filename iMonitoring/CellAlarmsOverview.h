//
//  CellAlarmsOverview.h
//  iMonitoring
//
//  Created by sébastien brugalières on 07/09/13.
//
//

#import <UIKit/UIKit.h>
@class CellAlarmDatasource;

@interface CellAlarmsOverview : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *CriticalNBLabel;
@property (weak, nonatomic) IBOutlet UILabel *MajorNBLabel;
@property (weak, nonatomic) IBOutlet UILabel *MinorNBLabel;
@property (weak, nonatomic) IBOutlet UILabel *WarningNBLabel;


- (void) initialize:(CellAlarmDatasource*) alarmDatasource;
- (void) initializeLoadingAlarms;

@end
