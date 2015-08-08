//
//  iPadCellDetailsAndKPIsViewTableViewController.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 23/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "iPadCellDetailsAndKPIsViewTableViewController.h"
#import "iPadCellDetailsAndKPIsViewControllerView.h"
#import "iPadDashboardScopeViewCell.h"
#import "UserPreferences.h"

@interface iPadCellDetailsAndKPIsViewTableViewController ()

@property (nonatomic) iPadCellDetailsAndKPIsViewControllerView* delegate;

@end

@implementation iPadCellDetailsAndKPIsViewTableViewController

- (void) initialize:(iPadCellDetailsAndKPIsViewControllerView*) delegate {
    self.delegate = delegate;
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"iPadDashboardScopeCellId";
    iPadDashboardScopeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == Nil) {
        cell = [[iPadDashboardScopeViewCell alloc] init]; 
    }
    
    NSInteger defaultScope = [UserPreferences sharedInstance].CellDashboardDefaultViewScope;
    if (defaultScope == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;        
    }
    
    cell.theTitleName.text = [NSString stringWithFormat:@"%@", [MonitoringPeriodUtility getStringForMonitoringPeriod:indexPath.row]];
    cell.theShortComment.text =[NSString stringWithFormat:@"%@", [MonitoringPeriodUtility getStringForShortGranularityPeriodName:indexPath.row]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [UserPreferences sharedInstance].CellDashboardDefaultViewScope = indexPath.row;
    [self.delegate updateDashboardScope];
}

@end
