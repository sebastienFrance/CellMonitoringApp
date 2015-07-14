//
//  SiteImageDetailsViewController.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 22/02/2015.
//
//

#import <UIKit/UIKit.h>
#import "HTMLRequest.h"

@class CellMonitoring;

@interface SiteImageDetailsViewController : UIViewController<HTMLDataResponse, UIScrollViewDelegate>

-(void) initializeWithImageName:(NSString*) imageName cell:(CellMonitoring*) theCell;

@end
