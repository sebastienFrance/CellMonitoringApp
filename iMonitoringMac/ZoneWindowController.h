//
//  ZoneWindowController.h
//  iMonitoring
//
//  Created by sébastien brugalières on 30/12/2013.
//
//

#import <Cocoa/Cocoa.h>
#import "ZonesDatasSource.h"

@class MainMapWindowController;

@interface ZoneWindowController : NSWindowController<ZonesDatasSourceDelegate>

- (id)init:(MainMapWindowController*) theDelegate;


@end
