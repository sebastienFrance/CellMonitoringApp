//
//  iPadDashboardScopeViewNRCell.m
//  iMonitoring
//
//  Created by sébastien brugalières on 03/01/13.
//
//

#import "iPadDashboardScopeViewNRCell.h"
#import "CellMonitoring.h"

@implementation iPadDashboardScopeViewNRCell

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

- (void) initializeWithCell:(CellMonitoring*) theCell {
    self.intraFreqNRs.text = [NSString stringWithFormat:@"%lu", (unsigned long)theCell.numberIntraFreqNR];
    self.interFreqNRs.text = [NSString stringWithFormat:@"%lu", (unsigned long)theCell.numberInterFreqNR];
    self.interRATNRs.text = [NSString stringWithFormat:@"%lu", (unsigned long)theCell.numberInterRATNR];
}

@end
