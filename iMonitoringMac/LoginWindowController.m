//
//  LoginWindowController.m
//  iMonitoring
//
//  Created by sébastien brugalières on 08/12/2013.
//
//

#import "LoginWindowController.h"
#import "UserPreferences.h"

@interface LoginWindowController ()
@property (weak) IBOutlet NSTextField *IPAddressTextField;
@property (weak) IBOutlet NSTextField *portNumberTextField;
@property (weak) IBOutlet NSTextField *userNameTextField;
@property (weak) IBOutlet NSSecureTextField *passwordTextField;

@property (nonatomic) MacConfigData* theData;

@end

@implementation LoginWindowController

- (id)init
{
    self = [super initWithWindowNibName:@"LoginWindow"];
    
    // userClickedCloseOrOk= FALSE;  // Removed based on answer.
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.window center];
    
    _theData = [[MacConfigData alloc] init:self];

    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    self.IPAddressTextField.stringValue = userPrefs.ServerIPAddress;
    self.portNumberTextField.stringValue = [NSString stringWithFormat:@"%lu",(unsigned long)userPrefs.ServerPortNumber];
    self.userNameTextField.stringValue = userPrefs.ServerUserName;
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
- (IBAction)okButtonPushed:(NSButton *)sender {
    [self.theData openConnection:self.IPAddressTextField.stringValue
                      portNumber:self.portNumberTextField.stringValue
                        userName:self.userNameTextField.stringValue
                        password:self.passwordTextField.stringValue];
 
    
}
- (IBAction)exitButtonPushed:(NSButton *)sender {
    exit(1);
}

- (void) connectionSuccess {
    
    [[NSApplication sharedApplication] stopModal];
    [self close];
}


@end
