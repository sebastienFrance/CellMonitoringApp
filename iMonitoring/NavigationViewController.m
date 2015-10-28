//
//  NavigationViewController.m
//  iMonitoring
//
//  Created by sébastien brugalières on 31/10/2013.
//
//

#import "NavigationViewController.h"
#import "MBProgressHUD.h"
#import "DataCenter.h"
#import <MapKit/MapKit.h>
#import "UserPreferences.h"
#import "AroundMeMapViewMgt.h"
#import "ReverseGeoCodeRouteDataSource.h"
#import "RouteInformation.h"
#import "RouteDirectionDataSource.h"
#import "NavigationViewCell.h"
#import "Utility.h"

@interface NavigationViewController ()
@property (weak, nonatomic) IBOutlet UITextField *StartFrom;
@property (weak, nonatomic) IBOutlet UITextField *DestinationTo;

@property (nonatomic) CLLocation* sourceLocation;
@property (nonatomic) CLLocation* destinationaLocation;
@property (weak, nonatomic) IBOutlet UISlider *borderSlider;
@property (weak, nonatomic) IBOutlet UILabel *borderDistanceLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *transportSelectionSegmented;
@property (weak, nonatomic) IBOutlet UITableView *theTableView;

@property (nonatomic) ReverseGeoCodeRouteDataSource* datasource;
@property (nonatomic) RouteDirectionDataSource* routeDatasource;

@property (nonatomic) RouteInformation* routeInfo;
@property (nonatomic) NSArray* routes;

@end

@implementation NavigationViewController


-(void) hideKeyboard {
    if (self.StartFrom.isFirstResponder) {
        [self.StartFrom resignFirstResponder];
    } else if (self.DestinationTo.isFirstResponder) {
        [self.DestinationTo resignFirstResponder];
    }
}
- (IBAction)goPushed:(UIButton *)sender {
    [self saveInUserPreferences];
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Looking for address";

    MKDirectionsTransportType transportType = [self getTransportType];

    id<AroundMeViewItf> aroundMe = [DataCenter sharedInstance].aroundMeItf;

    self.datasource = [[ReverseGeoCodeRouteDataSource alloc] init:aroundMe.aroundMeMapVC delegate:self];

    [self.datasource reverseGeoCodeRoute:self.StartFrom.text
                             destination:self.DestinationTo.text
                           transportType:transportType
                                  border:[self getBorderValue]];
    
    [self hideKeyboard];
}

-(MKDirectionsTransportType) getTransportType {
    switch (self.transportSelectionSegmented.selectedSegmentIndex) {
        case 0: {
            return MKDirectionsTransportTypeAutomobile;
            break;
        }
        case 1: {
            return MKDirectionsTransportTypeWalking;
            break;
        }
        case 2: {
            return MKDirectionsTransportTypeTransit;
            break;
        }
        default: {
            return MKDirectionsTransportTypeAutomobile;
            break;
        }
    }
}

#pragma mark - RouteDataSourceDelegate protocol
-(void) reverseGeoCodeRouteResponse:(RouteInformation*) route error:(NSError*) theError {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (theError != Nil) {
        UIAlertController* alert = [Utility getSimpleAlertView:@"Error"
                                                       message:@"Cannot resolve locations."
                                                   actionTitle:@"OK"];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        self.routeInfo = route;
        [self.routeDatasource getDirectionsFor:route delegate:self];
    }
}
#pragma  mark - RouteDirectionDataSourceDelegate Protocol

-(void) routeDirectionResponse:(NSArray*) routes error:(NSError*) theError {
    
    if (theError != Nil) {
        UIAlertController* alert = [Utility getSimpleAlertView:@"Error"
                                                       message:@"Cannot build routes."
                                                   actionTitle:@"OK"];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    } else {
        self.routes = routes;
        
        [self.theTableView reloadData];
    }
}

- (IBAction)sliderBorderChangedValue:(UISlider *)sender {
    NSUInteger value = [self getBorderValue];
    self.borderDistanceLabel.text = [NSString stringWithFormat:@"%lu m", (unsigned long)value];
}


- (NSUInteger) getBorderValue {
    NSUInteger value = self.borderSlider.value;
    NSUInteger reste = value % 10;
    value = value - reste;
    return value;
}

- (IBAction)directionTypeSelected:(UISegmentedControl *)sender {
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.StartFrom.delegate = self;
    self.DestinationTo.delegate = self;
    
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    
    self.theTableView.estimatedRowHeight = 86.0;
    self.theTableView.rowHeight = UITableViewAutomaticDimension;
    

    
    self.routeDatasource = [[RouteDirectionDataSource alloc] init];

    
    [self restoreFromUserPreferences];
    
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(1, 1, 40, 30) ];
    [lbl setText:@"From:"];
    [lbl setFont:[UIFont systemFontOfSize:14.0]];
    [lbl setTextColor:[UIColor darkGrayColor]];
    [lbl setTextAlignment:NSTextAlignmentLeft];
    self.StartFrom.leftView = lbl;
    self.StartFrom.leftViewMode = UITextFieldViewModeAlways;

    lbl = [[UILabel alloc] initWithFrame:CGRectMake(1, 1, 20, 30) ];
    [lbl setText:@"To:"];
    [lbl setFont:[UIFont systemFontOfSize:14.0]];
    [lbl setTextColor:[UIColor darkGrayColor]];
    [lbl setTextAlignment:NSTextAlignmentLeft];
    self.DestinationTo.leftView = lbl;
    self.DestinationTo.leftViewMode = UITextFieldViewModeAlways;
    
    [NavigationViewController updateTextFieldPropertiesForSpecificWords:self.StartFrom];
    [NavigationViewController updateTextFieldPropertiesForSpecificWords:self.DestinationTo];
}

-(void) restoreFromUserPreferences {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    
    self.borderSlider.value = userPrefs.RouteLookupInMeters;
    self.StartFrom.text = userPrefs.RouteFrom;
    self.DestinationTo.text = userPrefs.RouteTo;
    self.transportSelectionSegmented.selectedSegmentIndex = userPrefs.RouteTransportType;
    
    self.borderDistanceLabel.text = [NSString stringWithFormat:@"%lu m", (unsigned long)userPrefs.RouteLookupInMeters];
}

-(void) saveInUserPreferences {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    
    userPrefs.RouteFrom = self.StartFrom.text;
    userPrefs.RouteTo = self.DestinationTo.text;
    userPrefs.RouteLookupInMeters = [self getBorderValue];
    userPrefs.RouteTransportType = self.transportSelectionSegmented.selectedSegmentIndex;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == self.StartFrom) {
        [self.DestinationTo becomeFirstResponder];
    } else if (textField == self.DestinationTo) {
        [textField resignFirstResponder];
    }
    
    return NO;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString* resultString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([resultString isEqualToString:@"here"]) {
        [NavigationViewController setHighlightedText:textField];
    } else {
        [NavigationViewController setNormalText:textField];
    }
    
    return TRUE;
}


#pragma mark - Utilties for TextField
         
+(void) updateTextFieldPropertiesForSpecificWords:(UITextField*) textField {
    if ([textField.text isEqualToString:@"here"]) {
        [NavigationViewController setHighlightedText:textField];
    } else {
        [NavigationViewController setNormalText:textField];
    }
}

+(void) setHighlightedText:(UITextField*) textField {
    textField.textColor = [UIColor blueColor];
    textField.font = [UIFont boldSystemFontOfSize:14.0];
}

+(void) setNormalText:(UITextField*) textField {
    textField.textColor = [UIColor blackColor];
    textField.font = [UIFont systemFontOfSize:14.0];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Routes";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.routes != Nil) {
        return self.routes.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"NavigationCellId";
    NavigationViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [cell initWithRoute:self.routes[indexPath.row] buttonId:indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.navigationController popViewControllerAnimated:TRUE];
    }
    id<MapRefreshItf> aroundMe = [DataCenter sharedInstance].aroundMeItf;
    [aroundMe reloadCellsFromServerWithRouteAndDirection:self.routeInfo direction:self.routes[indexPath.row]];
}

@end
