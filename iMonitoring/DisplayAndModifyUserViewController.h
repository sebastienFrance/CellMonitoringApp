//
//  DisplayAndModifyUserViewController.h
//  iMonitoring
//
//  Created by sébastien brugalières on 25/10/13.
//
//

#import <UIKit/UIKit.h>
#import "RequestUtilities.h"

@class UserDescription;
@class UserListViewController;

@interface DisplayAndModifyUserViewController : UIViewController<HTMLDataResponse, UITextFieldDelegate>

- (void) initializeWithUser:(UserDescription*) theUser delegate:(UserListViewController*) theDelegate;

@end
