//
//  ZoneKPIsAverageViewController.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 21/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ZoneKPIsAverageViewController.h"
#import "WorstKPIDataSource.h"
#import "CellWithKPIValues.h"
#import "KPI.h"
#import "ZoneKPIsAverageViewCell.h"
#import "ZoneKPI.h"
#import "ZoneAverageDetailsViewController.h"
#import "ZoneKPIsAverageMail.h"

@interface ZoneKPIsAverageViewController ()

@property(nonatomic) NSIndexPath* selectedIndexPath;
@property(nonatomic) WorstKPIDataSource* dataSource;

@end

@implementation ZoneKPIsAverageViewController

@synthesize theTable = _theTable;

#pragma mark - Manage buttons

- (void)sendTheMail {
    // build the mail body that contains cell info and values for all KPIs
    ZoneKPIsAverageMail* mailbody = [[ZoneKPIsAverageMail alloc] init:_dataSource];
    
    [mailbody presentActivityViewFrom:self];
}


#pragma mark - Initializations 
- (void) initialize:(WorstKPIDataSource*) latestWorstKPIs {
    _dataSource = latestWorstKPIs;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _theTable.delegate = self;
    _theTable.dataSource = self;
    
    self.title = @"Zone KPIs";
    
    self.navigationItem.rightBarButtonItem.enabled = TRUE;
}

- (void) refreshView {
    [_theTable reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Zone Average";
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.zoneKPIs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ZoneAverageKPIId";
    ZoneKPIsAverageViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == Nil) {
        cell = [[ZoneKPIsAverageViewCell alloc] init]; 
    }
    
    NSEnumerator *enumerator = [_dataSource.zoneKPIs objectEnumerator];
    
    ZoneKPI* currentZoneKPI;
    
    for (int i = 0 ; i <= indexPath.row; i++) {
        currentZoneKPI = [enumerator nextObject];
    }
    
    [cell initializeWith:currentZoneKPI];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedIndexPath = indexPath;
    [self performSegueWithIdentifier:@"openZoneAverageDetailsId" sender:self];
}


// 
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"openZoneAverageDetailsId"]) {
        ZoneAverageDetailsViewController* vc = segue.destinationViewController;
        [vc initialize:_dataSource initialIndex:_selectedIndexPath.row];
    }
}


@end
