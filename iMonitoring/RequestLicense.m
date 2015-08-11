//
//  RequestLicense.m
//  iMonitoring
//
//  Created by sébastien brugalières on 15/03/2014.
//
//

#import "RequestLicense.h"
#import "Utility.h"

@interface RequestLicense()

@property (nonatomic) UIViewController* presentingVC;

@end

@implementation RequestLicense


- (void) requestLicenseByMail:(UIViewController*) parentViewController {
    
    self.presentingVC = parentViewController;
    
    if ([MFMailComposeViewController canSendMail] == FALSE) {
        UIAlertController* alert = [Utility getSimpleAlertView:@"Mail error"
                                                       message:@"Your device cannot send an email."
                                                   actionTitle:@"OK"];
        [parentViewController presentViewController:alert animated:YES completion:nil];
    } else {
        MFMailComposeViewController* mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        
        [mailViewController setToRecipients:@[@"cellmonitoringrequest@gmail.com"]];
        [mailViewController setSubject:@"iMonitoring free license request"];
        
        
        NSMutableString* mailTemplate = [[NSMutableString alloc] init];
        [mailTemplate appendString:@"<style type=\"text/css\"> h2 {color:blue;} p {color:black;} </style>"];
        
        [mailTemplate appendFormat:@"<p>Please fill the information below to request a free temporary license</p>"];
        [mailTemplate appendFormat:@"<h2>User Informations </h2>"];
        [mailTemplate appendFormat:@"<ul><li>First name: </li>"];
        [mailTemplate appendFormat:@"<li>Last name: </li>"];
        [mailTemplate appendFormat:@"<li>Company: </li>"];
        [mailTemplate appendFormat:@"<li>Purpose: </li>"];
        [mailTemplate appendFormat:@"</ul>"];
        
        
        [mailViewController setMessageBody:mailTemplate isHTML:TRUE];
        
        [parentViewController presentViewController:mailViewController animated:TRUE completion:Nil];
    }

}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    [controller dismissViewControllerAnimated:TRUE completion:Nil];
}


@end
