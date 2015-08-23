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
    }
    
    return self;
}

@end
