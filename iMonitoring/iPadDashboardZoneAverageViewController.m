//
//  iPadDashboardZoneAverageViewController.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 09/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "iPadDashboardZoneAverageViewController.h"
#import "ZoneAverageDetailsCell.h"
#import "ZoneAveragePeriodDetailsCell.h"
#import "MailAbstract.h"

@interface iPadDashboardZoneAverageViewController ()

@property (nonatomic) UIViewController* theMailPopover;

@end

@implementation iPadDashboardZoneAverageViewController


- (void) openMail:(UIBarButtonItem *)sender mail:(MailAbstract*) theMail {
    
    if (self.theMailPopover != Nil) {
        [self.theMailPopover dismissViewControllerAnimated:TRUE completion:Nil];
        self.theMailPopover = Nil;
    }
    
    self.theMailPopover = [theMail getActivityViewController];
    [self presentViewControllerInPopover:self.theMailPopover item:sender];
}

-(void) presentViewControllerInPopover:(UIViewController*) contentController item:(UIBarButtonItem *)theItem {
    contentController.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController* popPC = contentController.popoverPresentationController;
    popPC.barButtonItem = theItem;
    popPC.permittedArrowDirections = UIPopoverArrowDirectionAny;
    [self presentViewController:contentController animated:TRUE completion:Nil];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DCMonitoringPeriodView monitoringPeriodView = [[MonitoringPeriodUtility sharedInstance] monitoringPeriod];
    if ((monitoringPeriodView == last6Hours15MnView) ||
        (monitoringPeriodView == last24HoursHourlyView)) {
        return 77.0;
    } else {
        return 77.0;
    }
    
}


- (IBAction)DoneButtonPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:TRUE completion:Nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}




@end
