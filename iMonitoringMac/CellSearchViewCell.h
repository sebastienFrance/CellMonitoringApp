//
//  CellSearchViewCell.h
//  iMonitoring
//
//  Created by sébastien brugalières on 19/01/2014.
//
//

#import <Cocoa/Cocoa.h>

@interface CellSearchViewCell : NSTableCellView

@property (weak) IBOutlet NSTextField* cellName;
@property (weak) IBOutlet NSTextField* cellType;
@property (weak) IBOutlet NSImageView* cellImage;
@property (weak) IBOutlet NSButton* cellButton;
@property (weak) IBOutlet NSTextField* cellFrequency;
@property (weak) IBOutlet NSTextField* cellRelease;

@end
