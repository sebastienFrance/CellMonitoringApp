//
//  iPadCellGroupViewCell.m
//  iMonitoring
//
//  Created by sébastien brugalières on 12/04/13.
//
//

#import "CellGroupViewCell.h"
#import "CellMonitoring.h"
#import "Utility.h"

@implementation CellGroupViewCell

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

- (void) initializeWithCell:(CellMonitoring*) theCell index:(NSUInteger) theIndex {
    self.cellName.text = theCell.id;
    self.techno.text = theCell.techno;
    self.releaseName.text = theCell.releaseName;
    self.site.text = theCell.fullSiteName;
    self.cellIcon.image = theCell.getPinImage;
    self.dlFrequency.text = [Utility displayLongDLFrequency:theCell.normalizedDLFrequency earfcn:theCell.dlFrequency];
    self.NeighborsButton.tag = theIndex;
}

@end
