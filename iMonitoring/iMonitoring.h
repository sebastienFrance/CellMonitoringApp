//
//  iMonitoring.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 19/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "NavCell.h"

@interface iMonitoring : UIResponder <UIApplicationDelegate, NSStreamDelegate> {
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) NSArray* navigationCells;

@property (copy, nonatomic) void (^completionHandler)();

@end
