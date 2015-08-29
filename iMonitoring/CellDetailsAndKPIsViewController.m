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

@interface CellDetailsAndKPIsViewController ()

@property(nonatomic) CellKPIsDataSource* datasource;

@end

@implementation CellDetailsAndKPIsViewController


#pragma mark - Send mail
- (IBAction)sendMail:(UIBarButtonItem *)sender {
    KPIDictionary* dictionary = [KPIDictionaryManager sharedInstance].defaultKPIDictionary;
    MailCellKPI* mailbody = [[MailCellKPI alloc] init:self.theCell
                                           datasource:self.datasource
                                        KPIDictionary:dictionary
                                     monitoringPeriod:[[MonitoringPeriodUtility sharedInstance] monitoringPeriod]
                                               alarms:self.alarmDatasource.alarmsOrderedByDate];
    
    [mailbody presentActivityViewFrom:self];
 }



#pragma mark - CellKPIsLoadingItf
- (void) dataIsLoaded {
    [self.theTable reloadData];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void) dataLoadingFailure {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertController* alert = [Utility getSimpleAlertView:@"Communication Error"
                                                   message:@"Cannot get KPIs from the server."
                                               actionTitle:@"OK"];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) timezoneIsLoaded:(NSString*) theTimeZone {
    [self displayCellTimezone:theTimeZone];
}


#pragma mark - Initialization

- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder])) {
        _datasource = [[CellKPIsDataSource alloc] init:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initAndLoadCellDetails];
}

-(void) initAndLoadCellDetails {
    CellKPIsDataSource* cache = [self.theCell getCache];
    if (cache != Nil) {
        self.datasource = cache;
        [self.theTable reloadData];
        [self displayCellTimezone:self.theCell.timezone];
    } else {
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Loading KPIs";
        
        [self.datasource loadData:self.theCell];
    }
}



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

+(KPI*) getKPI:(DCTechnologyId) cellTechnology indexPath:(NSIndexPath*) indexPath {
    NSIndexPath* realIndexPath = [NSIndexPath indexPathForRow:indexPath.row
                                                    inSection:[CellDetailsAndKPIsViewController getKPISectionIndex:indexPath.section]];

    return [[KPIDictionaryManager sharedInstance] getKPI:cellTechnology indexPath:realIndexPath];
}

+(NSInteger) getKPISectionIndex:(NSUInteger) section {
    return (section - 2);
}


-(UITableViewCell *) buildCellForKPIsSection:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdKPI = @"CellKPIId";

    DisplayKPICell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdKPI forIndexPath:indexPath];

    KPI* cellKPI = [CellDetailsAndKPIsViewController getKPI:self.theCell.cellTechnology indexPath:indexPath];
    cell.kpiName.text = cellKPI.name;
    cell.kpiDescription.text = cellKPI.shortDescription;
    
    MonitoringPeriodUtility* theMP = [MonitoringPeriodUtility sharedInstance];
    NSDictionary* KPIs = [self.datasource getKPIsForMonitoringPeriod:[theMP monitoringPeriod]];
    
    if (KPIs != Nil) {
        NSArray* kpiValues = KPIs[cellKPI.internalName];
        
        if (kpiValues != Nil) {
            NSString* lastValue = [cellKPI getDisplayableValueFromNumber:[kpiValues lastObject]];
            NSString* beforeLastValue = Nil;
            if (kpiValues.count > 1) {
                beforeLastValue = [cellKPI getDisplayableValueFromNumber:kpiValues[(kpiValues.count - 2)]];
            }
            cell.kpiValue.text = [KPI displayCurrentAndPreviousValue:lastValue
                                                            preValue:beforeLastValue
                                                    monitoringPeriod:theMP.monitoringPeriod
                                                         requestDate:self.datasource.requestDate];

            if (cellKPI.hasDirection) {
                cell.severity.hidden = FALSE;
                cell.severity.backgroundColor = [cellKPI getColorValueFromNumber:[kpiValues lastObject]];
            } else {
                cell.severity.hidden = TRUE;
            }
            
        } else {
            cell.kpiValue.text = @"No value";
            cell.severity.hidden = TRUE;
        }
    } else {
        cell.kpiValue.text = @"KPI is loading...";
        cell.severity.hidden = TRUE;
    }
    
    return cell;
  
}


#pragma mark - Segue
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"openCellKPIDetailsId"]) {
        DetailsCellWithChartViewController* modal = segue.destinationViewController;
        
        NSIndexPath* selectedIndexInFullTable = [self.theTable indexPathForSelectedRow];
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:selectedIndexInFullTable.row inSection:(selectedIndexInFullTable.section - 2)];
        
        [modal initialize:self.datasource initialMonitoringPeriod:[[MonitoringPeriodUtility sharedInstance] monitoringPeriod] initialIndex:indexPath];
    } else if ([segue.identifier isEqualToString:@"openMarkCell"]) {
        MarkViewController* modal = segue.destinationViewController;
        modal.delegate = self;
        modal.theCell = self.theCell;
    } else {
        [super prepareForSegue:segue sender:sender];
    }
}




@end
