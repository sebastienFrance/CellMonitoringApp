//
//  MarkViewController.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 20/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AroundMeProtocols.h"

@protocol MarkedCell;

@class CellMonitoring;

@interface MarkViewController : UIViewController

#pragma mark - Public Properties
@property (nonatomic) Boolean bookmark;
@property (nonatomic, weak) id<MarkedCell> delegate;
@property (nonatomic) CellMonitoring* theCell;

- (void) theInitialText:(NSString*) text;



@end

