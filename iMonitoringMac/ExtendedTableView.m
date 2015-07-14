//
//  ExtendedTableView.m
//  iMonitoring
//
//  Created by sébastien brugalières on 09/01/2014.
//
//

#import "ExtendedTableView.h"

@interface ExtendedTableView()

@property(nonatomic, weak) id<ExtendedTableViewDelegate> theDelegate;

@end


@implementation ExtendedTableView


-(void) setExtendedDelegate:(id<ExtendedTableViewDelegate>)extendedDelegate {
    self.theDelegate = extendedDelegate;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    
    NSPoint globalLocation = [theEvent locationInWindow];
    NSPoint localLocation = [self convertPoint:globalLocation fromView:nil];
    
    NSInteger clickedCol = [self columnAtPoint:localLocation];
    NSInteger clickedRow = [self rowAtPoint:localLocation];
    
    [self.theDelegate selected:self row:clickedRow column:clickedCol];
    
    [super mouseDown:theEvent];
}


@end
