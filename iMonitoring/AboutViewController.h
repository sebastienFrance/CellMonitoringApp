//
//  AboutViewController.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 14/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestUtilities.h"

@interface AboutViewController : UIViewController <HTMLDataResponse>
@property (weak, nonatomic) IBOutlet UILabel *LTECellNumber;
@property (weak, nonatomic) IBOutlet UILabel *LTENeighborsNumber;
@property (weak, nonatomic) IBOutlet UILabel *WCDMACellNumber;
@property (weak, nonatomic) IBOutlet UILabel *WCDMANeighborsNumber;
@property (weak, nonatomic) IBOutlet UILabel *GSMCellNumber;
@property (weak, nonatomic) IBOutlet UILabel *GSMNeighborsNumber;


@end
