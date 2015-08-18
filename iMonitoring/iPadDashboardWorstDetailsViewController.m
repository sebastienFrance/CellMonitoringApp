//
//  iPadDashboardWorstDetailsViewController.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 09/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "iPadDashboardWorstDetailsViewController.h"
#import "KPI.h"
#import "CellWithKPIValues.h"
#import "WorstKPIItf.h"
#import "AroundMeViewMgt.h"
#import "iPadAroundMeImpl.h"
#import "iPadImonitoringViewController.h"
#import "UserPreferences.h"
#import "CellKPIsDataSource.h"
#import "MBProgressHUD.h"
#import "CellMonitoring.h"
#import "iPadCellDetailsAndKPIsViewControllerView.h"
#import "MailAbstract.h"


@interface iPadDashboardWorstDetailsViewController()

@property (nonatomic) UIViewController* theMailPopover;

@end

@implementation iPadDashboardWorstDetailsViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
// All is done with the buttons
}

- (void) setGraphicPropertiesBasedOnOrientation:(UIInterfaceOrientation) orientation chart:(WorstKPIChart*) theChart {
    theChart.yTitleDisplacement = -10.0f;
    theChart.titleFontSize = 14.0f;
    
    theChart.pieRadius = 125.0f;
    
    theChart.legendFontSize = 16.0f;
    theChart.legendXDisplacement = 180.0f;
    theChart.legendYDisplacement = 80.0f;
}


- (IBAction)KPIsButtonPressed:(UIButton *)sender {
    NSArray* KPIValuesPerCell = [_delegate getKPIValues];
    CellWithKPIValues* selectedCell = KPIValuesPerCell[sender.tag];
    
    CellMonitoring* theCell = [_delegate getCellbyName:selectedCell.cellName];
    
    [self dismissViewControllerAnimated:TRUE completion:^{
        [self.parentDashboard displayCellKPIs:theCell];
    }];
    
}
- (IBAction)MapButtonPressed:(UIButton *)sender {
    NSArray* KPIValuesPerCell = [_delegate getKPIValues];
    CellWithKPIValues* selectedCell = KPIValuesPerCell[sender.tag];
  
    
    CellMonitoring* theCellonMap = [_delegate getCellbyName:selectedCell.cellName];
   
    [self dismissViewControllerAnimated:FALSE completion:^{
        [self.parentDashboard displayCellOnMap:theCellonMap];
    }];
}




@end
