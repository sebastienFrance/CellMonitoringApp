//
//  CellAddressTableViewCell.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 31/08/2015.
//
//

#import <UIKit/UIKit.h>

@class CellMonitoring;

@interface CellAddressTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *theTimezone;

- (void) initializeCellAddress:(CellMonitoring*) theCell showBookmarkButton:(Boolean) withBookmarkButton;

@end
