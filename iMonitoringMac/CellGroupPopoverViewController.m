//
//  CellGroupPopoverViewController.m
//  iMonitoring
//
//  Created by sébastien brugalières on 21/12/2013.
//
//

#import "CellGroupPopoverViewController.h"
#import "CellMonitoringGroup.h"
#import "CellMonitoring.h"
#import "CellGroupPopoverViewCell.h"
#import "CellDetailsWindowController.h"

@interface CellGroupPopoverViewController ()
@property (weak) IBOutlet NSTableView *theTableView;

@property(nonatomic) NSMutableArray* allCells;


@end

@implementation CellGroupPopoverViewController


- (void)loadView {
    [super loadView];
    
    NSLog(@"loadView");
}


-(id) initWithCellGroup:(CellMonitoringGroup*) cellGroup {

    self = [super initWithNibName:@"CellGroupPopover" bundle:Nil];
    if (self) {
        // Initialization code here.
    }
    
    NSMutableArray* theAllCells = [[NSMutableArray alloc] initWithArray:cellGroup.filteredCells];
    
    [theAllCells sortUsingSelector:@selector(compareByName:)];
    
    _allCells = theAllCells;
    
    return self;


}

- (IBAction)showCellButtonPushed:(NSButton *)sender {
    
    CellMonitoring* theCell = self.allCells[sender.tag];
    
    [[MainMapWindowController sharedInstance] showDetailsOfCell:theCell];
}


#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.allCells.count;
}

// This method is optional if you use bindings to provide the data
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // Group our "model" object, which is a dictionary
    
    // In IB the tableColumn has the identifier set to the same string as the keys in our dictionary
    NSString *identifier = [tableColumn identifier];
    
    if ([identifier isEqualToString:@"MainCell"]) {
        // We pass us as the owner so we can setup target/actions into this main controller object
        CellGroupPopoverViewCell *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        // Then setup properties on the cellView based on the column
        CellMonitoring* theCell = self.allCells[row];
        cellView.textField.stringValue = theCell.id;
        [cellView.imageView setImage:[theCell getPinImage]];
        cellView.cellReleaseName.stringValue = theCell.releaseName;
        cellView.cellSite.stringValue = theCell.site;
        
        cellView.cellShowButton.tag = row;
        
        return cellView;
    } else if ([identifier isEqualToString:@"CellTechnology"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        // Then setup properties on the cellView based on the column
        CellMonitoring* theCell = self.allCells[row];
        cellView.textField.stringValue = theCell.techno;
        return cellView;
    }
    return nil;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    return self.allCells[rowIndex];
}

- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    [self.allCells sortUsingDescriptors:[tableView sortDescriptors]];
    [tableView reloadData];
}

@end
