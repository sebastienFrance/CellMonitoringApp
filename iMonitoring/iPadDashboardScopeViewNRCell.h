//
//  iPadDashboardScopeViewNRCell.h
//  iMonitoring
//
//  Created by sébastien brugalières on 03/01/13.
//
//

#import <UIKit/UIKit.h>

@class CellMonitoring;

@interface iPadDashboardScopeViewNRCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *intraFreqNRs;
@property (weak, nonatomic) IBOutlet UILabel *interFreqNRs;
@property (weak, nonatomic) IBOutlet UILabel *interRATNRs;

- (void) initializeWithCell:(CellMonitoring*) theCell;

@end
