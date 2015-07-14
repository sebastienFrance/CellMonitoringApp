//
//  WindowForPopover.h
//  iMonitoring
//
//  Created by sébastien brugalières on 19/01/2014.
//
//

#import <Cocoa/Cocoa.h>

@protocol LIPopoverFirstResponderStealingSuppression <NSObject>
@property (readonly, nonatomic) BOOL suppressFirstResponderWhenPopoverShows;
@end


@interface WindowForPopover : NSWindow

@end
