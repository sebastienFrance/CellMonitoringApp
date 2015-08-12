//
//  CreateUserViewController.m
//  iMonitoring
//
//  Created by sébastien brugalières on 21/10/13.
//
//

#import "CreateUserViewController.h"
#import "MBProgressHUD.h"
#import "PasswordUtility.h"
#import "Utility.h"

@interface CreateUserViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *retypePassword;
@property (weak, nonatomic) IBOutlet UITextField *theDescription;
@property (weak, nonatomic) IBOutlet UISwitch *administratorSelector;
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UITextField *email;

@property (nonatomic) Boolean hasCreatedNewUsers;

@property (weak, nonatomic) IBOutlet UIScrollView *theScrollview;

@property (weak, nonatomic) UITextField *activeTextField;

@end

@implementation CreateUserViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.userName.delegate = self;
    self.password.delegate = self;
    self.retypePassword.delegate = self;
    self.theDescription.delegate = self;
    self.firstName.delegate = self;
    self.lastName.delegate = self;
    self.email.delegate = self;
    
    self.hasCreatedNewUsers = FALSE;
    
    [self registerForKeyboardNotifications];

}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.theScrollview.contentInset = contentInsets;
    self.theScrollview.scrollIndicatorInsets = contentInsets;
    
    
    CGRect aRect = self.theScrollview.frame;
    aRect.size.height -= kbSize.height;
    CGPoint origin = self.activeTextField.frame.origin ;
    origin.y += self.theScrollview.frame.origin.y;
    //origin.y += self.activeTextField.frame.size.height;
    origin.y -= self.theScrollview.contentOffset.y;
    
    //CGRect activeRect = self.activeTextField.frame;
    
    if (!CGRectContainsPoint(aRect, origin) ) {
        // self.theScrollview.frame.origin.y
        CGPoint scrollPoint = CGPointMake(0.0, self.activeTextField.frame.origin.y + self.activeTextField.frame.size.height - (aRect.size.height));
        [self.theScrollview setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.theScrollview.contentInset = contentInsets;
    self.theScrollview.scrollIndicatorInsets = contentInsets;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeTextField = nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)CancelUserCreationPushed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:TRUE completion:Nil];
    
    if (self.hasCreatedNewUsers) {
        [self.delegateUserList updateUserList];
    }
}



- (IBAction)CreateUserPushed:(UIBarButtonItem *)sender {
    
    if ([PasswordUtility checkUserNameValidity:self.userName.text] == FALSE) {
        UIAlertController* alert = [Utility getSimpleAlertView:@"Invalid user name"
                                                       message:@"It must contain at least 5 characters with only lower case letter and/or numbers."
                                                   actionTitle:@"OK"];
        [self presentViewController:alert animated:YES completion:nil];

        return;
    }

    PasswordValidityStatus passwordStatus = [PasswordUtility checkPasswordValidity:self.password.text
                                                                            retype:self.retypePassword.text];
    if (passwordStatus != validPasswords) {
        UIAlertController* alert = [Utility getSimpleAlertView:@"Password error"
                                                       message:[PasswordUtility getPasswordErrorMessage:passwordStatus]
                                                   actionTitle:@"OK"];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = [NSString stringWithFormat:@"Add User %@", self.userName.text];
    
    NSString* hashPassword = [PasswordUtility hashStringForPassword:self.password.text];
    
    [RequestUtilities addUsers:self.userName.text password:hashPassword description:self.theDescription.text
                       isAdmin:self.administratorSelector.isOn firstName:self.firstName.text lastName:self.lastName.text email:self.email.text
                      delegate:self clientId:@"addUser"];
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == self.userName) {
        [self.password becomeFirstResponder];
    } else if (textField == self.password) {
        [self.retypePassword becomeFirstResponder];
    } else if (textField == self.retypePassword) {
        [self.firstName becomeFirstResponder];
    } else if (textField == self.firstName) {
        [self.lastName becomeFirstResponder];
    } else if (textField == self.lastName) {
        [self.email becomeFirstResponder];
    } else if (textField == self.email) {
        [self.theDescription becomeFirstResponder];
    } else if (textField == self.theDescription) {
        [textField resignFirstResponder];
    }
    
    return NO;
}


#pragma mark - HTMLResponse

- (void) dataReady: (id) theData clientId:(NSString *)theClientId {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if ([theClientId isEqualToString:@"addUser"]) {
        
        NSDictionary* data = theData;
        
        NSNumber* dataValue = data[@"Status"];
        NSUInteger value = dataValue.intValue;
        if (value != 0) {
            UIAlertController* alert = [Utility getSimpleAlertView:@"Execution error"
                                                           message:@"Cannot add user."
                                                       actionTitle:@"OK"];
            [self presentViewController:alert animated:YES completion:nil];
           return;
        }
        
        self.hasCreatedNewUsers = TRUE;
        
        NSString* theSuccessMessage = [NSString stringWithFormat:@"User %@ has been created", self.userName.text];
        
        self.userName.text = @"";
        self.password.text = @"";
        self.retypePassword.text = @"";
        self.theDescription.text = @"";
        self.firstName.text = @"";
        self.lastName.text = @"";
        self.email.text = @"";
        self.administratorSelector.on = FALSE;
        
        UIAlertController* alert = [Utility getSimpleAlertView:@"Success"
                                                       message:theSuccessMessage
                                                   actionTitle:@"OK"];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        UIAlertController* alert = [Utility getSimpleAlertView:@"Execution error"
                                                       message:@"Cannot add user."
                                                   actionTitle:@"OK"];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

//  ----------- Cannot retreive the KPI dictionaries from the server ----------
- (void) connectionFailure:(NSString*) theClientId {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertController* alert = [Utility getSimpleAlertView:@"Connection Failure"
                                                   message:@"Cannot add user."
                                               actionTitle:@"OK"];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
