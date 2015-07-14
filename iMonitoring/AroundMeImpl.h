//
//  AroundMeImpl.h
//  iMonitoring
//
//  Created by sébastien brugalières on 24/03/13.
//
//

#import <Foundation/Foundation.h>
#import "BasicAroundMeImpl.h"
#import "BasicAroundMeViewController.h"

@interface AroundMeImpl : BasicAroundMeImpl


- (id)init:(BasicAroundMeViewController*) theViewController;
- (void) loadViewContent;

@end
