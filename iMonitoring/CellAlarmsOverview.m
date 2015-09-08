//
//  CellAlarmsOverview.m
//  iMonitoring
//
//  Created by sébastien brugalières on 07/09/13.
//
//

#import "CellAlarmsOverview.h"
#import "CellAlarm.h"
#import "CellAlarmDatasource.h"

@implementation CellAlarmsOverview

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) initializeLoadingAlarms {
    self.CriticalNBLabel.text = @"loading";
    self.MajorNBLabel.text = @"loading";
    self.MinorNBLabel.text = @"loading";
    self.WarningNBLabel.text = @"loading";
}


- (void) initialize:(CellAlarmDatasource*) alarmDatasource {
    
    self.CriticalNBLabel.text = [NSString stringWithFormat:@" %lu ", (unsigned long)alarmDatasource.criticalAlarmCounter];
    if (alarmDatasource.criticalAlarmCounter >0) {
       self.CriticalNBLabel.backgroundColor = [CellAlarm getColorForSeverity:Critical];
    }
    
    self.MajorNBLabel.text = [NSString stringWithFormat:@" %lu ", (unsigned long)alarmDatasource.majorAlarmCounter];
    if (alarmDatasource.majorAlarmCounter > 0) {
        self.MajorNBLabel.backgroundColor = [CellAlarm getColorForSeverity:Major];
    }
    
    self.MinorNBLabel.text = [NSString stringWithFormat:@" %lu ", (unsigned long)alarmDatasource.minorAlarmCounter];
    if (alarmDatasource.minorAlarmCounter > 0) {
        self.MinorNBLabel.backgroundColor = [CellAlarm getColorForSeverity:Minor];
    }
    
    self.WarningNBLabel.text = [NSString stringWithFormat:@" %lu ", (unsigned long)alarmDatasource.warningAlarmCounter];
    if (alarmDatasource.warningAlarmCounter > 0) {
        self.WarningNBLabel.backgroundColor = [CellAlarm getColorForSeverity:Warning];
    }

    CellAlarm* alarmWithHighestSeverity = alarmDatasource.alarmWithHighestSeverity;
    if (alarmWithHighestSeverity != Nil) {
        self.contentView.superview.backgroundColor = alarmWithHighestSeverity.severityLightColor;
    }
}


@end
