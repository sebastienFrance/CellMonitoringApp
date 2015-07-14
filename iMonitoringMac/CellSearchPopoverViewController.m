//
//  CellSearchPopoverViewController.m
//  iMonitoring
//
//  Created by sébastien brugalières on 19/01/2014.
//
//

#import "CellSearchPopoverViewController.h"
#import "CellMonitoring.h"
#import "CellSearchViewCell.h"
#import "MainMapWindowController.h"
#import "AroundMeMapViewMgt.h"
#import "CellSearchAddressViewCell.h"

@interface CellSearchPopoverViewController ()
@property (weak) IBOutlet NSTableView *theTableView;

@property (nonatomic) NSString* address;
@property (nonatomic) NSArray* cells;

@end

@implementation CellSearchPopoverViewController


-(id) init {
    
    self = [super initWithNibName:@"CellSearchPopover" bundle:Nil];
    if (self) {
        // Initialization code here.
    }
    return self;
    
    
}

-(void) updateWith:(NSString*) address cells:(NSArray*)cells {
    self.address = address;
    self.cells = cells;
    
    NSLog(@"updateWith called %lu and %@", (unsigned long)cells.count, address);
    [self.theTableView reloadData];
    
}
- (IBAction)addressShowButtonPushed:(NSButton *)sender {
    [[MainMapWindowController sharedInstance] goToAddress:self.address];
}
- (IBAction)showButtonPushed:(NSButton *)sender {
    CellMonitoring* theCell = self.cells[sender.tag];
    [[MainMapWindowController sharedInstance] goToCell:theCell];
}

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (self.cells != Nil) {
        return (self.cells.count + 1);
    } else {
        return 0;
    }
}

// This method is optional if you use bindings to provide the data
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  
    // Group our "model" object, which is a dictionary
    
    // In IB the tableColumn has the identifier set to the same string as the keys in our dictionary
    NSString *identifier = [tableColumn identifier];
    
    if ([identifier isEqualToString:@"MainCell"]) {
        // We pass us as the owner so we can setup target/actions into this main controller object
        
        if (row == 0) {
            // Then setup properties on the cellView based on the column
            CellSearchAddressViewCell *cellView = [tableView makeViewWithIdentifier:@"CellAddress" owner:self];
            cellView.cellAddress.stringValue = self.address;
            return cellView;
        } else {
            CellSearchViewCell *cellView = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
            // Then setup properties on the cellView based on the column
            CellMonitoring* theCell = self.cells[(row -1)];
            cellView.cellName.stringValue = theCell.id;
            cellView.cellType.stringValue = theCell.techno;
            cellView.cellFrequency.stringValue = theCell.dlFrequency;
            cellView.cellRelease.stringValue = theCell.releaseName;
            [cellView.cellImage setImage:[theCell getPinImage]];
            cellView.cellButton.tag = (row -1);
            return cellView;
        }
        
        
        
    }
    
    return nil;
}


@end
