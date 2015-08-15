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

@interface WorstViewSelection()

@property (nonatomic, weak) id<AroundMeViewItf> delegate;

@end

@implementation WorstViewSelection 

- (id) init:(id<AroundMeViewItf>) aroundMeVC  {
    if (self = [super init]) {
        _delegate = aroundMeVC;
    }
    
    return self;
    
}
- (void) openView:(WorstKPIDataSource*) lastWorstKPIs barButtton:(UIBarButtonItem*) sourceButton viewController:(UIViewController*) theViewController {

    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Cell Dashboard"
                                                                   message:@"Select technology for the analysis"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    cellDataSource* aroundMeDataSource = [self.delegate datasource];
    
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
                                                                     [theViewController performSegueWithIdentifier:@"openCellsKPIs" sender:@(currentTechno)];                                                                 }];
           [alert addAction:defaultAction];
           index++;
           technoId = currentTechno;
           hasCells = TRUE;
       }
    }

    if (lastWorstKPIs != Nil) {
        NSString* dateRequest = [DateUtility  getDate:lastWorstKPIs.requestDate option:withHHmm];
        NSString* buttonString = [NSString stringWithFormat:@"%@ from %@",[BasicTypes getTechnoName:lastWorstKPIs.technology], dateRequest];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:buttonString style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [theViewController performSegueWithIdentifier:@"openCellsKPIs" sender:@(DCTechnologyLatestUsed)];                                                              }];
        [alert addAction:defaultAction];
        index++;
    }

    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [alert dismissViewControllerAnimated:TRUE completion:Nil];
                                                          }];
    [alert addAction:cancelAction];
    index++;

    // 2 because there're the "Cancel button" and the button for at least 1 techno
    if (index > 2) {
        // Display the Alert View else compute directly worst cell for the only one techno available
        UIPopoverPresentationController* popover = alert.popoverPresentationController;
        popover.barButtonItem = sourceButton;
        [theViewController presentViewController:alert animated:YES completion:nil];
     } else {
        if (hasCells == TRUE) {
            [theViewController performSegueWithIdentifier:@"openCellsKPIs" sender:@(technoId)];
        } else {
            UIAlertController* alert = [Utility getSimpleAlertView:@"Invalid data"
                                                           message:@"Cannot compute on an empty cell zone."
                                                       actionTitle:@"OK"];
            [theViewController presentViewController:alert animated:YES completion:nil];
        }
    }
}



@end
