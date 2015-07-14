//
//  SearchEverywhereEntryPoint.m
//  iMonitoring
//
//  Created by sébastien brugalières on 24/11/2013.
//
//

#import "SearchEverywhereEntryPoint.h"
#import "LocateCellTableViewController.h"
#import "CellsOnCoverageViewController.h"
#import "AroundMeViewMgt.h"
#import "DataCenter.h"
#import "MapInformationViewController.h"
#import "NeighborsLocateViewController.h"
#import "AroundMeViewItf.h"

@interface SearchEverywhereEntryPoint ()

@end

@implementation SearchEverywhereEntryPoint

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setToolbarHidden:TRUE animated:FALSE];
    self.navigationController.hidesBarsOnTap = FALSE;

    id<AroundMeViewItf> theAroundMeImpl = [DataCenter sharedInstance].aroundMeItf;
    
    LocateCellTableViewController* searchCell = self.viewControllers[0];
    searchCell.delegate = theAroundMeImpl.viewMgt;

    CellsOnCoverageViewController* searchCellOnCoverage = self.viewControllers[2];
    searchCellOnCoverage.delegate = theAroundMeImpl;

    NeighborsLocateViewController* controller = self.viewControllers[3];
    if (theAroundMeImpl.currentMapMode == MapModeNeighbors) {
        [controller initiliazeWith:theAroundMeImpl.datasource.neighborsDataSource.neighborData delegate:theAroundMeImpl.viewMgt];
     }
 }

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.navigationController setToolbarHidden:TRUE animated:FALSE];
    self.navigationController.hidesBarsOnTap = FALSE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
