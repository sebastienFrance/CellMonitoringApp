//
//  MapPreferencesController.h
//  iMonitoring
//
//  Created by sébastien brugalières on 16/12/2013.
//
//

#import <Foundation/Foundation.h>
#import "configurationUpdated.h"

@interface MapPreferencesController : NSWindowController

@property (nonatomic, weak) id<configurationUpdated> delegate;

@end
