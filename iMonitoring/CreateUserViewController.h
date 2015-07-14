//
//  CreateUserViewController.h
//  iMonitoring
//
//  Created by sébastien brugalières on 21/10/13.
//
//

#import <UIKit/UIKit.h>
#import "RequestUtilities.h"
#import "UserListViewController.h"

@interface CreateUserViewController : UIViewController<UITextFieldDelegate, HTMLDataResponse>

@property (nonatomic, weak) UserListViewController* delegateUserList;

@end
