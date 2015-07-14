//
//  RequestLicense.h
//  iMonitoring
//
//  Created by sébastien brugalières on 15/03/2014.
//
//

#import <Foundation/Foundation.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface RequestLicense : NSObject <MFMailComposeViewControllerDelegate>

- (void) requestLicenseByMail:(UIViewController*) parentViewController;

@end
