//
//  DashboardViewSelection.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 07/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DashboardViewSelection.h"
#import "DataCenter.h"
#import "AroundMeViewItf.h"
#import "cellDataSource.h"
#import "DateUtility.h"
#import "WorstKPIDataSource.h"
#import "iPadImonitoringViewController.h"
#import "iPadAroundMeImpl.h"
#import "Utility.h"


@implementation DashboardViewSelection


- (void) dismiss {
    iPadAroundMeImpl* aroundMe = (iPadAroundMeImpl*) [DataCenter sharedInstance].aroundMeItf;
    [aroundMe cancelDashboardView];

}

- (void) openView:(UIBarButtonItem*) sourceButton viewController:(UIViewController*) theViewController {

    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Dashboard"
                                                                   message:@"Select technology for the analysis"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    NSInteger buttonIndex = 0;
    DCTechnologyId technoId = DCTechnologyUNKNOWN;

    cellDataSource* aroundMeDataSource = [DataCenter sharedInstance].aroundMeItf.datasource;
    
    Boolean hasCells = FALSE;

    for (NSNumber* techno in [BasicTypes getImplementedTechnos]) {
        DCTechnologyId currentTechno = [techno integerValue];

        NSUInteger cellCount = [aroundMeDataSource getFilteredCellCountForTechnoId:currentTechno];
        if (cellCount > 0) {
            NSString* buttonString = [NSString stringWithFormat:@"%@ (%lu cells)",[BasicTypes getTechnoName:currentTechno], (unsigned long)cellCount];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:buttonString style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      iPadAroundMeImpl* aroundMe = (iPadAroundMeImpl*) [DataCenter sharedInstance].aroundMeItf;
                                                                      [aroundMe cancelDashboardView];
                                                                      [aroundMe openDashboardView:currentTechno];
                                                                  }];

            [alert addAction:defaultAction];
            technoId = currentTechno;
            buttonIndex++;
            hasCells = TRUE;
        }
    }

    WorstKPIDataSource* lastWorstKPIs = [DataCenter sharedInstance].aroundMeItf.lastWorstKPIs;
    if (lastWorstKPIs != Nil) {
        NSString* dateRequest = [DateUtility  getDate:lastWorstKPIs.requestDate option:withHHmm];
        NSString* buttonString = [NSString stringWithFormat:@"%@ from %@",[BasicTypes getTechnoName:lastWorstKPIs.technology], dateRequest];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:buttonString style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  iPadAroundMeImpl* aroundMe = (iPadAroundMeImpl*) [DataCenter sharedInstance].aroundMeItf;
                                                                  [aroundMe cancelDashboardView];
                                                                  [aroundMe openDashboardView:DCTechnologyLatestUsed];
                                                              }];

        [alert addAction:defaultAction];
        buttonIndex++;
    }
    
    // Warning: compare with 1 because on iPad there is no Cancel button for it
    if (buttonIndex > 1) {
        // Display the Alert View else compute directly worst cell for the only one techno available

        UIPopoverPresentationController* popover = alert.popoverPresentationController;
        popover.barButtonItem = sourceButton;
        [theViewController presentViewController:alert animated:YES completion:nil];
    } else {
        iPadAroundMeImpl* aroundMe = (iPadAroundMeImpl*) [DataCenter sharedInstance].aroundMeItf;
        if (hasCells == TRUE) {
            [aroundMe cancelDashboardView];
            [aroundMe openDashboardView:technoId];
        } else {
            UIAlertController* alert = [Utility getSimpleAlertView:@"Invalid data"
                                                           message:@"Cannot compute on an empty cell zone"
                                                       actionTitle:@"OK"];
            [theViewController presentViewController:alert animated:YES completion:nil];
            [aroundMe cancelDashboardView];
        }
    }
}

@end
