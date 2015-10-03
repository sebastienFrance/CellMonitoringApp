//
//  ChangePasswordViewController.m
//  iMonitoring
//
//  Created by sébastien brugalières on 17/10/13.
//
//

#import "ChangePasswordViewController.h"
#import "MBProgressHUD.h"
#import "DataCenter.h"
#import "RequestUtilities.h"
#import "PasswordUtility.h"
#import "ConnectionManager.h"
#import "Utility.h"

@interface ChangePasswordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *theNewPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *reTypeNewPasswordTextField;

@property (nonatomic) NSString* hashNewPassword;

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.oldPasswordTextField.delegate = self;
    self.theNewPasswordTextField.delegate = self;
    self.reTypeNewPasswordTextField.delegate = self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == self.oldPasswordTextField) {
        [self.theNewPasswordTextField becomeFirstResponder];
    } else if (textField == self.theNewPasswordTextField) {
        [self.reTypeNewPasswordTextField becomeFirstResponder];
    } else if (textField == self.reTypeNewPasswordTextField) {
        [textField resignFirstResponder];
    }
    
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)ApplyPasswordPushed:(UIBarButtonItem *)sender {
    if ([self.oldPasswordTextField.text isEqualToString:@""]) {
        UIAlertController* alert = [Utility getSimpleAlertView:@"Missing data"
                                                       message:@"Please enter old password."
                                                   actionTitle:@"OK"];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    PasswordValidityStatus passwordStatus = [PasswordUtility checkPasswordValidity:self.theNewPasswordTextField.text
                                                                            retype:self.reTypeNewPasswordTextField.text];
    if (passwordStatus != validPasswords) {
        UIAlertController* alert = [Utility getSimpleAlertView:@"Password error"
                                                       message:[PasswordUtility getPasswordErrorMessage:passwordStatus]
                                                   actionTitle:@"OK"];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    if ([self.theNewPasswordTextField.text isEqualToString:self.oldPasswordTextField.text]) {
        UIAlertController* alert = [Utility getSimpleAlertView:@"Incorrect data"
                                                       message:@"New and old password must be different."
                                                   actionTitle:@"OK"];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    self.hashNewPassword = [PasswordUtility hashStringForPassword:self.theNewPasswordTextField.text];
    NSString* hashOldPassword = [PasswordUtility hashStringForPassword:self.oldPasswordTextField.text];
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Updating Password";
    
    [RequestUtilities changePassword:hashOldPassword newPassword:self.hashNewPassword delegate:self clientId:@"changePassword"];
}

 // ---------- Parse the KPI dictionaries and go to the Main view controller -----------
- (void) dataReady: (id) theData clientId:(NSString *)theClientId {
    
    if ([theClientId isEqualToString:@"changePassword"]) {
        [[ConnectionManager sharedInstance] updatePassword:self.hashNewPassword];

        NSDictionary* data = theData;
        
        if (data.count >= 1) {
            NSNumber* connectStatus = data[@"Status"];
            NSUInteger value = connectStatus.intValue;
            
            switch (value) {
                case 0: {
                    [self dismissViewControllerAnimated:TRUE completion:Nil];
                    break;
                }
                case 1: {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    UIAlertController* alert = [Utility getSimpleAlertView:@"Password not updated"
                                                                   message:@"Unknown reason."
                                                               actionTitle:@"OK"];
                    [self presentViewController:alert animated:YES completion:nil];
                    break;
                }
                default:
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    UIAlertController* alert = [Utility getSimpleAlertView:@"Connection Failure"
                                                                   message:@"Error unknown."
                                                               actionTitle:@"OK"];
                    [self presentViewController:alert animated:YES completion:nil];
                    break;
            }
        }
    }
}


//  ----------- Cannot retreive the KPI dictionaries from the server ----------
- (void) connectionFailure:(NSString*) theClientId {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertController* alert = [Utility getSimpleAlertView:@"Connection Failure"
                                                   message:@"Cannot communicate with the server."
                                               actionTitle:@"OK"];
    [self presentViewController:alert animated:YES completion:nil];
}





- (IBAction)CancelPasswordPushed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:TRUE completion:Nil];
}

@end
