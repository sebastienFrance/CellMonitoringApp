//
//  KPIsViewController.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 20/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KPIsViewController.h"
#import "MBProgressHUD.h"
#import "CellWithKPIValues.h"
#import "DataCenter.h"
#import "KPIDictionary.h"
#import "KPI.h"
#import "WorstKPIsCell.h"
#import "DetailsWorstKPIsViewController.h"
#import "CellMonitoring.h"
#import "MailOverviewWorstCellsKPIs.h"

@interface KPIsViewController ()

@property(nonatomic) NSIndexPath* selectedIndexPath;
@property(nonatomic, weak) WorstKPIDataSource* dataSource;

@end

@implementation KPIsViewController
@synthesize theTable = _theTable;



- (void)sendTheMail {
    // build the mail body that contains cell info and values for all KPIs
    MailOverviewWorstCellsKPIs* mailbody = [[MailOverviewWorstCellsKPIs alloc] init:_dataSource];
    
    [mailbody presentActivityViewFrom:self];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder])) {
    }
    return self;
}



- (void) initialize:(WorstKPIDataSource*) latestWorstKPIs {
    _dataSource = latestWorstKPIs;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _theTable.delegate = self;
    _theTable.dataSource = self;
    
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
    return @"Worst Cells";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.KPIs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellWorstKPIId";
    WorstKPIsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == Nil) {
        cell = [[WorstKPIsCell alloc] init]; 
    }
    
    NSEnumerator *enumerator = [_dataSource.KPIs objectEnumerator];
    
    
    NSArray* KPIsPerCell;
    
    for (int i = 0 ; i <= indexPath.row; i++) {
        KPIsPerCell = [enumerator nextObject];
    }
    
    CellWithKPIValues* KPIsforACell = KPIsPerCell[0];

    // Do the same research for Worst Average 
    enumerator = [_dataSource.worstAverageKPIs objectEnumerator];
    
    for (int i = 0 ; i <= indexPath.row; i++) {
        KPIsPerCell = [enumerator nextObject];
    }
    
    CellWithKPIValues* KPIsforACellAverage = KPIsPerCell[0];

    [cell initializeWith:KPIsforACell cellAverage:KPIsforACellAverage];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"openDetailsWorstCells" sender:self];
}


// 
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"openDetailsWorstCells"]) {
        DetailsWorstKPIsViewController* vc = segue.destinationViewController;
        
        NSIndexPath* selectedIndexPath = [_theTable indexPathForSelectedRow];
        
        [vc initialize:_dataSource initialIndex:selectedIndexPath.row isAverage:FALSE];
    }
}



@end
