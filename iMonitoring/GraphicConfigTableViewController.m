
//
//  GraphicConfigTableViewController.m
//  iMonitoring
//
//  Created by sébastien brugalières on 07/05/13.
//
//

#import "GraphicConfigTableViewController.h"
#import "UserPreferences.h"

@interface GraphicConfigTableViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *cellKPIDetailsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *cellKPIDashboardSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *zoneKPIDashboardSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *zoneKPIDetailsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *mapAnimationSwitch;
@property (weak, nonatomic) IBOutlet UISlider *imageUploadQuality;
@property (weak, nonatomic) IBOutlet UILabel *imageUploadQualityLabel;
@property (weak, nonatomic) IBOutlet UISwitch *geoIndexLookup;

@end

@implementation GraphicConfigTableViewController

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
    
    self.cellKPIDetailsSwitch.on = [UserPreferences sharedInstance].isCellKPIDetailsGradiant;
    self.zoneKPIDetailsSwitch.on = [UserPreferences sharedInstance].isZoneKPIDetailsGradiant;
    self.mapAnimationSwitch.on = [UserPreferences sharedInstance].isMapAnimation;
    self.imageUploadQuality.value = [UserPreferences sharedInstance].imageUploadQuality * 100;
    self.imageUploadQualityLabel.text = [NSString stringWithFormat:@"%d%%", (int)roundf(self.imageUploadQuality.value)];
   
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.cellKPIDashboardSwitch.enabled = FALSE;
        self.zoneKPIDashboardSwitch.enabled = FALSE;
    } else {
        self.cellKPIDashboardSwitch.on = [UserPreferences sharedInstance].isCellDashboardGradiant;
        self.zoneKPIDashboardSwitch.on = [UserPreferences sharedInstance].isZoneDashboardGradiant;
    }
    
    self.geoIndexLookup.on = [UserPreferences sharedInstance].isGeoIndexLookup;
}

- (IBAction)cellKPIDetailsChanged:(UISwitch *)sender {
    [UserPreferences sharedInstance].cellKPIDetailsGradiant = self.cellKPIDetailsSwitch.on;
}

- (IBAction)cellKPIDashboardChanged:(UISwitch *)sender {
    [UserPreferences sharedInstance].cellDashboardGradiant = self.cellKPIDashboardSwitch.on;
}

- (IBAction)zoneKPIDetailsChanged:(UISwitch *)sender {
    [UserPreferences sharedInstance].zoneKPIDetailsGradiant = self.zoneKPIDetailsSwitch.on;
}
- (IBAction)zoneKPIDashboardChanged:(UISwitch *)sender {
    [UserPreferences sharedInstance].zoneDashboardGradiant = self.zoneKPIDashboardSwitch.on;
}
- (IBAction)mapAnimationChanged:(id)sender {
    [UserPreferences sharedInstance].mapAnimation = self.mapAnimationSwitch.on;
}
- (IBAction)geoIndexLookupChanged:(id)sender {
    [UserPreferences sharedInstance].geoIndexLookup = self.geoIndexLookup.on;
}

- (IBAction)imageUploadQualityHasChnaged:(UISlider *)sender {
    [UserPreferences sharedInstance].imageUploadQuality = roundf(self.imageUploadQuality.value) / 100.0;
    self.imageUploadQualityLabel.text = [NSString stringWithFormat:@"%d%%", (int)roundf(self.imageUploadQuality.value)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
