//
//  iPadSearchMenuViewController.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 07/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "iPadSearchMenuViewController.h"
#import "CellsOnCoverageViewController.h"
#import "CellsOnCoverageViewController.h"
#import "DataCenter.h"
#import "AroundMeViewItf.h"
#import "AroundMeViewMgt.h"
#import "NeighborsLocateViewController.h"
#import "cellDataSource.h"

@interface iPadSearchMenuViewController ()

@end

@implementation iPadSearchMenuViewController

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



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id<AroundMeViewItf> aroundMe = [DataCenter sharedInstance].aroundMeItf;
    if ([segue.identifier isEqualToString:@"openCellsInTable"]) {
        CellsOnCoverageViewController* controller = segue.destinationViewController;
        
        controller.delegate = aroundMe;
    } else if ([segue.identifier isEqualToString:@"openSearchCell"]) {
        LocateCellTableViewController* controller = segue.destinationViewController;
        
        controller.delegate = aroundMe.viewMgt;
    } else if ([segue.identifier isEqualToString:@"iPadOpenNeighborsList"]) {
        NeighborsLocateViewController* controller = segue.destinationViewController;
       
#warning SEB: why this useless check?
        if (aroundMe.currentMapMode == MapModeNeighbors) {
            [controller initiliazeWith:aroundMe.datasource.neighborsDataSource.neighborData delegate:aroundMe.viewMgt];
         }
    }
}

@end
