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
#import "CellBookmark+MarkedCell.h"
#import "MailCellKPI.h"
#import "MailActivity.h"
#import "KPIDictionaryManager.h"
#import "CellKPIsDataSource.h"
#import "DisplayKPICell.h"
#import "KPI.h"
#import "DetailsCellWithChartViewController.h"
#import "MarkViewController.h"
#import "KPIDictionary.h"
#import "KPIDictionaryManager.h"
#import "iPadAroundMeImpl.h"

@interface CellDetailsInfoBasicViewController()


@property(nonatomic) Boolean isCellParametersLoading;
@property(nonatomic) Boolean isCellAlarmsLoading;

@property(nonatomic) CellAlarmDatasource* alarmDatasource;
@property(nonatomic) CellParametersDataSource* parameterDatasource;

@property(nonatomic) CellKPIsDataSource* datasource;
@property (nonatomic) CellTimezoneDataSource* timezoneDatasource;


@property (weak, nonatomic) IBOutlet UITableView *theTable;


@property (nonatomic) CellMonitoring* theCell;
@property (nonatomic,weak) id<AroundMeViewItf> delegate;

@property(nonatomic) Boolean isBasicCellInfos;
@property(nonatomic) Boolean isKPIsDisplayed;

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

#pragma mark - MarkedCell

-(void) marked:(UIColor*) theColor userText:(NSString*) theText {

    [CellBookmark createCellBookmark:self.theCell comments:theText color:theColor];
    NSIndexPath* AddressIndex = [NSIndexPath indexPathForRow:SECTION_ADDRESS_ROW_CELL_ADDRESS inSection:SECTION_ADDRESS];
    [self.theTable reloadRowsAtIndexPaths:@[AddressIndex] withRowAnimation:FALSE];

    // Refresh the map content if filtering based on Marked cells
    [self.delegate refreshMapWithFilter:TRUE overlays:FALSE];
}

- (void) cancel {
}

#pragma mark - Buttons

- (IBAction)markButtonPushed:(UIButton *)sender {
    if ([CellBookmark isCellMarked:self.theCell]) {
        [CellBookmark removeCellBookmark:self.theCell.id];
        NSIndexPath* AddressIndex = [NSIndexPath indexPathForRow:SECTION_ADDRESS_ROW_CELL_ADDRESS inSection:SECTION_ADDRESS];
        [self.theTable reloadRowsAtIndexPaths:@[AddressIndex] withRowAnimation:FALSE];

        // Refresh the map content if filtering based on Marked cells
        [self.delegate refreshMapWithFilter:TRUE overlays:FALSE];
    } else {
        [self performSegueWithIdentifier:@"openMarkCell" sender:self];
    }
}

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


#pragma  mark - AlarmListener protocol

- (void) alarmLoadingFailure {
    self.isCellAlarmsLoading = FALSE;
    UIAlertController* alert = [Utility getSimpleAlertView:@"Communication failure"
                                                   message:@"Cell alarms cannot be loaded."
                                               actionTitle:@"OK"];
    [self presentViewController:alert animated:YES completion:nil];

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
        UIAlertController* alert = [Utility getSimpleAlertView:@"Communication error"
                                                       message:@"Cannot upload the photo on server."
                                                   actionTitle:@"OK"];
        [self presentViewController:alert animated:YES completion:nil];
    }
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

#pragma mark - CellTimezoneDataSourceDelegate delegate
- (void) cellTimezoneResponse:(CellMonitoring*) cell error:(NSError*) theError {
    [self displayCellTimezone:cell.timezone];
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
    [self showToolbar];

    self.title = self.theCell.id;
    self.theTable.delegate = self;
    self.theTable.dataSource = self;
    
    [self initAndLoadCellParameters];
    [self initAndLoadAlarms];
    [self initAndLoadCellDetails];


    self.hasImage = FALSE;
    
    [RequestUtilities getDefaultSiteImage:self.theCell.siteId quality:LowRes delegate:self clientId:@"getDefaultImage"];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self showToolbar];
}


-(void) showToolbar {
    [self.navigationController setToolbarHidden:TRUE];
    self.navigationController.hidesBarsOnSwipe = FALSE;
    self.navigationController.hidesBarsOnTap = FALSE;
}

-(void) initAndLoadCellDetails {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.isKPIsDisplayed = TRUE;
        _datasource = [[CellKPIsDataSource alloc] init:self];

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
    } else {
        self.isKPIsDisplayed = false;
        self.timezoneDatasource = [[CellTimezoneDataSource alloc] initWithDelegate:self cell:self.theCell];
        [self.timezoneDatasource loadTimeZone];
    }
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

-(void) displayCellTimezone:(NSString*) timeZone {
    CellAddressDetails* cell = (CellAddressDetails*) [self.theTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (cell != Nil) {
        cell.timezone.text = timeZone;
    }
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

+(KPI*) getKPI:(DCTechnologyId) cellTechnology indexPath:(NSIndexPath*) indexPath {
    NSIndexPath* realIndexPath = [NSIndexPath indexPathForRow:indexPath.row
                                                    inSection:[CellDetailsInfoBasicViewController getKPISectionIndex:indexPath.section]];

    return [[KPIDictionaryManager sharedInstance] getKPI:cellTechnology indexPath:realIndexPath];
}

+(NSInteger) getKPISectionIndex:(NSUInteger) section {
    return (section - 2);
}

-(UITableViewCell *) buildCellForKPIsSection:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdKPI = @"CellKPIId";

    DisplayKPICell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdKPI forIndexPath:indexPath];

    KPI* cellKPI = [CellDetailsInfoBasicViewController getKPI:self.theCell.cellTechnology indexPath:indexPath];

    MonitoringPeriodUtility* theMP = [MonitoringPeriodUtility sharedInstance];
    NSDictionary<NSString*,NSArray<NSNumber*>*>* KPIs = [self.datasource getKPIsForMonitoringPeriod:[theMP monitoringPeriod]];
    if (KPIs != Nil) {
        NSArray<NSNumber*>* kpiValues = KPIs[cellKPI.internalName];

        [cell initWith:cellKPI monitoringPeriod:[theMP monitoringPeriod] KPIValues:kpiValues date:self.datasource.requestDate];
    } else {
        [cell isStillLoading];
    }
    return cell;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.isKPIsDisplayed) {
        NSDictionary<NSString*,NSArray<KPI*>*> *KPIDictionary = [[KPIDictionaryManager sharedInstance].defaultKPIDictionary getKPIsPerDomain:self.theCell.cellTechnology];
        return (KPIDictionary.count + 2);
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SECTION_ADDRESS) {
        return 1;
    } if (section == SECTION_GENERAL) {
        if (self.isBasicCellInfos == FALSE) {
            return 4;
        } else {
            return 3;
        }
    } else  if (section >= SECTION_KPIS) {
        return [self numberOfRowsForKPIsInSection:section];
    } else {
        return 0;
    }
}

-(NSInteger) numberOfRowsForKPIsInSection:(NSInteger) section {
    return [CellDetailsInfoBasicViewController getKPIsFromSection:section technology:self.theCell.cellTechnology].count;
}

+(NSArray<KPI*>*) getKPIsFromSection:(NSInteger) section technology:(DCTechnologyId) cellTechnology {
    return [[KPIDictionaryManager sharedInstance] getKPIsFromSection:[CellDetailsInfoBasicViewController getKPISectionIndex:section]
                                                          technology:cellTechnology];
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
            if (self.isKPIsDisplayed) {
                return [CellDetailsInfoBasicViewController titleForKPIsInSection:section tehcnology:self.theCell.cellTechnology];
            } else {
                return @"Uknown";
            }
            break;
        }

    }
}

+(NSString*) titleForKPIsInSection:(NSInteger) section tehcnology:(DCTechnologyId) cellTechnology {
    NSArray<NSString*> *sectionsHeader = [[KPIDictionaryManager sharedInstance].defaultKPIDictionary getSectionsHeader:cellTechnology];
    return sectionsHeader[[CellDetailsInfoBasicViewController getKPISectionIndex:section]];
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
            if (self.isKPIsDisplayed) {
                return [self buildCellForKPIsSection:tableView cellForRowAtIndexPath:indexPath];
            } else {
                return Nil;
            }
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
                break;
            }
            case SECTION_GENERAL_ROW_ACTIONS_KPIS: {
                iPadAroundMeImpl* mainEntry = (iPadAroundMeImpl*) self.delegate;
                [mainEntry openDetailedKPIsView:self.theCell];
                break;
            }
            default: {
                NSLog(@"%s unknown case", __PRETTY_FUNCTION__);
            }
        }
    }
}

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

/* For iPad
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

 */


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
        
    } else     if ([segue.identifier isEqualToString:@"openCellKPIDetailsId"]) {
        DetailsCellWithChartViewController* modal = segue.destinationViewController;

        NSIndexPath* selectedIndexInFullTable = [self.theTable indexPathForSelectedRow];
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:selectedIndexInFullTable.row inSection:(selectedIndexInFullTable.section - 2)];

        [modal initialize:self.datasource initialMonitoringPeriod:[[MonitoringPeriodUtility sharedInstance] monitoringPeriod] initialIndex:indexPath];
    } else if ([segue.identifier isEqualToString:@"openMarkCell"]) {
        MarkViewController* modal = segue.destinationViewController;
        modal.delegate = self;
        modal.theCell = self.theCell;
    }
}



@end
