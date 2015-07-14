//
//  ZoneKPIsEntryPointViewController.h
//  iMonitoring
//
//  Created by sébastien brugalières on 23/11/2013.
//
//

#import <UIKit/UIKit.h>
#import "RequestUtilities.h"
#import "DetailsWorstKPIsViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "DataCenter.h"
#import "WorstKPIDataSource.h"


@interface ZoneKPIsEntryPointViewController : UITabBarController<WorstKPIDataLoadingItf>

- (void) initialize:(NSArray*) cells techno:(DCTechnologyId) theTechno centerCoordinate:(CLLocationCoordinate2D) coordinate;
- (void) initialize:(WorstKPIDataSource*) latestWorstKPIs;


@end
