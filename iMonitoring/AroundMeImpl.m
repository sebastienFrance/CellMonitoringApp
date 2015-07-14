//
//  AroundMeImpl.m
//  iMonitoring
//
//  Created by sébastien brugalières on 24/03/13.
//
//

#import "AroundMeImpl.h"
#import "MBProgressHUD.h"
#import "EndDemoSessionViewController.h"
#import "DataCenter.h"
#import "iMonitoring.h"
#import "AroundMeViewController.h"

@interface AroundMeImpl()


@property (nonatomic) EndDemoSessionViewController* endDemoVC;

@end

@implementation AroundMeImpl

#pragma mark - Constructor

- (id)init:(BasicAroundMeViewController*) theViewController {
    self = [super init:theViewController];
    return self;
}


#pragma mark - AroundMeViewItf protocol
- (void) stopDemoSession {
    
    SWRevealViewController* viewController = [DataCenter sharedInstance].slidingViewController;
    UINavigationController* navController = (UINavigationController*)viewController.frontViewController;

    if (navController != Nil) {
        
        UIViewController* currentViewController = Nil;
        // When presentedViewController is != Nil it means a Modal view is opened on top of the NavigationController
        // There can be several modal opened so we look for the last one to put our modal on top of it
        if (navController.presentedViewController != Nil) {
            // find the top modal
            currentViewController = navController.presentedViewController;
            while (currentViewController.presentedViewController != Nil) {
                currentViewController = currentViewController.presentedViewController;
            }
        } else {
            currentViewController = navController.visibleViewController;
        }

        [MBProgressHUD hideAllHUDsForView:currentViewController.view animated:FALSE];
        
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboardiPhoneApp" bundle:Nil];
        
        self.endDemoVC = [storyboard instantiateViewControllerWithIdentifier:@"EndDemoSession"];
        
        [currentViewController presentViewController:self.endDemoVC animated:TRUE completion:Nil];
    } 
}

// Common but different
- (void) loadViewContent {
    [super loadViewContent];
    

    // If the App has some NavigationCells we must display them on the map!
    iMonitoring* app = (iMonitoring*)[UIApplication sharedApplication].delegate;
    if (app.navigationCells != Nil) {
        [self initializeFromNav:app.navigationCells];
        app.navigationCells = Nil;
    }

  //  [self reloadCellsFromServer];
}



@end
