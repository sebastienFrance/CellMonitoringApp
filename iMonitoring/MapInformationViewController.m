//
//  MapInformationViewController.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 23/08/2014.
//
//

#import "MapInformationViewController.h"
#import "MapInfoDatasource.h"
#import "MapInfoTechnoDatasource.h"
#import "Utility.h"
#import "MBProgressHUD.h"
#import "MapInformationTechoInfoCell.h"
#import "MapInformationLTEANRInfoCell.h"
#import "MapInformationGeneralInfoCell.h"

@interface MapInformationViewController()

@property(nonatomic) MapInfoDatasource* datasource;
@property(nonatomic) Boolean dataSourceReady;

@property (weak, nonatomic) IBOutlet UITableView *theTableView;

@end

@implementation MapInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationController setToolbarHidden:TRUE animated:FALSE];
    self.navigationController.hidesBarsOnTap = FALSE;

    self.theTableView.dataSource = self;
    self.theTableView.delegate = self;

    self.theTableView.estimatedRowHeight = 62.0;
    self.theTableView.rowHeight = UITableViewAutomaticDimension;

    self.datasource = [[MapInfoDatasource alloc] init];
    [self.datasource loadMapInfoFor:self.listOfCells delegate:self];

    if ((self.listOfCells == Nil) || (self.listOfCells.count ==0)) {
        self.dataSourceReady = TRUE;
        [self.theTableView reloadData];
    } else {
        self.dataSourceReady = FALSE;

        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Loading map summary";
    }
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.navigationController setToolbarHidden:TRUE animated:FALSE];
    self.navigationController.hidesBarsOnTap = FALSE;
}

- (void) mapInfoLoaded:(NSError*) theError {
    [MBProgressHUD hideAllHUDsForView:self.view animated:FALSE];
    if (theError != Nil) {
        UIAlertController* alert = [Utility getSimpleAlertView:@"Communication error"
                                                       message:@"Cannot collect data from server."
                                                   actionTitle:@"OK"];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    } else {
        self.dataSourceReady = TRUE;
        [self.theTableView reloadData];
    }
}


- (IBAction)closeButtonPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:TRUE completion:Nil];
}

#pragma mark - Table view data source



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.dataSourceReady == FALSE) {
        return 0;
    } else {
        return 4;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Map summary";
    } else {
        DCTechnologyId techno = [MapInformationViewController technologyIdFromSectionIndex:section];
        return [BasicTypes getTechnoName:techno];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.dataSourceReady == FALSE) {
        return 0;
    }

    if (section == 0) {
        return 1;
    }

    DCTechnologyId techno = [MapInformationViewController technologyIdFromSectionIndex:section];
    switch (techno) {
        case DCTechnologyLTE: {
            return 2;
        }
        case DCTechnologyGSM:
        case DCTechnologyWCDMA: {
            return 1;
        }
        default: {
            return 0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *technoCellInfo = @"TechnoInfoCellId";
    static NSString *LTEANRCellInfo = @"LTEANRInfoCellId";
    static NSString *MapGeneralInfo = @"MapGeneralInfoCellId";

    if (indexPath.section == 0) {
        MapInformationGeneralInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:MapGeneralInfo];
        if (cell == Nil) {
            cell = [[MapInformationGeneralInfoCell alloc] init];
        }

        [cell initializeWith:self.datasource];
        return cell;
    }

    DCTechnologyId techno = [MapInformationViewController technologyIdFromSectionIndex:indexPath.section];
    if ((techno == DCTechnologyLTE) && (indexPath.row == 1)) {
        MapInformationLTEANRInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:LTEANRCellInfo];
        if (cell == Nil) {
            cell = [[MapInformationLTEANRInfoCell alloc] init];
        }

        [cell initializeWith:self.datasource];
        return cell;
    }

    if ((indexPath.section == 1) || (indexPath.section == 2) || (indexPath.section == 3)) {
        MapInformationTechoInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:technoCellInfo];
        if (cell == Nil) {
            cell = [[MapInformationTechoInfoCell alloc] init];
        }


        MapInfoTechnoDatasource* theDatasource = [self.datasource getTechnoInfo:techno];
        if (theDatasource == Nil) {
            NSLog(@"%s Can't find the datasource",__PRETTY_FUNCTION__);
            return Nil;
        } else {
            [cell initializeWith:theDatasource];
            return cell;
        }
    }
   return Nil;
}

+ (DCTechnologyId) technologyIdFromSectionIndex:(NSInteger) section {
    switch (section) {
        case 1: {
            return DCTechnologyLTE;
        }
        case 2: {
            return DCTechnologyWCDMA;
        }
        case 3: {
            return DCTechnologyGSM;
        }
        default: {
            return DCTechnologyUNKNOWN;
        }
    }

}

@end
