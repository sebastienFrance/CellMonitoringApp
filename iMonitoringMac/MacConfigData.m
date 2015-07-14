//
//  MacConfigData.m
//  iMonitoring
//
//  Created by sébastien brugalières on 08/12/2013.
//
//

#import "MacConfigData.h"
#import "PasswordUtility.h"
#import "ConnectionManager.h"
#import "UserPreferences.h"
#import "KPIDictionary.h"

@interface MacConfigData()

@property (nonatomic, weak) id<MacConfigViewDataResponse> delegate;

@end

@implementation MacConfigData


- (id) init:(id<MacConfigViewDataResponse>) theDelegate; {
    
    if (self = [super init]) {
        _delegate = theDelegate;
    }
    
    return self;
}

- (void) openConnection:(NSString*) theIPAddress portNumber:(NSString*) thePortNumber userName:(NSString*) theUserName password:(NSString*) thePassword {
    
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    
    userPrefs.ServerPortNumber  = [thePortNumber intValue];
    userPrefs.ServerIPAddress   = theIPAddress;
    userPrefs.ServerUserName    = theUserName;
    userPrefs.ServerPassword    = thePassword;
    
    
//    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:[_delegate getView] animated:YES];
//    hud.labelText = @"Loading Configuration";
    
    NSString* hashPassword = [PasswordUtility hashStringForPassword:thePassword];
    ConnectionManager* center = [ConnectionManager sharedInstance];
    [center setServerConfiguration:theIPAddress portNumber:thePortNumber userName:theUserName password:hashPassword];
    
    [RequestUtilities connect:hashPassword delegate:self clientId:@"connect"];
}

#pragma mark - HTMLDataResponse Protocol
- (void) dataReady: (id) theData clientId:(NSString *)theClientId {
    
    if ([theClientId isEqualToString:@"connect"]) {
        
        NSDictionary* data = theData;
        
        if (data.count >= 2) {
            
            NSLog(@"Connecton has succeed!");
            
            NSNumber* dataValue = data[@"connectionStatus"];
            NSUInteger value = dataValue.intValue;
            
           // dataValue = data[@"isAdmin"];

            switch (value) {
                case 0: {
                    [RequestUtilities getKPIDictionaries:self clientId:@"getKPIDictionaries"];
                    break;
                }
                case 1: {
                    NSAlert* alert = [NSAlert alertWithMessageText:@"Connection Failure" defaultButton:@"Cancel" alternateButton:Nil otherButton:Nil informativeTextWithFormat:@"Invalid user name"];
                    [alert runModal];
                    break;
                }
                case 2: {
                    NSAlert* alert = [NSAlert alertWithMessageText:@"Connection Failure" defaultButton:@"Cancel" alternateButton:Nil otherButton:Nil informativeTextWithFormat:@"Invalid Password"];
                    [alert runModal];
                    break;
                }
                default: {
                    NSAlert* alert = [NSAlert alertWithMessageText:@"Connection Failure" defaultButton:@"Cancel" alternateButton:Nil otherButton:Nil informativeTextWithFormat:@"Error unknown"];
                    [alert runModal];
                }
            }
        } else {
            NSAlert* alert = [NSAlert alertWithMessageText:@"Connection Failure" defaultButton:@"Cancel" alternateButton:Nil otherButton:Nil informativeTextWithFormat:@"Server has provided an invalid response"];
            [alert runModal];
       }
        
    } else {
        if ([KPIDictionary loadKPIsdictionaries:theData] == false) {
            NSAlert* alert = [NSAlert alertWithMessageText:@"Configuration Error" defaultButton:@"Cancel" alternateButton:Nil otherButton:Nil informativeTextWithFormat:@"Invalid KPI dictionary"];
            [alert runModal];
            return;
       }
        
        
        [_delegate connectionSuccess];
    }
}

- (void) connectionFailure:(NSString*) theClientId {
    NSAlert* alert = [NSAlert alertWithMessageText:@"Connection Failure" defaultButton:@"Cancel" alternateButton:Nil otherButton:Nil informativeTextWithFormat:@"Cannot communicate with the server"];
    [alert runModal];
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
