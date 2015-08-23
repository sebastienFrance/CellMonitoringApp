//
//  AroundMeImpl.m
//  iMonitoring
//
//  Created by sébastien brugalières on 24/03/13.
//
//

#import "AroundMeImpl.h"
#import "MBProgressHUD.h"
#import "DataCenter.h"
#import "iMonitoring.h"
#import "AroundMeViewController.h"

@implementation AroundMeImpl

#pragma mark - Constructor

- (id)init:(BasicAroundMeViewController*) theViewController {
    self = [super init:theViewController];
    return self;
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
