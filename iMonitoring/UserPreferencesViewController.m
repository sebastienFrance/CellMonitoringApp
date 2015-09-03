//
//  UserPreferencesViewController.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 08/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserPreferencesViewController.h"
#import "KPIsTechnoCell.h"
#import "KPIsPrefListViewController.h"
#import "DataCenter.h"
#import "MonitoringPeriodViewController.h"
#import "TouchIdCell.h"
#import "SWRevealViewController/SWRevealViewController.h"
#import "KPIDictionaryManager.h"
#import "UserPreferences.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface UserPreferencesViewController ()

@property (nonatomic) KPIsPrefListViewController* currentKPIsController;
@property (nonatomic) NSArray<NSString*>* technoLabel;
@property (nonatomic) NSArray<UIImage*>* imageLabel;

@property (nonatomic, strong) UIPanGestureRecognizer *dynamicTransitionPanGesture;

@end

@implementation UserPreferencesViewController
@synthesize preferencesTableView;


static const NSUInteger USER_PREFS_SECTION_KPIS = 0;
static const NSUInteger USER_PREFS_SECTION_MONITORING_CONFIG = 1;
static const NSUInteger USER_PREFS_SECTION_GRAPHICS_CONFIG = 2;
static const NSUInteger USER_PREFS_SECTION_SECURITY = 3;
static const NSUInteger USER_PREFS_SECTION_ADMIN = 4;

static NSUInteger _technoMapping[] =  { DCTechnologyLTE, DCTechnologyWCDMA, DCTechnologyGSM };

#pragma mark - Initializations

- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder])) {
        _technoLabel = @[@"LTE KPIs", @"WCDMA KPIs", @"GSM KPIs"];
        _imageLabel = @[[UIImage imageNamed:@"LTE_logo.jpg"], [UIImage imageNamed:@"logo_3g_150.jpg"], [UIImage imageNamed:@"GSMLogo.png"]];
        
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    preferencesTableView.dataSource = self;
    preferencesTableView.delegate = self;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.navigationItem setLeftBarButtonItems:nil animated:YES]; // hide Side Menu button
    }

    self.title = @"Preferences";

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.revealViewController != Nil) {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

- (IBAction)menuButtonPushed:(id)sender {
    [self.revealViewController revealToggle:Nil];
}

- (IBAction)touchIdPressed:(UISwitch *)sender {
    [UserPreferences sharedInstance].touchIdEnabled = sender.on;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    DataCenter* dc = [DataCenter sharedInstance];
    if (dc.isAdminUser == FALSE) {
        return 4; // Don't show change password for non admin user
    } else {
        return 5;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case USER_PREFS_SECTION_KPIS: return _technoLabel.count;
        case USER_PREFS_SECTION_MONITORING_CONFIG: return 2;
        case USER_PREFS_SECTION_GRAPHICS_CONFIG: return 1;
        case USER_PREFS_SECTION_SECURITY: return 1;
        case USER_PREFS_SECTION_ADMIN: return 1;
        default: return 0;
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdForKPIs = @"LTECellKPIsPrefs";
    static NSString *CellIdForMonitoringPeriod = @"DefaultMonitoringPeriodId";
    static NSString *CellIdForTouchId = @"touchIdCellId";

    switch (indexPath.section) {
        case USER_PREFS_SECTION_KPIS: {
            KPIsTechnoCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdForKPIs forIndexPath:indexPath];

            cell.technoLabel.text = _technoLabel[indexPath.row];
            cell.technoImage.image = _imageLabel[indexPath.row];
            return cell;
            
        }
        case USER_PREFS_SECTION_MONITORING_CONFIG: {
            UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdForMonitoringPeriod forIndexPath:indexPath];

            if (indexPath.row == 0) {
                cell.textLabel.text = @"Default Monitoring Period";
                cell.detailTextLabel.text = [[MonitoringPeriodUtility sharedInstance] monitoringPeriodString];
            } else {
                cell.textLabel.text = @"Default KPI dictionary";
                cell.detailTextLabel.text = [[KPIDictionaryManager sharedInstance] defaultKPIDictionaryName];
            }
            return cell;
           
        }
        case USER_PREFS_SECTION_GRAPHICS_CONFIG: {
            UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdForMonitoringPeriod forIndexPath:indexPath];

            cell.textLabel.text = @"Graphics options";
            cell.detailTextLabel.text = @"Configure graphics properties";
            
            return cell;
            
        }
        case USER_PREFS_SECTION_SECURITY: {
            TouchIdCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdForTouchId forIndexPath:indexPath];

            LAContext *context = [LAContext new];
            NSError *error;

            if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
                cell.touchIdSwitch.on = [UserPreferences sharedInstance].isTouchIdEnabled;
            } else {
                cell.touchIdSwitch.on = FALSE;
                cell.touchIdSwitch.enabled = FALSE;
            }

            return cell;
        }
        case USER_PREFS_SECTION_ADMIN: {
            UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdForMonitoringPeriod forIndexPath:indexPath];

            cell.textLabel.text = @"Change Password";
            cell.detailTextLabel.text = @"Change your password to connect";
            
            return cell;
            
        }
        default: {
            return Nil;
        }
            
    }
    
    return Nil;
        
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case USER_PREFS_SECTION_KPIS: {
            [self performSegueWithIdentifier:@"openKPIsTechnoListId" sender:self];
            break;
        }
        case USER_PREFS_SECTION_MONITORING_CONFIG: {
            [self performSegueWithIdentifier:@"openMonitoringPeriodId" sender:self];
            break;
        }
        case USER_PREFS_SECTION_GRAPHICS_CONFIG: {
            [self performSegueWithIdentifier:@"openGraphicConfigId" sender:self];
            break;
        }
        case USER_PREFS_SECTION_ADMIN: {
            [self performSegueWithIdentifier:@"OpenChangePassword" sender:self];
            break;
        }
        default: {
            
        }
    }
}

#pragma mark - Others
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"openKPIsTechnoListId"]) {
        _currentKPIsController = segue.destinationViewController;
        
        NSIndexPath* indexPath = [preferencesTableView indexPathForSelectedRow];
        if ((indexPath.section == USER_PREFS_SECTION_KPIS)) {
            [_currentKPIsController initTechno:_technoMapping[indexPath.row]];
        }
        
    } else if ([segue.identifier isEqualToString:@"openMonitoringPeriodId"]) {
        MonitoringPeriodViewController* vc = segue.destinationViewController;
        vc.delegate = self;
        NSIndexPath* indexPath = [preferencesTableView indexPathForSelectedRow];
        if (indexPath.row == 0) {
            vc.isKPIDictionary = FALSE;
        } else {
            vc.isKPIDictionary = TRUE;
        }
    }
}

- (void) updateDefaultMonitoringPeriod {
    [preferencesTableView reloadData];
}

- (void) updateDefaultKPIDictionary {
    [preferencesTableView reloadData];    
}

@end
