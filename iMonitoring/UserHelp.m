//
//  UserHelp.m
//  CellMonitoring
//
//  Created by sébastien brugalières on 07/04/2014.
//
//

#import "UserHelp.h"
#import "UserPreferences.h"
#import "Utility.h"

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

-(void) startHelp:(UIViewController*) controller {
    if ([UserPreferences sharedInstance].startHelp) {
        UIAlertController* alert = [Utility getSimpleAlertView:@"Information"
                                                       message:@"Try to locate cells in NYC, SF, Washington, Seattle, Paris, Lyon...\n\nEnjoy!"
                                                   actionTitle:@"OK"];
        [controller presentViewController:alert animated:YES completion:nil];
        [UserPreferences sharedInstance].startHelp = FALSE;
    }
}


-(void) iPadHelpForDashboardView:(UIViewController*) controller {
    if ([UserPreferences sharedInstance].iPadDashboardHelp) {
        UIAlertController* alert = [Utility getSimpleAlertView:@"Information"
                                                       message:@"Pinch graphics to zoom in/out\n\nTouch graphic for details"
                                                   actionTitle:@"OK"];
        [controller presentViewController:alert animated:YES completion:nil];
        [UserPreferences sharedInstance].iPadDashboardHelp = FALSE;
    }
}

-(void) iPadHelpForCellDashboardView:(UIViewController*) controller {
    if ([UserPreferences sharedInstance].iPadCellDashboardHelp) {
        UIAlertController* alert = [Utility getSimpleAlertView:@"Information"
                                                       message:@"Pinch graphics to zoom in/out\n\nTouch graphic for details"
                                                   actionTitle:@"OK"];
        [controller presentViewController:alert animated:YES completion:nil];
        [UserPreferences sharedInstance].iPadCellDashboardHelp = FALSE;
    }
}

-(void) helpForGenericGraphicKPI:(UIViewController*) controller {
    if ([UserPreferences sharedInstance].helpForGenericGraphicKPI) {
        UIAlertController* alert = [Utility getSimpleAlertView:@"Information"
                                                       message:@"Swipe graphic to increase/decrease time period"
                                                   actionTitle:@"OK"];
        [controller presentViewController:alert animated:YES completion:nil];
        [UserPreferences sharedInstance].helpForGenericGraphicKPI = FALSE;
    }
}


@end
