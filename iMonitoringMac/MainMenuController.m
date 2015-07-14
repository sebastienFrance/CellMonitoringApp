//
//  MainMenuController.m
//  iMonitoring
//
//  Created by sébastien brugalières on 19/01/2014.
//
//

#import "MainMenuController.h"
#import "MainMapWindowController.h"

@implementation MainMenuController

- (IBAction)cellsOnCoverage:(id)pId {
    [[MainMapWindowController sharedInstance] displayCellsOnCoverage];
}


- (IBAction)zones:(id)pId {
    [[MainMapWindowController sharedInstance] displayZones];
}
- (IBAction)LocateCellOnTheRoad:(id)pId {
    [[MainMapWindowController sharedInstance] displayRoute];
}

@end
