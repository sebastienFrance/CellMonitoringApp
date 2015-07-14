//
//  UserListViewCell.h
//  iMonitoring
//
//  Created by Sébastien Brugalières on 21/10/13.
//
//

#import <UIKit/UIKit.h>
#import "UserDescription.h"

@interface UserListViewCell : UITableViewCell

- (void) initializeWithUser:(UserDescription*) user;


@end
