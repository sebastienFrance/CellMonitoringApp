//
//  SearchViewPopover.m
//  iMonitoring
//
//  Created by sébastien brugalières on 19/01/2014.
//
//

#import "SearchViewPopover.h"

@implementation SearchViewPopover

-(BOOL) suppressFirstResponderWhenPopoverShows {
    return TRUE;
}



- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

@end
