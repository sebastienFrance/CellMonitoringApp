//
//  iPadCellGroupViewCell.h
//  iMonitoring
//
//  Created by sébastien brugalières on 12/04/13.
//
//

#import <UIKit/UIKit.h>

@class CellMonitoring;

@interface CellGroupViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *cellName;
@property (weak, nonatomic) IBOutlet UILabel *techno;
@property (weak, nonatomic) IBOutlet UILabel *site;
@property (weak, nonatomic) IBOutlet UILabel *releaseName;
@property (weak, nonatomic) IBOutlet UIImageView *cellIcon;
@property (weak, nonatomic) IBOutlet UILabel *dlFrequency;
@property (weak, nonatomic) IBOutlet UIButton *NeighborsButton;


- (void) initializeWithCell:(CellMonitoring*) theCell index:(NSUInteger) theIndex;

@end
