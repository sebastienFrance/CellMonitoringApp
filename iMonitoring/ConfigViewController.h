//
//  ConfigViewController.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 06/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConfigViewData.h"
#import <MessageUI/MFMailComposeViewController.h>

@class iMonitoringMainViewController;
@class ConfigViewData;

@interface ConfigViewController : UIViewController <ConfigViewDataResponse, UITextFieldDelegate, MFMailComposeViewControllerDelegate>

// Can be overloaded by subclass to implement specific behavior when connection has been authenticated
-(void) doConnectionSuccess;

@end
