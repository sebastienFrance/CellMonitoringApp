//
//  VisitedCellViewCell.h
//  iMonitoring
//
//  Created by sébastien brugalières on 29/04/13.
//
//

#import <UIKit/UIKit.h>

@class VisitedCell;

@interface VisitedCellViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *techno;
@property (weak, nonatomic) IBOutlet UILabel *lastVisitedDate;
@property (weak, nonatomic) IBOutlet UILabel *cellName;
@property (weak, nonatomic) IBOutlet UILabel *visitedCount;

- (void) initializeWithVisitedCell:(VisitedCell*) theVisitedCell;

@end
