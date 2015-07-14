//
//  CellGroupPopoverViewCell.h
//  iMonitoring
//
//  Created by sébastien brugalières on 22/12/2013.
//
//

#import <Cocoa/Cocoa.h>

@interface CellGroupPopoverViewCell : NSTableCellView

@property (nonatomic) IBOutlet NSButton* cellShowButton;
@property (nonatomic) IBOutlet NSTextField* cellSite;
@property (nonatomic) IBOutlet NSTextField* cellReleaseName;

@end
