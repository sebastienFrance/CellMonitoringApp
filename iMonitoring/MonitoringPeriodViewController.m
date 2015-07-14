//
//  MonitoringPeriodViewController.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 02/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MonitoringPeriodViewController.h"
#import "DataCenter.h"
#import "UserPreferencesViewController.h"
#import "KPIDictionary.h"
#import "KPIDictionaryManager.h"


@interface MonitoringPeriodViewController ()

@end

@implementation MonitoringPeriodViewController
@synthesize delegate;
@synthesize isKPIDictionary;

#pragma mark - Initializations

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

- (void)viewWillDisappear:(BOOL)animated {
    if (isKPIDictionary == FALSE) {
        [delegate updateDefaultMonitoringPeriod];
    } else {
        [delegate updateDefaultKPIDictionary];        
    }
    [super viewWillDisappear:animated];
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
    if (isKPIDictionary == FALSE) {
        return 5;
    } else {
        NSArray* dicos = [[KPIDictionaryManager sharedInstance] KPIDictionaries];
        return dicos.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellMonitoringPeriod";
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == Nil) {
        cell = [[UITableViewCell alloc] init];
    }

    MonitoringPeriodUtility* dc = [MonitoringPeriodUtility sharedInstance];
    
    if (isKPIDictionary == FALSE) {

        cell.textLabel.text =  [MonitoringPeriodUtility getStringForMonitoringPeriod:indexPath.row];
        if (indexPath.row == dc.monitoringPeriod) { 
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            _selectedCell = cell;
        }
    } else {
        KPIDictionary* dico = [[KPIDictionaryManager sharedInstance] KPIDictionaries][indexPath.row];
        cell.textLabel.text =  dico.name;
        if ([dico.name isEqualToString:[KPIDictionaryManager sharedInstance].defaultKPIDictionaryName]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            _selectedCell = cell;
        }
    }
   return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MonitoringPeriodUtility* dc = [MonitoringPeriodUtility sharedInstance];
    
    Boolean selectedhasChanged = FALSE;
    
    if (isKPIDictionary == FALSE) {            
        if (indexPath.row != (dc.monitoringPeriod)) {
            dc.monitoringPeriod = indexPath.row;
            selectedhasChanged = TRUE;
        }
    } else {
        KPIDictionary* dico = [[KPIDictionaryManager sharedInstance] KPIDictionaries][indexPath.row];
        if ([dico.name isEqualToString:[KPIDictionaryManager sharedInstance].defaultKPIDictionaryName] == FALSE) {
            [KPIDictionaryManager sharedInstance].defaultKPIDictionary = dico;
            selectedhasChanged = TRUE;
        }
    }
    
    if (selectedhasChanged) {
        _selectedCell.accessoryType = UITableViewCellAccessoryNone;
        
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        _selectedCell = cell;
    }
}

@end
