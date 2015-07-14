//
//  UserHelp.m
//  CellMonitoring
//
//  Created by sébastien brugalières on 07/04/2014.
//
//

#import "UserHelp.h"
#import "UserPreferences.h"

@implementation UserHelp


+(UserHelp*)sharedInstance
{
    static dispatch_once_t pred;
    static UserHelp *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[UserHelp alloc] init];
    });
    return sharedInstance;
}

- (id)init{
    if (self = [super init] ) {
    }
    
    return self;
}

-(void) startHelp {
    if ([UserPreferences sharedInstance].startHelp) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information"
                                                        message:@"Try to locate cells in NYC, SF, Washington, Seattle, Paris, Lyon...\n\nEnjoy!"
                                                       delegate:Nil cancelButtonTitle:@"ok"
                                              otherButtonTitles:nil];
        [alert show];
        
        [UserPreferences sharedInstance].startHelp = FALSE;
    }
}

-(void) startHelpWithoutLogin {
    if ([UserPreferences sharedInstance].startWithoutLicenseHelp) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information"
                                                        message:@"Try to locate cells in NYC, SF, Washington, Seattle, Paris, Lyon...\n\nYour session will expires in 5mn!"
                                                       delegate:Nil
                                              cancelButtonTitle:@"ok"
                                              otherButtonTitles:nil];
        [alert show];
        
        [UserPreferences sharedInstance].startWithoutLicenseHelp = FALSE;
    }
}

-(void) iPadHelpForDashboardView {
    if ([UserPreferences sharedInstance].iPadDashboardHelp) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information"
                                                        message:@"Pinch graphics to zoom in/out\n\nTouch graphic for details"
                                                       delegate:Nil
                                              cancelButtonTitle:@"ok"
                                              otherButtonTitles:nil];
        [alert show];
        
        [UserPreferences sharedInstance].iPadDashboardHelp = FALSE;
    }
}

-(void) iPadHelpForCellDashboardView {
    if ([UserPreferences sharedInstance].iPadCellDashboardHelp) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information"
                                                        message:@"Pinch graphics to zoom in/out\n\nTouch graphic for details"
                                                       delegate:Nil
                                              cancelButtonTitle:@"ok"
                                              otherButtonTitles:nil];
        [alert show];
        
        [UserPreferences sharedInstance].iPadCellDashboardHelp = FALSE;
    }
}

-(void) helpForGenericGraphicKPI {
    if ([UserPreferences sharedInstance].helpForGenericGraphicKPI) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information"
                                                        message:@"Swipe graphic to increase/decrease time period"
                                                       delegate:Nil
                                              cancelButtonTitle:@"ok"
                                              otherButtonTitles:nil];
        [alert show];
        
        [UserPreferences sharedInstance].helpForGenericGraphicKPI = FALSE;
    }
    
}


@end
