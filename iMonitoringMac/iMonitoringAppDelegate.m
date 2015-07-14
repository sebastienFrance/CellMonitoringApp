//
//  iMonitoringAppDelegate.m
//  iMonitoringMac
//
//  Created by sébastien brugalières on 08/12/2013.
//
//

#import "iMonitoringAppDelegate.h"
#import "MainMapWindowController.h"
#import "LoginWindowController.h"

@interface iMonitoringAppDelegate()

@end


@implementation iMonitoringAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[MainMapWindowController sharedInstance] showWindow:self];
}

@end
