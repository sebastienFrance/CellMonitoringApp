//
//  WindowForPopover.m
//  iMonitoring
//
//  Created by sébastien brugalières on 19/01/2014.
//
//

#import "WindowForPopover.h"

@interface WindowForPopover ()

@end

@implementation WindowForPopover

- (BOOL)makeFirstResponder:(NSResponder *)responder;
{
    NSLog(@"makeFirstResponder called");
    
    // Prevent popover content view from forcing our current first responder to resign
    if (responder != self.firstResponder && [responder isKindOfClass:[NSView class]]) {
        NSWindow *const newFirstResponderWindow = ((NSView *)responder).window;
        NSWindow *currentFirstResponderWindow;
        
        NSResponder *const currentFirstResponder = self.firstResponder;
        if ([currentFirstResponder isKindOfClass:[NSWindow class]])
            currentFirstResponderWindow = (id)currentFirstResponder;
        else if ([currentFirstResponder isKindOfClass:[NSView class]])
            currentFirstResponderWindow = ((NSView *)currentFirstResponder).window;
        
        // Prevent some view in popover from stealing our first responder, but allow the user to explicitly activate it with a click on the popover.
        // Note that the current first responder may be in a child window, if it's a control in the "thick titlebar" area and we're currently full-screen.
        if (newFirstResponderWindow != self && newFirstResponderWindow != currentFirstResponderWindow && self.currentEvent.window != newFirstResponderWindow)
            for (NSView *responderView = (id)responder; responderView; responderView = responderView.superview)
                if ([responderView conformsToProtocol:@protocol(LIPopoverFirstResponderStealingSuppression)] &&
                    ((id <LIPopoverFirstResponderStealingSuppression>)responderView).suppressFirstResponderWhenPopoverShows)
                    return NO;
    }
    
    return [super makeFirstResponder:responder];
}


@end
