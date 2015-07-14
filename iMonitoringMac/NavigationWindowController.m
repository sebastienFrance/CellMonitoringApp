//
//  NavigationWindowController.m
//  iMonitoring
//
//  Created by sébastien brugalières on 30/12/2013.
//
//

#import "NavigationWindowController.h"
#import "MainMapWindowController.h"
#import "AroundMeMapViewMgt.h"
#import "UserPreferences.h"
#import "RouteDirectionDataSource.h"
#import "NavigationViewCell.h"

@interface NavigationWindowController ()
@property (weak) IBOutlet NSTextField *startingPlaceTextField;
@property (weak) IBOutlet NSTextField *destinationTextField;
@property (weak) IBOutlet NSSlider *borderSlider;
@property (weak) IBOutlet NSTextField *borderTextField;
@property (weak) IBOutlet NSSegmentedControl *transportTypeSegmentedControl;
@property (weak) IBOutlet NSTableView *routeTableview;

@property (nonatomic) ReverseGeoCodeRouteDataSource* datasource;

@property (nonatomic, weak) MainMapWindowController* delegate;
@property (nonatomic) RouteDirectionDataSource* routeDatasource;

@property (nonatomic) NSArray* routes;
@property (nonatomic) RouteInformation* routeInfo;

@end

@implementation NavigationWindowController

- (id)init:(MainMapWindowController*) mainDelegate
 {
    self = [super initWithWindowNibName:@"CellsOnRoute"];
    
     _delegate = mainDelegate;
     _routeDatasource = [[RouteDirectionDataSource alloc] init];
     
    return self;
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.window setLevel:NSStatusWindowLevel];
    
    [self restoreFromUserPreferences];
}
- (IBAction)routeButtonPushed:(NSButton *)sender {

    [self saveInUserPreferences];
    
    self.datasource = [[ReverseGeoCodeRouteDataSource alloc] init:self.delegate.aroundMeMapVC delegate:self];
    
    
    MKDirectionsTransportType transportType = MKDirectionsTransportTypeAutomobile;
    if (self.transportTypeSegmentedControl.selectedSegment == 1) {
        transportType = MKDirectionsTransportTypeWalking;
    }
    
    
    [self.datasource reverseGeoCodeRoute:self.startingPlaceTextField.stringValue destination:self.destinationTextField.stringValue
                           transportType:transportType border:[self getBorderValue]];
}
- (IBAction)showRouteButtonPushed:(NSButton *)sender {
    [self.delegate reloadCellsFromServerWithRouteAndDirection:self.routeInfo direction:self.routes[sender.tag]];
}

- (IBAction)borderSliderHasChangedValue:(NSSlider *)sender {
    NSUInteger value = [self getBorderValue];
    self.borderTextField.stringValue = [NSString stringWithFormat:@"%lu m", (unsigned long)value];
}


-(void) restoreFromUserPreferences {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    
    self.borderSlider.integerValue = userPrefs.RouteLookupInMeters;
    self.startingPlaceTextField.stringValue = userPrefs.RouteFrom;
    self.destinationTextField.stringValue = userPrefs.RouteTo;
    self.transportTypeSegmentedControl.selectedSegment = userPrefs.RouteTransportType;
    
    self.borderTextField.stringValue = [NSString stringWithFormat:@"%lu m", (unsigned long)userPrefs.RouteLookupInMeters];
}

-(void) saveInUserPreferences {
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    
    userPrefs.RouteFrom = self.startingPlaceTextField.stringValue;
    userPrefs.RouteTo = self.destinationTextField.stringValue;
    userPrefs.RouteLookupInMeters = [self getBorderValue];
    userPrefs.RouteTransportType = self.transportTypeSegmentedControl.selectedSegment;
}


- (NSUInteger) getBorderValue {
    NSUInteger value = self.borderSlider.intValue;
    NSUInteger reste = value % 10;
    value = value - reste;
    return value;
}

#pragma  mark - RouteDataSourceDelegate
-(void) reverseGeoCodeRouteResponse:(RouteInformation*) route error:(NSError*) theError {
    
    if (theError != Nil) {
        NSAlert* alert = [NSAlert alertWithMessageText:@"Error"
                                         defaultButton:Nil
                                       alternateButton:Nil
                                           otherButton:Nil
                             informativeTextWithFormat:@"Cannot resolve locations"];
        [alert runModal];
    } else {
        
        self.routeInfo = route;
        [self.routeDatasource getDirectionsFor:route delegate:self];
    }
}


#pragma  mark - RouteDirectionDataSourceDelegate Protocol

-(void) routeDirectionResponse:(NSArray*) routes error:(NSError*) theError {
    
    if (theError != Nil) {
        NSAlert* alert = [NSAlert alertWithMessageText:@"Error"
                                         defaultButton:Nil
                                       alternateButton:Nil
                                           otherButton:Nil
                             informativeTextWithFormat:@"Cannot build the route"];
        [alert runModal];
        return;
    }
    NSLog(@"Routes have been loaded %lu", (unsigned long)routes.count);
    self.routes = routes;
    
    [self.routeTableview reloadData];
}


#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (self.routes == Nil) {
        return 0;
    } else {
        return self.routes.count;
    }
}

// This method is optional if you use bindings to provide the data
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // Group our "model" object, which is a dictionary
    
    // In IB the tableColumn has the identifier set to the same string as the keys in our dictionary
    NSString *identifier = [tableColumn identifier];
    
    // We pass us as the owner so we can setup target/actions into this main controller object
    NavigationViewCell *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
    [cellView initWithRoute:self.routes[row] buttonId:row];
    
    // Then setup properties on the cellView based on the column
    
    return cellView;
}





@end
