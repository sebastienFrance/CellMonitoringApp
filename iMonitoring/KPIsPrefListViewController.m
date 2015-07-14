//
//  KPIsPrefListViewController.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 13/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KPIsPrefListViewController.h"
#import "KPIPrefConfiguration.h"
#import "KPI.h"
#import "KPIDictionary.h"
#import "DataCenter.h"
#import "BasicTypes.h"
#import "KPIDictionaryManager.h"

@interface KPIsPrefListViewController ()

@end

@implementation KPIsPrefListViewController


#pragma mark - Initializations

- (void) initTechno:(DCTechnologyId) theTechno {
    KPIDictionaryManager* dataCenterInstance = [KPIDictionaryManager sharedInstance];

    _KPIDictionary = [dataCenterInstance.defaultKPIDictionary getKPIsPerDomain:theTechno];

    self.title = [BasicTypes getTechnoName:theTechno];
    
    NSArray* sectionsHeader = [_KPIDictionary allKeys];
    _sectionsHeader = [sectionsHeader sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sectionsHeader.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return _sectionsHeader[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSArray* sectionContent = _KPIDictionary[_sectionsHeader[section]];
    return sectionContent.count;
 }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"KPIsPrefConfigId";
    KPIPrefConfiguration *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == Nil) {
        cell = [[KPIPrefConfiguration alloc] init];
    }

     
    NSArray* sectionContent = _KPIDictionary[_sectionsHeader[indexPath.section]];
    KPI* theKPI = sectionContent[indexPath.row];
    [cell initWithKPI:theKPI];

    return cell;
}



@end
