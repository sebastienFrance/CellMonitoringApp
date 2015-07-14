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

@interface WorstViewSelection()

@property (nonatomic) NSDictionary* mappingAlertViewButton;
@property (nonatomic, weak) id<AroundMeViewItf> delegate;
@property (nonatomic, weak) UIViewController* theViewControllerDelegate;

@end

@implementation WorstViewSelection 

- (id) init:(id<AroundMeViewItf>) aroundMeVC viewController:(UIViewController*) viewControllerDelegate {
    if (self = [super init]) {
        _delegate = aroundMeVC;
        _theViewControllerDelegate = viewControllerDelegate;
    }
    
    return self;
    
}

- (void) openView:(WorstKPIDataSource*) lastWorstKPIs {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Cell Dashboard" message:@"Select technology for the analysis" delegate:Nil cancelButtonTitle:@"Cancel" otherButtonTitles:Nil];
    
    NSMutableDictionary* mappingButton = [[NSMutableDictionary alloc] init ];
    
    NSInteger index;
    DCTechnologyId technoId = DCTechnologyUNKNOWN;
    
    cellDataSource* aroundMeDataSource = [self.delegate datasource];
    
    Boolean hasCells = FALSE;
    
    NSString *buttonString;
    NSUInteger cellCount = [aroundMeDataSource getFilteredCellCountForTechnoId:DCTechnologyLTE];
    if (cellCount > 0) {
        buttonString = [NSString stringWithFormat:@"%@ (%lu cells)",kTechnoLTE, (unsigned long)cellCount];
        index = [alert addButtonWithTitle:buttonString];
        technoId = DCTechnologyLTE;
        mappingButton[@(index)] = @(technoId);
        hasCells = TRUE;
    }
    cellCount = [aroundMeDataSource getFilteredCellCountForTechnoId:DCTechnologyWCDMA];
    if (cellCount > 0) {
        buttonString = [NSString stringWithFormat:@"%@ (%lu cells)",kTechnoWCDMA, (unsigned long)cellCount];
        index = [alert addButtonWithTitle:buttonString];
        technoId = DCTechnologyWCDMA;
        mappingButton[@(index)] = @(technoId);
        hasCells = TRUE;
    }
    cellCount = [aroundMeDataSource getFilteredCellCountForTechnoId:DCTechnologyGSM];
    if (cellCount > 0) {
        buttonString = [NSString stringWithFormat:@"%@ (%lu cells)",kTechnoGSM, (unsigned long)cellCount];
        index = [alert addButtonWithTitle:buttonString];
        technoId = DCTechnologyGSM;
        mappingButton[@(index)] = @(technoId);
        hasCells = TRUE;
    }
    
    if (lastWorstKPIs != Nil) {
        NSString* dateRequest = [DateUtility  getDate:lastWorstKPIs.requestDate option:withHHmm];
        switch (lastWorstKPIs.technology) {
            case DCTechnologyLTE: {
                buttonString = [NSString stringWithFormat:@"%@ from %@",kTechnoLTE, dateRequest];
                
                break;
            }
            case DCTechnologyWCDMA: {
                buttonString = [NSString stringWithFormat:@"%@ from %@",kTechnoWCDMA, dateRequest];
                break;
            }
            case DCTechnologyGSM: {
                buttonString = [NSString stringWithFormat:@"%@ from %@",kTechnoGSM, dateRequest];
                break;
            }
            default: {
                break;
            }
        }
        index = [alert addButtonWithTitle:buttonString];
        mappingButton[@(index)] = @(DCTechnologyLatestUsed);
    }
    
    // 2 because there're the "Cancel button" and the button for at least 1 techno
    if (alert.numberOfButtons > 2) {
        // Display the Alert View else compute directly worst cell for the only one techno available
        self.mappingAlertViewButton = mappingButton;
        
        if (alert != Nil) {
            alert.delegate = self;
            [alert show];        
        }
    } else {
        if (hasCells == TRUE) {
            [self.theViewControllerDelegate performSegueWithIdentifier:@"openCellsKPIs" sender:@(technoId)];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid data" message:@"Cannot compute on an empty cell zone" delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];                    
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    // If Cancel button is pressed, just do nothing!
    if (buttonIndex ==0) {
        return;
    }
    
    NSNumber* technoNumber = self.mappingAlertViewButton[@(buttonIndex)];
    DCTechnologyId technoId = [technoNumber shortValue];
    
    self.mappingAlertViewButton = Nil;
    
    [self.theViewControllerDelegate performSegueWithIdentifier:@"openCellsKPIs" sender:@(technoId)];
    
}


@end
