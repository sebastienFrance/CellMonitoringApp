//
//  CellDetailsAndKPIsViewController.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 18/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CellDetailsAndKPIsViewController.h"
#import "CellAddressDetails.h"
#import "CellMonitoring.h"
#import "DataCenter.h"
#import "KPI.h"
#import "KPIDictionary.h"
#import "DisplayKPICell.h"
#import "DetailsCellWithChartViewController.h"
#import "MBProgressHUD.h"
#import "AroundMeViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "CellKPIsDataSource.h"
#import "MailCellKPI.h"
#import "CellBookmark+MarkedCell.h"
#import "MailActivity.h"
#import "KPIDictionaryManager.h"


@implementation CellDetailsAndKPIsViewController

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSDictionary<NSString*,NSArray<KPI*>*> *KPIDictionary = [[KPIDictionaryManager sharedInstance].defaultKPIDictionary getKPIsPerDomain:self.theCell.cellTechnology];
    return (KPIDictionary.count + 2);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // First section is Cell Description
    if (section == SECTION_ADDRESS) {
        return 1;
    } if (section == SECTION_GENERAL) {
        return 3;
    } else  if (section >= SECTION_KPIS) {
        return [self numberOfRowsForKPIsInSection:section];
    } else {
        return 0;
    }
}

-(NSInteger) numberOfRowsForKPIsInSection:(NSInteger) section {
    return [CellDetailsAndKPIsViewController getKPIsFromSection:section technology:self.theCell.cellTechnology].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == SECTION_ADDRESS || section == SECTION_GENERAL) {
        return [super tableView:tableView titleForHeaderInSection:section];
    } else {
        return [CellDetailsAndKPIsViewController titleForKPIsInSection:section tehcnology:self.theCell.cellTechnology];
    }
}

// Specific
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SECTION_ADDRESS: {
            return 180.0;
        }
        case SECTION_GENERAL: {
            if (indexPath.row == SECTION_GENERAL_ROW_NEIGHBORS_RELATIONS) {
                return 125.0;
            } else if (indexPath.row == SECTION_GENERAL_ROW_ALARMS) {
                return 103.0;
            } else {
                return 58.0;
            }
        }
        default: {
            return 97.0;
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_GENERAL || indexPath.section == SECTION_ADDRESS) {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    } else {
        return [self buildCellForKPIsSection:tableView cellForRowAtIndexPath:indexPath];
    }
}

+(NSString*) titleForKPIsInSection:(NSInteger) section tehcnology:(DCTechnologyId) cellTechnology {
    NSArray<NSString*> *sectionsHeader = [[KPIDictionaryManager sharedInstance].defaultKPIDictionary getSectionsHeader:cellTechnology];
    return sectionsHeader[[CellDetailsAndKPIsViewController getKPISectionIndex:section]];
}

+(NSArray<KPI*>*) getKPIsFromSection:(NSInteger) section technology:(DCTechnologyId) cellTechnology {
    return [[KPIDictionaryManager sharedInstance] getKPIsFromSection:[CellDetailsAndKPIsViewController getKPISectionIndex:section]
                                                          technology:cellTechnology];
}


+(NSInteger) getKPISectionIndex:(NSUInteger) section {
    return (section - 2);
}



@end
