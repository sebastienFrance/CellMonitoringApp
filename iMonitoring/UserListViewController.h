//
//  UserListViewController.h
//  iMonitoring
//
//  Created by Sébastien Brugalières on 21/10/13.
//
//

#import <UIKit/UIKit.h>
#import "RequestUtilities.h"

@interface UserListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, HTMLDataResponse>


- (void) updateUserList;

@end
