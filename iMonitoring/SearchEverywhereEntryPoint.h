//
//  SearchEverywhereEntryPoint.h
//  iMonitoring
//
//  Created by sébastien brugalières on 24/11/2013.
//
//

#import <UIKit/UIKit.h>
#import "AroundMeProtocols.h"

@interface SearchEverywhereEntryPoint : UITabBarController

@property (nonatomic) id<DisplayRegion> delegateRegion;

@end
