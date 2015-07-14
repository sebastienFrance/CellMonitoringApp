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

@interface DashboardViewSelection ()

@property (nonatomic) NSDictionary* mappingAlertViewButton;
@property (nonatomic) UIActionSheet* alert;

@end

@implementation DashboardViewSelection


- (void) dismiss {
    [self.alert dismissWithClickedButtonIndex:-1 animated:TRUE];
}

- (void) dealloc {
    self.alert = Nil;
}

- (void) openView:(UIBarButtonItem*) sourceButton{
    
    // cancelButtonTitle must be set to nil on the iPad because it's presented in a Popover
    self.alert = [[UIActionSheet alloc] initWithTitle:@"Dashboard" delegate:self cancelButtonTitle:Nil destructiveButtonTitle:Nil otherButtonTitles:Nil];
    
    NSMutableDictionary* mappingButton = [[NSMutableDictionary alloc] init ];
    
    NSInteger index;
    DCTechnologyId technoId = DCTechnologyUNKNOWN;
    
    cellDataSource* aroundMeDataSource = [DataCenter sharedInstance].aroundMeItf.datasource;
    
    Boolean hasCells = FALSE;
    
    NSString *buttonString;
    NSUInteger cellCount = [aroundMeDataSource getFilteredCellCountForTechnoId:DCTechnologyLTE];
    if (cellCount > 0) {
        buttonString = [NSString stringWithFormat:@"%@ (%lu cells)",kTechnoLTE, (unsigned long)cellCount];
        index = [self.alert addButtonWithTitle:buttonString];
        technoId = DCTechnologyLTE;
        mappingButton[@(index)] = @(technoId);
        hasCells = TRUE;
    }
    cellCount = [aroundMeDataSource getFilteredCellCountForTechnoId:DCTechnologyWCDMA];
    if (cellCount > 0) {
        buttonString = [NSString stringWithFormat:@"%@ (%lu cells)",kTechnoWCDMA, (unsigned long)cellCount];
        index = [self.alert addButtonWithTitle:buttonString];
        technoId = DCTechnologyWCDMA;
        mappingButton[@(index)] = @(technoId);
        hasCells = TRUE;
    }
    cellCount = [aroundMeDataSource getFilteredCellCountForTechnoId:DCTechnologyGSM];
    if (cellCount > 0) {
        buttonString = [NSString stringWithFormat:@"%@ (%lu cells)",kTechnoGSM, (unsigned long)cellCount];
        index = [self.alert addButtonWithTitle:buttonString];
        technoId = DCTechnologyGSM;
        mappingButton[@(index)] = @(technoId);
        hasCells = TRUE;
    }
    WorstKPIDataSource* lastWorstKPIs = [DataCenter sharedInstance].aroundMeItf.lastWorstKPIs;
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
        index = [self.alert addButtonWithTitle:buttonString];
        mappingButton[@(index)] = @(DCTechnologyLatestUsed);
    }
    
    // Warning: compare with 1 because on iPad there is no Cancel button for it
    if (self.alert.numberOfButtons > 1) {
        // Display the Alert View else compute directly worst cell for the only one techno available
        self.mappingAlertViewButton = mappingButton;
        
        if (self.alert != Nil) {
            self.alert.delegate = self;
            
            [self.alert showFromBarButtonItem:sourceButton animated:TRUE];
        }
    } else {
        iPadAroundMeImpl* aroundMe = (iPadAroundMeImpl*) [DataCenter sharedInstance].aroundMeItf;
        if (hasCells == TRUE) {
            [aroundMe cancelDashboardView];
            [aroundMe openDashboardView:technoId];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid data" message:@"Cannot compute on an empty cell zone" delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];                    
            [aroundMe cancelDashboardView];
        }
    }
}

#pragma mark - UIActionSheetDelegate protocol

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    iPadAroundMeImpl* aroundMe = (iPadAroundMeImpl*) [DataCenter sharedInstance].aroundMeItf;
    [aroundMe cancelDashboardView];
}

// Implement UIActionSheetDelegate Protocol
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == -1) {
        return;
    }
    
    
    NSNumber* technoNumber = self.mappingAlertViewButton[@(buttonIndex)];
    DCTechnologyId technoId = [technoNumber shortValue];
    
    self.mappingAlertViewButton = Nil;
    
   iPadAroundMeImpl* aroundMe = (iPadAroundMeImpl*) [DataCenter sharedInstance].aroundMeItf;
    [aroundMe openDashboardView:technoId];
    
}

@end
