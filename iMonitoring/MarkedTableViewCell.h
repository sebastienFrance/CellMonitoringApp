//
//  MarkedTableViewCell.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 28/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CellBookmark;

@interface MarkedTableViewCell : UITableViewCell



- (void) initialiazeWithCellBookmark:(CellBookmark*) theCellBookmark;

@end
