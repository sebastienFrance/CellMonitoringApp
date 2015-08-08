//
//  CellDetailsInfoBasicViewController.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 03/01/2015.
//
//

#import "CellDetailsInfoBasicViewController.h"
#import "CellAlarmDatasource.h"
#import "CellParametersDataSource.h"
#import "iPadDashboardScopeViewNRCell.h"
#import <UIKit/UIKit.h>
#import "CellProperties.h"
#import "CellAlarmsOverview.h"
#import "CellAddressDetails.h"
#import "CellParametersValueViewController.h"
#import "CellAlarmsViewController.h"
#import "HistoricalNRsOverviewViewController.h"
#import "MBProgressHUD.h"
#import "Utility.h"
#import "CellImageListViewController.h"
#import "UserPreferences.h"

@interface CellDetailsInfoBasicViewController()


@property(nonatomic) Boolean isCellParametersLoading;
@property(nonatomic) Boolean isCellAlarmsLoading;

@property(nonatomic) CellAlarmDatasource* alarmDatasource;
@property(nonatomic) CellParametersDataSource* parameterDatasource;


@property (weak, nonatomic) IBOutlet UITableView *theTable;


@property (nonatomic) CellMonitoring* theCell;
@property (nonatomic,weak) id<AroundMeViewItf> delegate;

@property(nonatomic) Boolean isBasicCellInfos;

// Images properties
@property(nonatomic) UIImage* defaultCellImage;

@property(nonatomic) Boolean hasImage;


@end

@implementation CellDetailsInfoBasicViewController

#pragma mark - Navigate to Direction

- (IBAction)goToMapApp:(UIButton *)sender {
    
    [self.theCell showDirection];
}

#pragma mark - Camera Mgt
- (IBAction)cameraButtonPressed:(UIButton *)sender {
   UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == TRUE) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    
    [self presentViewController:imagePicker animated:YES completion:Nil];
}
- (IBAction)TapGetsureOnImage:(UITapGestureRecognizer *)sender {
    if (self.hasImage == TRUE) {
        [self performSegueWithIdentifier:@"pushImageSiteList" sender:Nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate

// Extract the original image from the ImagePicker and store it.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage* image = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"uploading Image";
    
    [RequestUtilities sendImageForSitde:self.theCell.siteId
                                  image:image
                                quality:[UserPreferences sharedInstance].imageUploadQuality
                               delegate:self
                               clientId:@"Send Photos"];
    
    [self  dismissViewControllerAnimated:YES completion:Nil];
}


// Close the ImagePicker and release it
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self  dismissViewControllerAnimated:YES completion:Nil];
}

#pragma mark - CellParametersDataSourceDelegate
-(void) cellParametersWithResponse:(CellMonitoring*) cell error:(NSError*) theError {
    self.isCellParametersLoading = FALSE;
    if (theError == Nil) {
        [self.theTable reloadData];
    } else {
        NSLog(@"Error when loading cell parameters");
    }
}

#pragma  mark - AlarmListener protocol

- (void) alarmLoadingFailure {
    self.isCellAlarmsLoading = FALSE;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Communication failure" message:@"Cell alarms cannot be loaded" delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alert show];
    self.isCellAlarmsLoading = FALSE;
}
- (void) alarmLoaded {
    self.isCellAlarmsLoading = FALSE;
    [self.theTable reloadData];
}

#pragma mark - HTMLDataResponse
- (void) dataReady:(id) theData clientId:(NSString*) theClientId {
    [MBProgressHUD hideAllHUDsForView:self.view animated:TRUE];
    
    if ([theClientId isEqualToString:@"Send Photos"]) {
        [RequestUtilities getSiteImageList:self.theCell.siteId delegate:self clientId:@"getImageList"];
    } else if ([theClientId isEqualToString:@"getDefaultImage"]) {
        NSDictionary* theImageData = theData;
        NSArray* theImageString = theImageData[@"image"];
        if (theImageString != Nil && theImageString.count > 0) {
            self.hasImage = TRUE;
            self.defaultCellImage = [Utility imageFromJSONByteString:theImageString];
            [self.theTable reloadData];
        }
    }
}

- (void) connectionFailure:(NSString*) theClientId {
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, theClientId);
    [MBProgressHUD hideAllHUDsForView:self.view animated:TRUE];
    if ([theClientId isEqualToString:@"Send Photos"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Communication error" message:@"Cannot upload the photo on server" delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    }
}


#pragma mark - Initialization

- (void) initialize:(CellMonitoring *)theCell delegate:(id<AroundMeViewItf>) theDelegate {
    _theCell =  theCell;
    _delegate = theDelegate;
    _isBasicCellInfos = FALSE; // Specific iPad?
}

- (void) initializeWithSimpleCellInfo:(CellMonitoring *)theCell {
    _theCell =  theCell;
    _delegate = Nil;
    _isBasicCellInfos = TRUE; // Specific iPad?
    
    CGSize smallViewSize = CGSizeMake(320.0, 393.0); // Specific iPad
    self.preferredContentSize = smallViewSize; // Specific iPad
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.theCell.id;
    self.theTable.delegate = self;
    self.theTable.dataSource = self;
    
    [self initAndLoadCellParameters];
    [self initAndLoadAlarms];
    
    self.hasImage = FALSE;
    
    [RequestUtilities getDefaultSiteImage:self.theCell.siteId quality:LowRes delegate:self clientId:@"getDefaultImage"];
}

-(void) initAndLoadCellParameters {
    if (self.theCell.parametersBySection == Nil) {
        self.isCellParametersLoading = TRUE;
        self.parameterDatasource = [[CellParametersDataSource alloc] init:self];
        [self.parameterDatasource loadData:self.theCell];
    } else {
        self.isCellParametersLoading = FALSE;
    }
}

-(void) initAndLoadAlarms {
    self.alarmDatasource = [[CellAlarmDatasource alloc] init:self.theCell];
    [self.alarmDatasource subscribe:self];
    self.isCellAlarmsLoading = TRUE;
    [self.alarmDatasource loadAlarms];
}

#pragma mark - Cell builders
-(UITableViewCell*) buildCellForNRs:(UITableView*) tableView {
    static NSString *CellNRIdentifier = @"CellNeighborsRelationsId";
    iPadDashboardScopeViewNRCell *cell = [tableView dequeueReusableCellWithIdentifier:CellNRIdentifier];
    
    if (cell == Nil) {
        cell = [[iPadDashboardScopeViewNRCell alloc] init];
    }
    [cell initializeWithCell:self.theCell];
    
    return cell;
}


-(UITableViewCell*) buildCellForKPIs:(UITableView*) tableView {
    static NSString *CellIdentifier = @"CellPropertiesId";
    CellProperties *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == Nil) {
        cell = [[CellProperties alloc] init];
    }
    cell.textCellLabel.text =@"KPIs";
    cell.detailedCellLabel.text = @"Display Cell's KPIs";
    return cell;
    
}

-(UITableViewCell*) buildCellForAlarm:(UITableView*) tableView {
    static NSString *CellAlarmsOverviewIdentifier = @"CellAlarmsOverviewId";
    CellAlarmsOverview *cell = [tableView dequeueReusableCellWithIdentifier:CellAlarmsOverviewIdentifier];
    
    if (cell == Nil) {
        cell = [[CellAlarmsOverview alloc] init];
    }
    
    if (self.isCellAlarmsLoading == TRUE) {
        [cell initializeLoadingAlarms];
    } else {
        [cell initialize:self.alarmDatasource];
    }
    
    return cell;
}

-(UITableViewCell*) buildCellForParameters:(UITableView*) tableView {
    static NSString *CellIdentifier = @"CellPropertiesId";
    CellProperties *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == Nil) {
        cell = [[CellProperties alloc] init];
    }
    cell.textCellLabel.text =@"Parameters";
    
    if (self.isCellParametersLoading) {
        cell.detailedCellLabel.text = @"Parameters are loading...";
    } else {
        if (self.theCell.parametersBySection == Nil) {
            cell.detailedCellLabel.text = @"No cell parameters available";
        } else {
            cell.detailedCellLabel.text = @"Display main cell parameters";
        }
        
    }
    
    return cell;
}

- (UITableViewCell *) buildCellForAddress:(UITableView *)tableView  cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellAddressCellId";
    CellAddressDetails *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    [cell initializeWithCell:self.theCell];
    if (self.defaultCellImage != Nil) {
        cell.sitePicture.image = self.defaultCellImage;
    }
    
    return cell;
    
}

- (UITableViewCell *) buildCellForGeneralSection:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case SECTION_GENERAL_ROW_PARAMETERS: {
            return [self buildCellForParameters:tableView];
        }
        case SECTION_GENERAL_ROW_ALARMS: {
            return [self buildCellForAlarm:tableView];
        }
        case SECTION_GENERAL_ROW_ACTIONS_KPIS: {
            return [self buildCellForKPIs:tableView];
        }
        case SECTION_GENERAL_ROW_NEIGHBORS_RELATIONS: {
            return [self buildCellForNRs:tableView];
        }
        default: {
            return Nil;
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case SECTION_ADDRESS: {
            return @"Cell Description";
            break;
        }
        case SECTION_GENERAL: {
            return @"Cell Properties";
            break;
        }
        default:{
            return @"Unknown";
            break;
        }
            
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case SECTION_ADDRESS: {
            return [self buildCellForAddress:tableView cellForRowAtIndexPath:indexPath];
        }
        case SECTION_GENERAL: {
            return [self buildCellForGeneralSection:tableView cellForRowAtIndexPath:indexPath];
        }
        default: {
            return Nil;
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_GENERAL ) {
        switch (indexPath.row) {
            case SECTION_GENERAL_ROW_PARAMETERS: {
                [self performSegueWithIdentifier:@"openParametersValueId" sender:self];
                break;
            }
            case SECTION_GENERAL_ROW_ALARMS: {
                if ((self.alarmDatasource.alarmsOrderedBySeverity == Nil) || (self.alarmDatasource.alarmsOrderedBySeverity.count == 0)) {
                    return;
                }
                [self performSegueWithIdentifier:@"openAlarmsId" sender:self];
                
            }
        }
    }
}

#pragma mark - Segue
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"openParametersValueId"]) {
        CellParametersValueViewController* controller = segue.destinationViewController;
        controller.theCell = self.theCell;
    } else if ([segue.identifier isEqualToString:@"openAlarmsId"]) {
        CellAlarmsViewController* controller = segue.destinationViewController;
        controller.alarmDatasource = self.alarmDatasource;
    } else if ([segue.identifier isEqualToString:@"pushNRsHistorical"]) {
        HistoricalNRsOverviewViewController* controller = segue.destinationViewController;
        [controller initWithCell:self.theCell];
    } else if ([segue.identifier isEqualToString:@"pushImageSiteList"]) {
        CellImageListViewController* controller = segue.destinationViewController;
        [controller initializeWithCell:self.theCell];
        
    }
}



@end
