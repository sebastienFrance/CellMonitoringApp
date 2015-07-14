//
//  VisitedCellViewCell.m
//  iMonitoring
//
//  Created by sébastien brugalières on 29/04/13.
//
//

#import "VisitedCellViewCell.h"
#import "VisitedCells+History.h"
#import "CellMonitoring.h"
#import "DateUtility.h"

@implementation VisitedCellViewCell

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

- (void) initializeWithVisitedCell:(VisitedCells*) theVisitedCell {
    self.cellName.text          = theVisitedCell.cellInternalName;
    self.techno.text            = [BasicTypes getTechnoName:theVisitedCell.theTechnology];
    self.lastVisitedDate.text   = [DateUtility getDate:theVisitedCell.lastVisitedDate option:withHHmm];
    self.visitedCount.text      = [NSString stringWithFormat:@"%lu", (unsigned long)[theVisitedCell.visitedCount unsignedIntegerValue]];
}

@end
