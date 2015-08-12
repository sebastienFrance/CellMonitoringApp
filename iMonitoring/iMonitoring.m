//
//  iMonitoring.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 19/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "iMonitoring.h"
#import "NavDataParsing.h"
#import "AroundMeViewController.h"
#import "iPadImonitoringViewController.h"
#import "iPadAroundMeImpl.h"
#import "DataCenter.h"
#import "DataManagement.h"
#import "SWRevealViewController/SWRevealViewController.h"
#import "iMonitoringMainViewController.h"
#import "AroundMeImpl.h"
#import "AroundMeViewItf.h"
#import "UserActivityHelper.h"
#import "Utility.h"

typedef void(^restorationHandler_t)(NSArray *);

@interface iMonitoring()

@property(nonatomic) NSInputStream* theInputStream;
@property(nonatomic) NSMutableData *theData;
@property(nonatomic, copy) restorationHandler_t theRestorationHandler;

@end

@implementation iMonitoring
@synthesize navigationCells = _navigationCells;

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[DataManagement sharedInstance] initializeIt];
    
    
    [DataCenter sharedInstance].isAppStarting = TRUE;

    return YES;
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"%s", __PRETTY_FUNCTION__);

    NavDataParsing* parser = [[NavDataParsing alloc] init];
    NavDataParsingStatus status = [parser parseNavigationData:url];

    switch (status) {
        case InitializationError: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Navigation data" message:@"Initialization error" delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];
            return FALSE;
        }
        case ParseError: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Navigation data" message:@"Parsing error" delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];
            return FALSE;
        }
        case Success: {
            _navigationCells = parser.navigationCells;
            return TRUE;
        }
    }
}

				
- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // Reset it to avoid automatic navigation when the App comes back in Foreground
    _navigationCells = Nil;
 
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
   // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    DataCenter* dc = [DataCenter sharedInstance];
    if ((_navigationCells != Nil) && (_navigationCells.count > 0)) {
        
        if (dc.isAppStarting == FALSE) {
            
#warning SEB: doesn't work if the user is not already connected / Same for User Activity
           [iMonitoring goToMapViewController];
            
            NSArray* navigationCellsForUser = [[NSArray alloc] initWithArray:_navigationCells];
            [[DataCenter sharedInstance].aroundMeItf initializeFromNav:navigationCellsForUser];

        } else {
            dc.isAppStarting = FALSE;
        }
    } else {
        dc.isAppStarting = FALSE;
    }
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
 
    self.completionHandler = completionHandler;
    
}

#pragma mark - UserActivity

- (void) application:(UIApplication *)application didUpdateUserActivity:(NSUserActivity *)userActivity {
}

-(BOOL) application:(UIApplication *) application willContinueUserActivityWithType:(NSString *)userActivityType {
    if ([userActivityType isEqualToString:ActivityTypeViewingCells]) {
        return TRUE;
    } else {
        return FALSE;
    }
}

-(BOOL) application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler {
    if ([userActivity.activityType isEqualToString:ActivityTypeViewingCells]) {

        [iMonitoring goToMapViewController];

        if (userActivity.supportsContinuationStreams == TRUE) {
            [userActivity getContinuationStreamsWithCompletionHandler:^(
                                                                        NSInputStream *inputStream,
                                                                        NSOutputStream *outputStream, NSError *error) {
                if (error != Nil) {
 
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Communication Error" message:@"Cannot get data to continue the user activity" delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                    [alert show];
                    NSLog(@"%s error with getContinuationStreamsWithCompletionHandler %@", __PRETTY_FUNCTION__,error.localizedDescription);
                } else {
                    if (inputStream != Nil) {
                        
                        self.theData = [[NSMutableData alloc] init];
                        self.theInputStream = inputStream;
                        self.theInputStream.delegate = self;
                        [self.theInputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
                        [self.theInputStream open];
                        self.theRestorationHandler = restorationHandler;
                    } else {
                        NSLog(@"%s: input stream is nil!", __PRETTY_FUNCTION__);
                    }
                }
               
            }];

        } else {
            id<AroundMeViewItf> aroundMeItf = [DataCenter sharedInstance].aroundMeItf;
            UIViewController* mapVC = [aroundMeItf aroundMeViewController];
            restorationHandler(@[mapVC]);
        }

        return TRUE;
    } else {
        NSLog(@"%s FALSE", __PRETTY_FUNCTION__);
        return FALSE;
    }
}

+(void) goToMapViewController {
    DataCenter* dc = [DataCenter sharedInstance];
    
     id<AroundMeViewItf> aroundMeItf = dc.aroundMeItf;
    UIViewController* mapVC = [aroundMeItf aroundMeViewController];
    
    // Get the position of the Toogle Menu
    SWRevealViewController* revealVC = dc.slidingViewController;
    FrontViewPosition position = revealVC.frontViewPosition;
    
    switch (position) {
        case FrontViewPositionRight: {
            // When the position is "Right" it means the toggle menu is displayed and we can navigate directly to the Map
            iMonitoringMainViewController* iMonitoringTopView = (iMonitoringMainViewController*) revealVC.rearViewController;
            [iMonitoringTopView nagivateToMap];
            break;
        }
        case FrontViewPositionLeft: {
            // When the position is "Left" either the Map is displayed or a NavigationController triggered by the toggle Menu
            UINavigationController* navController = (UINavigationController*)revealVC.frontViewController;
            if (revealVC.frontViewController == mapVC.parentViewController) {
                if (navController.visibleViewController != mapVC) {
                    [iMonitoring dismissModalAndPopToRootOf:navController];
                } else {
                    [navController popToRootViewControllerAnimated:TRUE];
                }
            } else {
                [iMonitoring dismissModalAndPopToRootOf:navController];
                
                iMonitoringMainViewController* iMonitoringTopView = (iMonitoringMainViewController*) revealVC.rearViewController;
                [iMonitoringTopView nagivateToMap];
            }
            break;
        }
        default: {
            NSLog(@"%s: Warning FrontViewPosition not managed", __PRETTY_FUNCTION__); // Cannot happen!
            break;
        }
    }

}

// Dismiss all modals ViewControllers displayed under the visible ViewController in the NavigationController
// It iterates through all "Presented" ViewController to build a stack
// We can dissmissViewController from the top of the stack to the bottom to close all Modal ViewControllers
//
// When all Modals are closed we go back to the Root of the NavigationController

+(void) dismissModalAndPopToRootOf:(UINavigationController*) navController {
    
    if (navController.visibleViewController.parentViewController == Nil) {
        // it's not a children of the NavController, so it's most probably a modal or several modals
        UIViewController* currentViewController = navController.visibleViewController;
        NSMutableArray* stackOfPresentedVC = [[NSMutableArray alloc] init];
        
        while (currentViewController.presentedViewController != Nil) {
            [stackOfPresentedVC addObject:currentViewController];
            currentViewController = currentViewController.presentedViewController;
        }
        [stackOfPresentedVC addObject:currentViewController];
        
        for (NSInteger i = (stackOfPresentedVC.count) - 1; i >= 0; i--) {
            currentViewController = stackOfPresentedVC[i];
            [currentViewController dismissViewControllerAnimated:FALSE completion:Nil];
        }
    }
    
    [navController popToRootViewControllerAnimated:TRUE];
}

-(void) application:(UIApplication *)application didFailToContinueUserActivityWithType:(NSString *)userActivityType error:(NSError *)error {
    NSLog(@"%s for userActivityType %@ for reason: %@", __PRETTY_FUNCTION__, userActivityType, error.description);
}

#pragma mark - NSStreamDelegate protocol

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
    switch (streamEvent) {
        case NSStreamEventHasBytesAvailable: { // Read the data from the InputStream
            uint8_t buf[1024];
            NSUInteger len = [self.theInputStream read:buf maxLength:1024];
            if(len) {
                [self.theData appendBytes:(const void *)buf length:len];
            } else {
                NSLog(@"%s no buffer!",__PRETTY_FUNCTION__);
            }
            break;
        }
        case NSStreamEventEndEncountered: { // All data from the inputStream have been read
            
            // Close the input Stream
            [self.theInputStream close];
            [self.theInputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            self.theInputStream = Nil;
            
            // Send the data to the ViewController
            NSArray* navCells = [NSKeyedUnarchiver unarchiveObjectWithData:self.theData];
            
            id<AroundMeViewItf> aroundMeItf = [DataCenter sharedInstance].aroundMeItf;
            [aroundMeItf initializeFromNav:navCells];
            UIViewController* mapVC = [aroundMeItf aroundMeViewController];
            self.theRestorationHandler(@[mapVC]);
            break;
        }
        default: {
            
        }
    }
}

@end
