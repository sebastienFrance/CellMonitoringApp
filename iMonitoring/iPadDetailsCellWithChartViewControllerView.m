//
//  iPadDetailsCellKPIViewControllerView.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 18/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "iPadDetailsCellWithChartViewControllerView.h"
#import "KPI.h"
#import "CellDetailsCellKPIViewCell.h"
#import "CellDetailsPeriodCellKPIViewCell.h"
#import "CellMonitoring.h"
#import "DataCenter.h"
#import "DateUtility.h"
#import "KPIBarChart.h"
#import "KPIDataSource.h"
#import "CellDetailsPeriodCellKPIViewCell.h"
#import "KPIDictionary.h"
#import "UserPreferences.h"
#import "MailCellDetailedKPI.h"

@interface iPadDetailsCellWithChartViewControllerView ()

@property(nonatomic) UIViewController* mailPopover;

@end

@implementation iPadDetailsCellWithChartViewControllerView

// Differences
- (IBAction)closeButtonPushed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:TRUE completion:Nil];
}

- (float) getRowHeightForDetailedView {
    return 70.0;
}

- (float) getRowHeightForSimpleView {
    return 46.0;
}

- (void) opendMail:(UIBarButtonItem *)sender mail:(MailAbstract*) theMail{
    
    if (self.mailPopover != Nil) {
        [self.mailPopover dismissViewControllerAnimated:TRUE completion:Nil];
        self.mailPopover = Nil;
    }

    self.mailPopover = [theMail getActivityViewController];
    [self presentViewControllerInPopover:self.mailPopover item:sender];
}

-(void) presentViewControllerInPopover:(UIViewController*) contentController item:(UIBarButtonItem *)theItem {

    contentController.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController* popPC = contentController.popoverPresentationController;
    popPC.barButtonItem = theItem;
    popPC.permittedArrowDirections = UIPopoverArrowDirectionAny;
    [self presentViewController:contentController animated:TRUE completion:Nil];
}


-(void) customizeChartDisplayProperties:(KPIBarChart*) theChart {
    theChart.yTitleDisplacement = -5.0f;
    theChart.titleFontSize = 14.0f;
    theChart.titleWithKPIDomain = TRUE;
}

@end
