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

@interface ConfigViewData() 

@property (nonatomic, weak) id<ConfigViewDataResponse> delegate;

@end

@implementation ConfigViewData


- (id) init:(id<ConfigViewDataResponse>) theDelegate; {

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

#pragma mark - HTMLDataResponse Protocol
- (void) dataReady: (id) theData clientId:(NSString *)theClientId {
    
    if ([theClientId isEqualToString:@"connect"]) {
        
        NSDictionary* data = theData;

        if (data.count >= 2) {
            NSNumber* dataValue = data[@"connectionStatus"];
            NSUInteger value = dataValue.intValue;

            dataValue = data[@"isAdmin"];
            [DataCenter sharedInstance].isAdminUser = dataValue.boolValue;

            switch (value) {
                case 0: {
                    [RequestUtilities getKPIDictionaries:self clientId:@"getKPIDictionaries"];               
                    break;
                }
                case 1: {
                    [MBProgressHUD hideHUDForView:[_delegate getView] animated:YES];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Failure" message:@"Invalid user name" delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                    [alert show];        
                    break;
                }
                case 2: {
                    [MBProgressHUD hideHUDForView:[_delegate getView] animated:YES];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Failure" message:@"Invalid password" delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                    [alert show];
                    break;
                }
                default:
                    [MBProgressHUD hideHUDForView:[_delegate getView] animated:YES];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Failure" message:@"Error unknown" delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                    [alert show];
                    break;
            }
        } else {
            [MBProgressHUD hideHUDForView:[_delegate getView] animated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Server has provided an invalid response" delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];

        }

    } else {
        
        [MBProgressHUD hideHUDForView:[_delegate getView] animated:YES];

        if ([KPIDictionary loadKPIsdictionaries:theData] == false) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Configuration Error" message:@"Invalid KPI dictionary" delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];
            return;            
        }
        
                
        [_delegate connectionSuccess];
     }
}

- (void) connectionFailure:(NSString*) theClientId {
    [MBProgressHUD hideHUDForView:[_delegate getView] animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Failure" message:@"Cannot communicate with the server" delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alert show];        
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
