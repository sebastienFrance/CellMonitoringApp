//
//  SimpleGraphicWindowController.h
//  iMonitoring
//
//  Created by sébastien brugalières on 02/01/2014.
//
//

#import <Cocoa/Cocoa.h>

@class MainMapWindowController;
@class WorstKPIDataSource;

@interface SimpleGraphicWindowController : NSWindowController

- (id)init:(MainMapWindowController*) theDelegate datasource:(WorstKPIDataSource*) lastWorstKPIs;


@end
