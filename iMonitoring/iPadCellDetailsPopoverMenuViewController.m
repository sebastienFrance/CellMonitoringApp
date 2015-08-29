//
//  iPadCellDetailsPopoverMenuViewController.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 30/12/2014.
//
//

#import "iPadCellDetailsPopoverMenuViewController.h"
#import "CellAddressDetails.h"
#import "CellMonitoring.h"

@interface iPadCellDetailsPopoverMenuViewController ()

@property (nonatomic) CellTimezoneDataSource* timezoneDatasource;

@end

@implementation iPadCellDetailsPopoverMenuViewController


#pragma mark - CellTimezoneDataSourceDelegate delegate
- (void) cellTimezoneResponse:(CellMonitoring*) cell error:(NSError*) theError {
    [self displayCellTimezone:cell.timezone];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.timezoneDatasource = [[CellTimezoneDataSource alloc] initWithDelegate:self cell:self.theCell];
    [self.timezoneDatasource loadTimeZone];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_ADDRESS: {
            return 1;
            break;
        }
        case SECTION_GENERAL: {
            if (self.isBasicCellInfos == FALSE) {
                return 4;
            } else {
                return 3;
            }
            break;
        }

        default:{
            return 0;
            break;
        }
    }
}

// Specific
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 180.0;
    } else {
        switch (indexPath.row) {
            case SECTION_GENERAL_ROW_PARAMETERS: {
                return 65.0;
            }
            case SECTION_GENERAL_ROW_ALARMS: {
                return 110.0;
            }
            case SECTION_GENERAL_ROW_ACTIONS_KPIS: {
                return 65.0;
            }
            case SECTION_GENERAL_ROW_NEIGHBORS_RELATIONS: {
                return 110;
            }
            default:
                return 65.0;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_GENERAL) {
        if (indexPath.row == SECTION_GENERAL_ROW_ACTIONS_KPIS) {
            iPadAroundMeImpl* mainEntry = (iPadAroundMeImpl*) self.delegate;
            [mainEntry openDetailedKPIsView:self.theCell];
        } else {
            [super tableView:tableView didSelectRowAtIndexPath:indexPath];
        }
    }
}

@end
