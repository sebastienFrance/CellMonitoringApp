//
//  NeighborsLocateViewCell.m
//  iMonitoring
//
//  Created by sébastien brugalières on 30/10/12.
//
//

#import "NeighborsLocateViewCell.h"
#import "NeighborOverlay.h"
#import "CellMonitoring.h"
#import "Utility.h"

@implementation NeighborsLocateViewCell

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

- (void) initializeWith:(NeighborOverlay*) neighbor addedNeighbor:(Boolean) isAdded {
    [self initializeWith:neighbor];
    if (isAdded) {
        self.AddedOrRemoved.text = @"Added";
        self.AddedOrRemoved.textColor = [UIColor greenColor];
    } else {
        self.AddedOrRemoved.text = @"Removed";
        self.AddedOrRemoved.textColor = [UIColor redColor];
    }
}


- (void) initializeWith:(NeighborOverlay*) neighbor {
    
    if (neighbor.targetCell.id != Nil) {
        self.targetCellName.text = [NSString stringWithFormat:@"To %@", neighbor.targetCell.id];
    } else {
        self.targetCellName.text = [NSString stringWithFormat:@"To %@ (unknown)", neighbor.targetCellId];
    }
    self.NeighborDistance.text = neighbor.distance;
    self.NeighborMeasuredByANR.text = neighbor.measuredbyANR ? @"TRUE" : @"FALSE";
    self.NeighborNoHO.text = neighbor.noHo ? @"TRUE" : @"FALSE";
    self.NeighborNoRemove.text = neighbor.noRemove ? @"TRUE" : @"FALSE";

    float normalizedFreq = [Utility computeNormalizedDLFrequency:neighbor.dlFrequency];

    self.dlFrequency.text = [Utility displayShortDLFrequency:normalizedFreq]; //neighbor.dlFrequency;
    self.NeighborType.text = neighbor.NRTypeString;

    self.AddedOrRemoved.text = @""; // Not used by default so keep it empty
}

@end
