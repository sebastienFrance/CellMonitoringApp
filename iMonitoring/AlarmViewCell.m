//
//  AlarmViewCell.m
//  iMonitoring
//
//  Created by sébastien brugalières on 05/09/13.
//
//

#import "AlarmViewCell.h"
#import "DateUtility.h"
#import "CellMonitoring.h"
#import "Utility.h"

@implementation AlarmViewCell

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

- (void) initializeWithAlarm:(CellAlarm*) theAlarm cell:(CellMonitoring*) theCell {
    self.probableCauseLabel.text = theAlarm.probableCause;
    self.severityLabel.text = theAlarm.severityString;
    self.severityLabel.backgroundColor = theAlarm.severityColor;
    self.additionalTextLabel.text = theAlarm.additionalText;
    self.alarmTypeLabel.text = theAlarm.alarmTypeString;
    self.contentView.backgroundColor = theAlarm.severityLightColor;
   
    if (theCell.hasTimezone) {
        self.dateAndTimeLabel.text = [NSString stringWithFormat:@"%@ (%@)",[DateUtility getDateWithRealTimeZone:theAlarm.dateAndTime timezone:theCell.theTimezone option:withHHmmss], [Utility extractLongTimezoneFrom:theCell.theTimezone]];
    } else {
        self.dateAndTimeLocalTimeLabel.text = @"No cell local time";
    }
    
    
    self.dateAndTimeLocalTimeLabel.text = [NSString stringWithFormat:@"%@ (Local Time)",[DateUtility getDate:theAlarm.dateAndTime option:withHHmmss]];
    self.isAcknowledgedLabel.text = theAlarm.isAcknowledged ? @"True" : @"False";
}


@end
