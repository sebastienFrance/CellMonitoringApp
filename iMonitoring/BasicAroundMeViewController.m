//
//  BasicAroundMeViewController.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 22/11/2014.
//
//

#import "BasicAroundMeViewController.h"
#import "SWRevealViewController/SWRevealViewController.h"
#import "AroundMeViewItf.h"
#import "MapModeItf.h"
#import "DataCenter.h"
#import "AroundMeMapViewMgt.h"
#import "UserActivityHelper.h"
#import "CMLocationManager.h"
#import "BasicAroundMeImpl.h"
#import "AroundMeMapViewDelegate.h"
#import "MapConfigurationUpdate.h"


@import Foundation;

@interface BasicAroundMeViewController()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *userLocationButton;
@property(nonatomic) CMLocationManager* locationManager;

@property (nonatomic) AroundMeMapViewDelegate* mapDelegate;


// For userActivity stream

@property (nonatomic) NSOutputStream* theOutputStream;
@property (nonatomic) NSData*   theDataToStream;
@property (nonatomic) NSUInteger byteIndex;


@end

@implementation BasicAroundMeViewController


#pragma mark - GUI Callback
- (IBAction)menuButton:(UIBarButtonItem *)sender {
    [self.revealViewController revealToggle:Nil];
    
}

- (IBAction)displayAroundMe:(UIBarButtonItem *)sender {
    
    id<AroundMeViewItf> aroundMe = [DataCenter sharedInstance].aroundMeItf;
    
    aroundMe.currentMapMode = MapModeDefault;
    
    [aroundMe.aroundMeMapVC displayMapAroundUserLocation];
}


- (IBAction)refresh:(UIBarButtonItem *)sender {
    id<AroundMeViewItf> aroundMe = [DataCenter sharedInstance].aroundMeItf;
    
    [aroundMe reloadCellsFromServer];
    
}

#pragma mark - View initializations

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initializeUserActivity];
    [self initializeLocationManager];
    
    DataCenter* dc = [DataCenter sharedInstance];
    BasicAroundMeImpl* viewImpl = (BasicAroundMeImpl*) dc.aroundMeItf;
    
    self.mapConfUpdate = [self initializeMapConfigurationUpdate:viewImpl refresh:viewImpl map:self.theMapView];
    self.mapDelegate = [self initializeMapViewDelegate:viewImpl mapMode:viewImpl];
    self.theMapView.delegate = self.mapDelegate;
    
    [viewImpl loadViewContent];
    
    [DataCenter sharedInstance].slidingViewController = self.revealViewController;
    
    
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.navigationController setToolbarHidden:FALSE animated:FALSE];
    self.navigationController.hidesBarsOnTap = TRUE;

}


// Can be overriden by subclass
-(AroundMeMapViewDelegate*) initializeMapViewDelegate:(id<MapDelegateItf>) mapDelegate mapMode:(id<MapModeItf>) mode {
    return [[AroundMeMapViewDelegate alloc] init:mapDelegate mapMode:mode];
}

// Can be overriden by subclass
-(id<configurationUpdated>) initializeMapConfigurationUpdate:(id<MapModeItf>) theMapMode refresh:(id<MapRefreshItf>) theMapRefresh map:(MKMapView*) theMapView {
    return [[MapConfigurationUpdate alloc] init:theMapMode refresh:theMapRefresh map:theMapView];
}

#pragma mark - Gesture for Map

-(void) showToolbar {
    [self.navigationController setNavigationBarHidden:FALSE animated:YES];
}


#pragma mark - Others
// Must be overriden by subclass
- (void) showCellGroupOnMap:(CellMonitoringGroup *)theSelectedCellGroup annotationView:(MKAnnotationView *)view {
}


- (void) refreshMapDisplayOptions {
    [self.mapConfUpdate updateConfiguration];
}

-(MKMapView*) getMapView {
    return self.theMapView;
}

- (void) connectionCompleted {
    
}
// Can be overriden by subclass
- (void) dismissAllPopovers {
}


#pragma mark - User activity

-(void) updateUserActivity {
    self.userActivity.needsSave = TRUE;
}

-(void) initializeUserActivity {
    // initialize the user activity
    self.userActivity = [UserActivityHelper initializeUserActivity:self];
    [self.userActivity becomeCurrent];
}

-(void) updateUserActivityState:(NSUserActivity *)activity {
    [super updateUserActivityState:activity];
    
    id<AroundMeViewItf> delegate = [DataCenter sharedInstance].aroundMeItf;
    
    if (delegate.currentMapMode == MapModeNavMultiCell) {
        self.userActivity.supportsContinuationStreams = TRUE;
    } else {
        self.userActivity.supportsContinuationStreams = FALSE;
    }
    
    [self.userActivity addUserInfoEntriesFromDictionary:[UserActivityHelper arrayForViewingCells:delegate]];
}

-(void) restoreUserActivityState:(NSUserActivity *)activity {
    
    MKMapCamera* newCamera = [UserActivityHelper mapCameraFromViewingCells:activity];
    
    id<AroundMeViewItf> delegate = [DataCenter sharedInstance].aroundMeItf;
    
    MapModeEnabled activityMapMode = [UserActivityHelper mapMode:activity];
    
    switch (activityMapMode) {
        case MapModeDefault:
            delegate.currentMapMode = activityMapMode;
            [delegate.aroundMeMapVC showLocationOnMapAndReloadWithCamera:newCamera];
            break;
        case MapModeNavMultiCell: {
            [delegate.aroundMeMapVC showLocationOnMapAndReloadWithCamera:newCamera];
            break;
        }
        case MapModeZone: {
            delegate.currentMapMode = activityMapMode;
            [delegate initiliazeWithZone:[UserActivityHelper zoneName:activity]];
            [delegate.aroundMeMapVC showLocationOnMapAndReloadWithCamera:newCamera];
            break;
        }
        case MapModeNeighbors: {
            delegate.currentMapMode = activityMapMode;
            NSLog(@"%s received cell : %@", __PRETTY_FUNCTION__, [UserActivityHelper centerCellNeighbor:activity]);
            [delegate initializeWithBeighborsOfFromCell:[UserActivityHelper centerCellNeighbor:activity]];
            break;
        }
        default: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Activity Warning" message:@"Cannot manage this user activity" delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];
        }
    }
}

#pragma mark - NSUserActivityDelegate protocol

- (void)userActivity:(NSUserActivity *)userActivity
didReceiveInputStream:(NSInputStream *)inputStream
        outputStream:(NSOutputStream *)outputStream {
  
    id<AroundMeViewItf> delegate = [DataCenter sharedInstance].aroundMeItf;

    self.byteIndex = 0;
    self.theDataToStream = [NSKeyedArchiver archivedDataWithRootObject:delegate.navCells];
    self.theOutputStream = outputStream;
    self.theOutputStream.delegate = self;
    
    [self.theOutputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.theOutputStream open];    
}

- (void)userActivityWasContinued:(NSUserActivity *)userActivity {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
}

- (void)userActivityWillSave:(NSUserActivity *)userActivity {
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
    switch (streamEvent) {
        case NSStreamEventHasSpaceAvailable: { // Write the data to the outputStream
            uint8_t *readBytes = (uint8_t *)[self.theDataToStream bytes];
            readBytes += self.byteIndex; // instance variable to move pointer
            NSUInteger data_len = [self.theDataToStream length];
            NSUInteger len = (data_len - self.byteIndex >= 1024) ? 1024 : (data_len-self.byteIndex);
            uint8_t buf[len];
            (void)memcpy(buf, readBytes, len);
            
            len = [self.theOutputStream write:(const uint8_t *)buf maxLength:len];
            self.byteIndex += len;
            break;
        }
        case NSStreamEventEndEncountered: {
            [self.theOutputStream close];
            [self.theOutputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            self.theOutputStream = Nil;
            break;
        }
        default: {
            NSLog(@"%s unexpected event for stream",__PRETTY_FUNCTION__);
            break;
        }
    }
}

#pragma mark - LocationManagerDelegate protocol

-(void) initializeLocationManager {
    self.locationManager = [[CMLocationManager alloc] init];
    [self.locationManager startLocation:self];
    
}


-(void) locationAutorization:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.userLocationButton.enabled = TRUE;
        self.theMapView.showsUserLocation = TRUE;
    } else {
        self.userLocationButton.enabled = FALSE;
        self.theMapView.showsUserLocation = FALSE;
    }
}

@end
