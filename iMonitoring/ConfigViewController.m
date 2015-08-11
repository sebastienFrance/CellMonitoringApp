//
//  ConfigViewController.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 06/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConfigViewController.h"
#import "ConfigViewData.h"
#import "DataCenter.h"
#import "iMonitoringMainViewController.h"
#import "MBProgressHUD.h"
#import "RequestUtilities.h"
#import "iMonitoringMainViewController.h"
#import "iMonitoring.h"
#import "AroundMeViewController.h"
#import "AroundMeViewItf.h"
#import "AroundMeImpl.h"
#import "RequestLicense.h"
#import "UserHelp.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "UserPreferences.h"

@interface ConfigViewController ()

@property (nonatomic) ConfigViewData* theData;

@property (weak, nonatomic) IBOutlet UITextField *IPAddress;
@property (weak, nonatomic) IBOutlet UITextField *portNumber;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;

@property (nonatomic) RequestLicense* requestALicence;

@end


@implementation ConfigViewController


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == self.IPAddress) {
        [self.portNumber becomeFirstResponder];
    } else if (textField == self.portNumber) {
        [self.userName becomeFirstResponder];
    } else if (textField == self.userName) {
        [self.password becomeFirstResponder];
    } else if (textField == self.password) {
        [textField resignFirstResponder];
    }
    
    return NO;
}


- (void) connectionSuccess {
    if ([DataCenter sharedInstance].isDemoSession) {
        [[UserHelp sharedInstance] startHelpWithoutLogin:self];
    } else {
        [[UserHelp sharedInstance] startHelp:self];
    }

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information"
                                                    message:@"Swipe graphic to increase/decrease time period"
                                                   delegate:Nil
                                          cancelButtonTitle:@"ok"
                                          otherButtonTitles:nil];
    [alert show];


    [self doConnectionSuccess];
}


-(void) doConnectionSuccess {
    [self dismissViewControllerAnimated:TRUE completion:Nil];
    
    DataCenter* dc = [DataCenter sharedInstance];
    
    BasicAroundMeImpl* aroundMe = (BasicAroundMeImpl*) dc.aroundMeItf;
    [aroundMe connectionCompleted];
    
    iMonitoring* app = (iMonitoring*)[UIApplication sharedApplication].delegate;
    if (app.navigationCells != Nil) {
        [aroundMe initializeFromNav:app.navigationCells];
        app.navigationCells = Nil;
    }
}

#pragma mark - Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"openEMSView"]) {
        SWRevealViewController* swController = segue.destinationViewController;
        [DataCenter sharedInstance].slidingViewController = swController;

        iMonitoring* app = (iMonitoring*) [UIApplication sharedApplication].delegate;
        if (app.navigationCells != Nil) {
            id<AroundMeViewItf> aroundMe = [DataCenter sharedInstance].aroundMeItf;
            [aroundMe initializeFromNav:app.navigationCells];
        }
    }
}

- (UIView*) getView {
    return self.view;
}

- (IBAction)ApplyCallback:(UIBarButtonItem *)sender {
    [self.theData openConnection:self.IPAddress.text portNumber:self.portNumber.text userName:self.userName.text password:self.password.text];
    
}

- (IBAction)requestLicensePushed:(UIButton *)sender {
    self.requestALicence = [[RequestLicense alloc] init];
    [self.requestALicence requestLicenseByMail:self];
}

- (IBAction)tryWithoutLicensePushed:(UIButton *)sender {

    [[DataCenter sharedInstance] startDemoSessionWithTimer];

    [self.theData openConnection:@"91.121.68.70" portNumber:@"8443" userName:@"democell" password:@"demoUser1234"];
}


- (void) viewWillAppear:(BOOL)animated {
    _theData = [[ConfigViewData alloc] init:self];
    
    self.IPAddress.text = _theData.IPAddress;
    self.portNumber.text = _theData.portNumber;
    self.userName.text = _theData.userName;
    
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.IPAddress.delegate = self;
    self.portNumber.delegate = self;
    self.userName.delegate = self;
    self.password.delegate = self;


    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    if (userPrefs.touchIdEnabled) {
        [self authenticateWithTouchId];
    }


}


-(void) authenticateWithTouchId {
    LAContext *context = [LAContext new];
    NSError *error;

    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:@"To connect CellMonitoring" reply:^(BOOL success, NSError *authenticationError) {
                    if (success) {
                        UserPreferences* userPrefs = [UserPreferences sharedInstance];
                        [self.theData openConnection:self.IPAddress.text portNumber:self.portNumber.text userName:self.userName.text password:userPrefs.ServerPassword];
                        
                    } else {
                        NSLog(@"Authentication with Touch ID failed");
                    }
                }
         ];
    }

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {

    [self dismissViewControllerAnimated:TRUE completion:Nil];
}


@end
