//
//  WorstViewSelection.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 14/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WorstViewSelection.h"
#import "AroundMeViewItf.h"
#import "cellDataSource.h"
#import "DateUtility.h"
#import "WorstKPIDataSource.h"
#import "Utility.h"
#import "DataCenter.h"

@implementation WorstViewSelection 

- (void) openView:(UIBarButtonItem*) sourceButton viewController:(id<DashboardSelectionDelegate>) theDelegate cancelButton:(Boolean) hasCancelButton {

    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Cell Dashboard"
                                                                   message:@"Select technology for the analysis"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    cellDataSource* aroundMeDataSource = [DataCenter sharedInstance].aroundMeItf.datasource;
    
    NSInteger index = 0;
    DCTechnologyId technoId = DCTechnologyUNKNOWN;
    Boolean hasCells = FALSE;

   for (NSNumber* techno in [BasicTypes getImplementedTechnos]) {
       DCTechnologyId currentTechno = [techno intValue];

       NSUInteger cellCount = [aroundMeDataSource getFilteredCellCountForTechnoId:currentTechno];
       if (cellCount > 0) {
           NSString *buttonString = [NSString stringWithFormat:@"%@ (%lu cells)",[BasicTypes getTechnoName:currentTechno], (unsigned long)cellCount];
           UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:buttonString style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [theDelegate showSelectedDashboard:currentTechno];                                                                                 }
                                           ];
           [alert addAction:defaultAction];
           index++;
           technoId = currentTechno;
           hasCells = TRUE;
       }
    }

    WorstKPIDataSource* lastWorstKPIs = [DataCenter sharedInstance].aroundMeItf.lastWorstKPIs;
    if (lastWorstKPIs != Nil) {
        NSString* dateRequest = [DateUtility  getDate:lastWorstKPIs.requestDate option:withHHmm];
        NSString* buttonString = [NSString stringWithFormat:@"%@ from %@",[BasicTypes getTechnoName:lastWorstKPIs.technology], dateRequest];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:buttonString style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [theDelegate showSelectedDashboard:DCTechnologyLatestUsed];                                                                            }
                                        ];
        [alert addAction:defaultAction];
        index++;
    }

    if (hasCancelButton) {
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [alert dismissViewControllerAnimated:TRUE completion:Nil];
                                                             }];
        [alert addAction:cancelAction];
        index++;
    }


    // 2 because there're the "Cancel button" and the button for at least 1 techno
    UIViewController* theViewController = [theDelegate getViewController];
    if ((index > 1 && hasCancelButton == FALSE) ||
        (index > 2 && hasCancelButton == TRUE)) {
        // Display the Alert View else compute directly worst cell for the only one techno available
        UIPopoverPresentationController* popover = alert.popoverPresentationController;
        popover.barButtonItem = sourceButton;
        [theViewController presentViewController:alert animated:YES completion:nil];
     } else {
        if (hasCells == TRUE) {
            [theDelegate showSelectedDashboard:technoId];
        } else {
            UIAlertController* alert = [Utility getSimpleAlertView:@"Invalid data"
                                                           message:@"Cannot compute on an empty cell zone."
                                                       actionTitle:@"OK"];
            [theViewController presentViewController:alert animated:YES completion:nil];
        }
    }
}



@end
