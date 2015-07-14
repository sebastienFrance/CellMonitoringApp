//
//  ExtendedTableView.h
//  iMonitoring
//
//  Created by sébastien brugalières on 09/01/2014.
//
//

#import <Cocoa/Cocoa.h>
@class ExtendedTableView;

@protocol ExtendedTableViewDelegate <NSObject>

-(void) selected:(ExtendedTableView*) tableview row:(NSUInteger) theRow column:(NSUInteger) theColumn;

@end


@interface ExtendedTableView : NSTableView

-(void) setExtendedDelegate:(id <ExtendedTableViewDelegate>) extendedDelegate;

@end
