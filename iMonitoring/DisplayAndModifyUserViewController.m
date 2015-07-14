//
//  DisplayAndModifyUserViewController.m
//  iMonitoring
//
//  Created by sébastien brugalières on 25/10/13.
//
//

#import "DisplayAndModifyUserViewController.h"
#import "UserDescription.h"
#import "DateUtility.h"
#import "RequestUtilities.h"
#import "MBProgressHUD.h"
#import "UserListViewController.h"
#import "PasswordUtility.h"

@interface DisplayAndModifyUserViewController ()
@property (weak, nonatomic) IBOutlet UILabel *creationDate;
@property (weak, nonatomic) IBOutlet UISwitch *isAdmin;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *retypePassword;
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *theDescription;
@property (weak, nonatomic) IBOutlet UITextView *userPasswordDescription;
@property (weak, nonatomic) IBOutlet UILabel *retypePasswordLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UILabel *userName;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *modifyButton;
@property (nonatomic) UserDescription* user;
@property (nonatomic) Boolean isEditMode;
@property (nonatomic) Boolean hasUpdatedUsers;

@property (weak, nonatomic) UITextField *activeTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *theScrollview;


@property (nonatomic, weak) UserListViewController* delegate;
@end

@implementation DisplayAndModifyUserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) initializeWithUser:(UserDescription*) theUser delegate:(UserListViewController *)theDelegate {
    
    self.user = theUser;
    self.delegate = theDelegate;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.hasUpdatedUsers = FALSE;
    
	// Disable all field
    [self endEditMode];
    
    // initialize all fields

    self.password.delegate = self;
    self.retypePassword.delegate = self;
    self.firstName.delegate = self;
    self.lastName.delegate = self;
    self.email.delegate = self;
    self.theDescription.delegate = self;

    self.userName.text = self.user.name;
    
    self.creationDate.text = [DateUtility getDate:self.user.creationDate option:withHHmmss];
    self.isAdmin.on = self.user.isAdmin;
    self.lastName.text = self.user.lastName;
    self.firstName.text = self.user.firstName;
    self.email.text = self.user.email;
    self.theDescription.text = self.user.userDescription;
    
    [self registerForKeyboardNotifications];

}


#pragma mark - Manage scrollView


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
- (IBAction)cancelButtonPushed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:TRUE completion:Nil];
    
    if (self.hasUpdatedUsers) {
        [self.delegate updateUserList];
    }
    
}
- (IBAction)modifyButtonPushed:(UIBarButtonItem *)sender {
    
    if (self.isEditMode == TRUE) {
        
        [self updateUser];
        
    } else {
        [self startEditMode];
    }
}

- (void) updateUser {
    
    NSString* hashPassword = @"";
    if (self.password.text.length > 0) {
        if ([PasswordUtility checkPasswordValidity:self.password.text retype:self.retypePassword.text] == FALSE) {
            return;
        }
        hashPassword = [PasswordUtility hashStringForPassword:self.password.text];
    }
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = [NSString stringWithFormat:@"Update user %@", self.user.name];
    
    
    [RequestUtilities updateUser:self.userName.text password:hashPassword description:self.theDescription.text
                       isAdmin:self.isAdmin.isOn firstName:self.firstName.text lastName:self.lastName.text email:self.email.text
                      delegate:self clientId:@"updateUser"];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.password) {
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



- (void) startEditMode {
    
    self.isEditMode = TRUE;
    
    self.modifyButton.title = @"Save";
    
    self.isAdmin.enabled = TRUE;
    self.password.enabled = TRUE;
    self.retypePassword.enabled = TRUE;
    self.firstName.enabled = TRUE;
    self.lastName.enabled = TRUE;
    self.email.enabled = TRUE;
    self.theDescription.enabled = TRUE;
    
    self.password.text = @"";
    self.userPasswordDescription.hidden = FALSE;
    
    self.retypePassword.hidden = FALSE;
    self.retypePasswordLabel.hidden = FALSE;
  
}

- (void) endEditMode {
    self.isEditMode = FALSE;

    self.modifyButton.title = @"Modify";
    
    self.creationDate.enabled = FALSE;
    self.isAdmin.enabled = FALSE;
    self.password.enabled = FALSE;
    self.retypePassword.enabled = FALSE;
    self.firstName.enabled = FALSE;
    self.lastName.enabled = FALSE;
    self.email.enabled = FALSE;
    self.theDescription.enabled = FALSE;
    self.userPasswordDescription.hidden = TRUE;
    
    self.password.text = @"12345";
    self.retypePassword.hidden = TRUE;
    self.retypePasswordLabel.hidden = TRUE;
}

#pragma mark - HTMLResponse

- (void) dataReady: (id) theData clientId:(NSString *)theClientId {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if ([theClientId isEqualToString:@"updateUser"]) {
        
        NSDictionary* data = theData;
        
        NSNumber* dataValue = data[@"Status"];
        NSUInteger value = dataValue.intValue;
        if (value != 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Execution error" message:@"Cannot add user" delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];
            return;
        }

        self.hasUpdatedUsers = TRUE;
        [self endEditMode];

        NSString* theSuccessMessage = [NSString stringWithFormat:@"User %@ has been updated", self.user.name];
        
        self.password.text = @"";
        self.retypePassword.text = @"";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:theSuccessMessage delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Execution error" message:@"User not updated" delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    }
}

//  ----------- Cannot retreive the KPI dictionaries from the server ----------
- (void) connectionFailure:(NSString*) theClientId {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Failure" message:@"User not updated" delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alert show];
}



@end
