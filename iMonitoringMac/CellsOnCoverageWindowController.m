//
//  CellsOnCoverageWindowController.m
//  iMonitoring
//
//  Created by sébastien brugalières on 27/12/2013.
//
//

#import "CellsOnCoverageWindowController.h"
#import "CellMonitoring.h"

@interface CellsOnCoverageWindowController ()

@property (nonatomic) NSMutableArray* cellsOnMap;
@property (weak) IBOutlet NSTableView *theTableView;

@property (weak) IBOutlet NSTextField *LTECells;
@property (weak) IBOutlet NSTextField *LTEIntraFreqNRs;
@property (weak) IBOutlet NSTextField *LTEInterFReqNRs;
@property (weak) IBOutlet NSTextField *LTEInterRATNRs;

@property (weak) IBOutlet NSTextField *WCDMACells;
@property (weak) IBOutlet NSTextField *WCDMAIntraFreqNRs;
@property (weak) IBOutlet NSTextField *WCDMAInterFReqNRs;
@property (weak) IBOutlet NSTextField *WCDMAInterRATNRs;

@property (weak) IBOutlet NSTextField *GSMCells;
@property (weak) IBOutlet NSTextField *GSMIntraFreqNRs;
@property (weak) IBOutlet NSTextField *GSMInterFReqNRs;
@property (weak) IBOutlet NSTextField *GSMInterRATNRs;


@end

@implementation CellsOnCoverageWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.window setLevel:NSStatusWindowLevel];
    
    [self initializeCounters];
    
    [self refreshContent];
}

- (void) initializeCounters {
    NSUInteger LTECellsCounters = 0;
    NSUInteger LTEIntraFreqNRsCounters = 0;
    NSUInteger LTEInterFReqNRsCounters = 0;
    NSUInteger LTEInterRATNRsCounters = 0;
    
    NSUInteger WCDMACellsCounters = 0;
    NSUInteger WCDMAIntraFreqNRsCounters = 0;
    NSUInteger WCDMAInterFReqNRsCounters = 0;
    NSUInteger WCDMAInterRATNRsCounters = 0;
    
    NSUInteger GSMCellsCounters = 0;
    NSUInteger GSMIntraFreqNRsCounters = 0;
    NSUInteger GSMInterFReqNRsCounters = 0;
    NSUInteger GSMInterRATNRsCounters = 0;
    
    for (CellMonitoring* theCell in self.cellsOnMap) {
        switch (theCell.cellTechnology) {
            case DCTechnologyLTE: {
                LTECellsCounters++;
                LTEIntraFreqNRsCounters += theCell.numberIntraFreqNR;
                LTEInterFReqNRsCounters += theCell.numberInterFreqNR;
                LTEInterRATNRsCounters += theCell.numberInterRATNR;
                break;
            }
            case DCTechnologyWCDMA: {
                WCDMACellsCounters++;
                WCDMAIntraFreqNRsCounters += theCell.numberIntraFreqNR;
                WCDMAInterFReqNRsCounters += theCell.numberInterFreqNR;
                WCDMAInterRATNRsCounters += theCell.numberInterRATNR;
                break;
            }
            case DCTechnologyGSM: {
                GSMCellsCounters++;
                GSMIntraFreqNRsCounters += theCell.numberIntraFreqNR;
                GSMInterFReqNRsCounters += theCell.numberInterFreqNR;
                GSMInterRATNRsCounters += theCell.numberInterRATNR;
                break;
            }
            default:
                break;
        }
    }
    
    self.LTECells.stringValue = [NSString stringWithFormat:@"%lu", LTECellsCounters];
    self.LTEIntraFreqNRs.stringValue = [NSString stringWithFormat:@"%lu", LTEIntraFreqNRsCounters];
    self.LTEInterFReqNRs.stringValue = [NSString stringWithFormat:@"%lu", LTEInterFReqNRsCounters];
    self.LTEInterRATNRs.stringValue = [NSString stringWithFormat:@"%lu", LTEInterRATNRsCounters];

    self.WCDMACells.stringValue = [NSString stringWithFormat:@"%lu", WCDMACellsCounters];
    self.WCDMAIntraFreqNRs.stringValue = [NSString stringWithFormat:@"%lu", WCDMAIntraFreqNRsCounters];
    self.WCDMAInterFReqNRs.stringValue = [NSString stringWithFormat:@"%lu", WCDMAInterFReqNRsCounters];
    self.WCDMAInterRATNRs.stringValue = [NSString stringWithFormat:@"%lu", WCDMAInterRATNRsCounters];

    self.GSMCells.stringValue = [NSString stringWithFormat:@"%lu", GSMCellsCounters];
    self.GSMIntraFreqNRs.stringValue = [NSString stringWithFormat:@"%lu", GSMIntraFreqNRsCounters];
    self.GSMInterFReqNRs.stringValue = [NSString stringWithFormat:@"%lu", GSMInterFReqNRsCounters];
    self.GSMInterRATNRs.stringValue = [NSString stringWithFormat:@"%lu", GSMInterRATNRsCounters];

}

-(void) refreshContent {
    self.cellsOnMap = [[NSMutableArray alloc] initWithArray:[self.delegate getCellsFromMap]];
    [self initializeCounters];
    [self.theTableView reloadData];
}

- (id)init
{
    self = [super initWithWindowNibName:@"CellsOnCoverageWindow"];
    
    return self;
}

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.cellsOnMap.count;
}

// This method is optional if you use bindings to provide the data
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // Group our "model" object, which is a dictionary
    
    // In IB the tableColumn has the identifier set to the same string as the keys in our dictionary
    NSString *identifier = [tableColumn identifier];
    
    if ([identifier isEqualToString:@"CellName"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        // Then setup properties on the cellView based on the column
        CellMonitoring* theCell = self.cellsOnMap[row];
        cellView.textField.stringValue = theCell.id;
        return cellView;
    } else if ([identifier isEqualToString:@"CellTechnology"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        // Then setup properties on the cellView based on the column
        CellMonitoring* theCell = self.cellsOnMap[row];
        cellView.textField.stringValue = theCell.techno;
        return cellView;
    } else if ([identifier isEqualToString:@"CellRelease"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        // Then setup properties on the cellView based on the column
        CellMonitoring* theCell = self.cellsOnMap[row];
        cellView.textField.stringValue = theCell.releaseName;
        return cellView;
    } else if ([identifier isEqualToString:@"CellFrequency"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        // Then setup properties on the cellView based on the column
        CellMonitoring* theCell = self.cellsOnMap[row];
        cellView.textField.stringValue = theCell.dlFrequency;
        return cellView;
    } else if ([identifier isEqualToString:@"CellAzimuth"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        // Then setup properties on the cellView based on the column
        CellMonitoring* theCell = self.cellsOnMap[row];
        cellView.textField.stringValue = theCell.azimuth;
        return cellView;
    } else if ([identifier isEqualToString:@"CellIntraFreq"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        // Then setup properties on the cellView based on the column
        CellMonitoring* theCell = self.cellsOnMap[row];
        cellView.textField.integerValue = theCell.numberIntraFreqNR;
        return cellView;
    } else if ([identifier isEqualToString:@"CellInterFreq"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        // Then setup properties on the cellView based on the column
        CellMonitoring* theCell = self.cellsOnMap[row];
        cellView.textField.integerValue = theCell.numberInterFreqNR;
        return cellView;
    } else if ([identifier isEqualToString:@"CellInterRAT"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        // Then setup properties on the cellView based on the column
        CellMonitoring* theCell = self.cellsOnMap[row];
        cellView.textField.integerValue = theCell.numberInterRATNR;
        return cellView;
    } else if ([identifier isEqualToString:@"CellLatitude"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        // Then setup properties on the cellView based on the column
        CellMonitoring* theCell = self.cellsOnMap[row];
        cellView.textField.floatValue = theCell.coordinate.latitude;
        return cellView;
    } else if ([identifier isEqualToString:@"CellLongitude"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        // Then setup properties on the cellView based on the column
        CellMonitoring* theCell = self.cellsOnMap[row];
        cellView.textField.floatValue = theCell.coordinate.longitude;
        return cellView;
    }
    return nil;
}

//- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn {
//    NSLog(@"Column Selected with Row %ld", (long)[tableView clickedRow]);
//    
//}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    NSLog(@"Column Selected with Row %ld", (long)[self.theTableView selectedRow]);
    [self.delegate showSelectedCellOnMap:self.cellsOnMap[[self.theTableView selectedRow]]];
    
}

#warning MAC add table sorting
//- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
//    return self.allCells[rowIndex];
//}
//
//- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
//{
//    [self.allCells sortUsingDescriptors:[tableView sortDescriptors]];
//    [tableView reloadData];
//}


@end
