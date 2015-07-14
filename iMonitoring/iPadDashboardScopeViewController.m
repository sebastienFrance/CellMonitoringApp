//
//  iPadDashboardScopeViewController.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 09/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "iPadDashboardScopeViewController.h"
#import "iPadDashboardScopeViewCell.h"
#import "iPadDashboardViewController.h"
#import "DataCenter.h"
#import "UserPreferences.h"

@interface iPadDashboardScopeViewController () {
@private
    iPadDashboardViewController* _delegate;
}


@end

@implementation iPadDashboardScopeViewController


- (void) initialize:(iPadDashboardViewController*) delegate {
    _delegate = delegate;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"iPadDashboardScopeCellId";
    iPadDashboardScopeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == Nil) {
        cell = [[iPadDashboardScopeViewCell alloc] init]; 
    }
    
    NSInteger defaultScope = [UserPreferences sharedInstance].ZoneDashboardDefaultScope;
    if (defaultScope == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    MonitoringPeriodUtility* dc = [MonitoringPeriodUtility sharedInstance];
    
    
    switch (indexPath.row) {
        case DSScopeLastGP: {
            cell.theTitleName.text = [NSString stringWithFormat:@"Worst cell on %@", [MonitoringPeriodUtility getStringForGranularityPeriodName:dc.monitoringPeriod]];
            cell.theShortComment.text = @"Display Worst Cells KPI on last GP";

            break;
        }
        case DSScopeLastPeriod: {
            cell.theTitleName.text = [NSString stringWithFormat:@"Worst cell for %@",[MonitoringPeriodUtility getStringForGranularityPeriodDuration:dc.monitoringPeriod]];
            cell.theShortComment.text = @"Display Worst Cells KPI over last period";
            break;
        }
        case DSScopeAverageZoneAndPeriod: {
            cell.theTitleName.text = [NSString stringWithFormat:@"KPI average for %@",[MonitoringPeriodUtility getStringForGranularityPeriodDuration:dc.monitoringPeriod]];
            cell.theShortComment.text = @"Display KPIs average on zone over last period";
            break;
        }
        default: {
            return Nil;
        }
    }
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [UserPreferences sharedInstance].ZoneDashboardDefaultScope = indexPath.row;
    [_delegate updateDashboardScope];
}

@end
