//
//  DaboardSelectionPopoverViewCell.h
//  iMonitoring
//
//  Created by sébastien brugalières on 19/01/2014.
//
//

#import <Cocoa/Cocoa.h>

@interface DaboardSelectionPopoverViewCell : NSTableCellView

@property (weak) IBOutlet NSTextField* cellTechnology;
@property (weak) IBOutlet NSImageView* cellImage;
@property (weak) IBOutlet NSButton* cellButton;


@end
