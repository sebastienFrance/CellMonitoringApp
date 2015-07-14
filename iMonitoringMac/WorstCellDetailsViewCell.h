//
//  WorstCellDetailsViewCell.h
//  iMonitoring
//
//  Created by sébastien brugalières on 18/01/2014.
//
//

#import <Cocoa/Cocoa.h>

@interface WorstCellDetailsViewCell : NSTableCellView

@property (nonatomic) IBOutlet NSTextField* cellName;
@property (nonatomic) IBOutlet NSButton* KPIsButton;
@property (nonatomic) IBOutlet NSButton* mapButton;

@end
