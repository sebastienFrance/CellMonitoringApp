//
//  NeighborsLocateViewCell.h
//  iMonitoring
//
//  Created by sébastien brugalières on 30/10/12.
//
//

#import <UIKit/UIKit.h>

@class NeighborOverlay;

@interface NeighborsLocateViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *targetCellName;
@property (weak, nonatomic) IBOutlet UILabel *NeighborType;
@property (weak, nonatomic) IBOutlet UILabel *NeighborDistance;
@property (weak, nonatomic) IBOutlet UILabel *NeighborNoHO;
@property (weak, nonatomic) IBOutlet UILabel *NeighborNoRemove;
@property (weak, nonatomic) IBOutlet UILabel *NeighborMeasuredByANR;
@property (weak, nonatomic) IBOutlet UILabel *dlFrequency;
@property (weak, nonatomic) IBOutlet UILabel *AddedOrRemoved;

- (void) initializeWith:(NeighborOverlay*) neighbor;
- (void) initializeWith:(NeighborOverlay*) neighbor addedNeighbor:(Boolean) isAdded;

@end
