//
//  DataCenter.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 13/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataCenter.h"


@implementation DataCenter


+(DataCenter*)sharedInstance
{
    static dispatch_once_t pred;
    static DataCenter *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[DataCenter alloc] init];
    });
    return sharedInstance;
}

- (id)init{
    if (self = [super init] ) {

        _isAppStarting = TRUE;
        _isDemoSession = FALSE;
    }
    
    return self;
}


- (void) startDemoSessionWithTimer {
    _isDemoSession = TRUE;
    [NSTimer scheduledTimerWithTimeInterval:(300) target:self selector:@selector(timerFireMethod:) userInfo:Nil repeats:FALSE];
}

- (void) timerFireMethod:(NSTimer *)timer {
    
    [self.aroundMeItf stopDemoSession];
    
}


- (void) dealloc {
    // implement -dealloc & remove abort() when refactoring for
    // non-singleton use.
    abort();
}




@end
