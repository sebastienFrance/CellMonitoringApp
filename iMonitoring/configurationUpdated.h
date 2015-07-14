//
//  configurationUpdated.h
//  iMonitoring
//
//  Created by sébastien brugalières on 17/12/2013.
//
//

#import <Foundation/Foundation.h>
#import "MapModeItf.h"

@protocol configurationUpdated

@property (nonatomic, readonly) MapModeEnabled currentMapMode;

- (void) updateConfiguration;

@end