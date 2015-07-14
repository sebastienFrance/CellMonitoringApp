//
//  BasicAroundMeImpl.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 22/11/2014.
//
//

#import <Foundation/Foundation.h>
#import "AroundMeViewItf.h"
#import "AroundMeMapViewDelegate.h"
#import "MapDelegateItf.h"
#import "BasicAroundMeViewController.h"

@class AroundMeViewController;

@interface BasicAroundMeImpl : NSObject <MapDelegateItf, AroundMeViewItf, CellDataSourceDelegate>

@property (nonatomic) RouteInformation* lastRoute;
@property (nonatomic) MKRoute* lastDirection;

- (id)init:(BasicAroundMeViewController*) theViewController;
- (void) loadViewContent;
- (void) showNavigationDataOnMap;


- (void) connectionCompleted;


// only used by iPad
- (void) dismissAllPopovers;

@end
