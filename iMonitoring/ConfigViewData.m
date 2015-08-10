//
//  ConfigViewData.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 01/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConfigViewData.h"
#import "DataCenter.h"
#import "iMonitoringMainViewController.h"
#import "MBProgressHUD.h"
#import "RequestUtilities.h"
#import "iMonitoringMainViewController.h"
#import "iMonitoring.h"
#import "KPIDictionary.h"
#import "UserPreferences.h"
#import "PasswordUtility.h"
#import "ConnectionManager.h"
#import "Utility.h"

@interface ConfigViewData() 

@property (nonatomic, weak) UIViewController<ConfigViewDataResponse>* delegate;

@end

@implementation ConfigViewData



- (id) init:(UIViewController<ConfigViewDataResponse>*) theDelegate; {

    if (self = [super init]) {
        _delegate = theDelegate;
   }
    
    return self;
}

- (void) openConnection:(NSString*) theIPAddress portNumber:(NSString*) thePortNumber userName:(NSString*) theUserName password:(NSString*) thePassword {

    if ([DataCenter sharedInstance].isDemoSession == FALSE) {
        UserPreferences* userPrefs = [UserPreferences sharedInstance];

        userPrefs.ServerPortNumber  = [thePortNumber intValue];
        userPrefs.ServerIPAddress   = theIPAddress;
        userPrefs.ServerUserName    = theUserName;
        userPrefs.ServerPassword    = thePassword;
    }

    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:[_delegate getView] animated:YES];
    hud.labelText = @"Loading Configuration";
    
    NSString* hashPassword = [PasswordUtility hashStringForPassword:thePassword];
    
    ConnectionManager* connMgr = [ConnectionManager sharedInstance];
    [connMgr setServerConfiguration:theIPAddress
                         portNumber:thePortNumber
                           userName:theUserName
                           password:hashPassword];
    
    [RequestUtilities connect:hashPassword delegate:self clientId:@"connect"];
}

typedef NS_ENUM(NSUInteger, ConnectionStatus) {
    ConnectionSuccess = 0,
    InvalidUserName = 1,
    InvalidUserPassword = 2,
};


#pragma mark - HTMLDataResponse Protocol
- (void) dataReady: (id) theData clientId:(NSString *)theClientId {
    
    if ([theClientId isEqualToString:@"connect"]) {
        
        NSDictionary* data = theData;

        if (data.count >= 2) {
            NSNumber* dataValue = data[@"connectionStatus"];
            ConnectionStatus value = dataValue.intValue;

            dataValue = data[@"isAdmin"];
            [DataCenter sharedInstance].isAdminUser = dataValue.boolValue;

            switch (value) {
                case ConnectionSuccess: {
                    [RequestUtilities getKPIDictionaries:self clientId:@"getKPIDictionaries"];               
                    break;
                }
                case InvalidUserName: {
                    [MBProgressHUD hideHUDForView:[_delegate getView] animated:YES];
                    UIAlertController *alert = [Utility getSimpleAlertView:@"Connection Failure"
                                                                   message:@"Invalid user name."
                                                               actionTitle:@"OK"];
                    [self.delegate presentViewController:alert animated:YES completion:nil];
                    break;
                }
                case InvalidUserPassword: {
                    [MBProgressHUD hideHUDForView:[_delegate getView] animated:YES];
                    UIAlertController *alert = [Utility getSimpleAlertView:@"Connection Failure"
                                                                   message:@"Invalid password."
                                                               actionTitle:@"OK"];
                    [self.delegate presentViewController:alert animated:YES completion:nil];
                    break;
                }
                default:
                    [MBProgressHUD hideHUDForView:[_delegate getView] animated:YES];
                    UIAlertController *alert = [Utility getSimpleAlertView:@"Connection Failure"
                                                                   message:@"Error unknown."
                                                               actionTitle:@"OK"];
                    [self.delegate presentViewController:alert animated:YES completion:nil];
                    break;
            }
        } else {
            [MBProgressHUD hideHUDForView:[_delegate getView] animated:YES];
            UIAlertController *alert = [Utility getSimpleAlertView:@"Connection Failure"
                                                           message:@"Server has provided an invalid response."
                                                       actionTitle:@"OK"];
            [self.delegate presentViewController:alert animated:YES completion:nil];
        }

    } else {

        [MBProgressHUD hideHUDForView:[_delegate getView] animated:YES];

        if ([KPIDictionary loadKPIsdictionaries:theData] == false) {
            UIAlertController *alert = [Utility getSimpleAlertView:@"Configuration Error"
                                                           message:@"Invalid KPI dictionary."
                                                       actionTitle:@"OK"];
            [self.delegate presentViewController:alert animated:YES completion:nil];
            return;
        }
        
                
        [_delegate connectionSuccess];
     }
}

- (void) connectionFailure:(NSString*) theClientId {
    [MBProgressHUD hideHUDForView:[_delegate getView] animated:YES];
    UIAlertController *alert = [Utility getSimpleAlertView:@"Connection Failure"
                                                   message:@"Cannot communicate with the server."
                                               actionTitle:@"OK"];
    [self.delegate presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Accessors
- (NSString*) IPAddress {
    return [UserPreferences sharedInstance].ServerIPAddress;
}

- (NSString*) portNumber {
    return [NSString stringWithFormat:@"%lu",(unsigned long)[UserPreferences sharedInstance].ServerPortNumber];
}

- (NSString*) userName {
    return [UserPreferences sharedInstance].ServerUserName;
}


@end
