//
//  ZoneWindowController.m
//  iMonitoring
//
//  Created by sébastien brugalières on 30/12/2013.
//
//

#import "ZoneWindowController.h"
#import "Zone.h"
#import "BasicTypes.h"
#import "MainMapWindowController.h"

@interface ZoneWindowController ()

@property (nonatomic) ZonesDatasSource* datasource;
@property (weak) IBOutlet NSTableView *zoneTableView;

@property (nonatomic, weak) MainMapWindowController* delegate;

@end

@implementation ZoneWindowController

- (id)init:( MainMapWindowController*) theDelegate
{
    self = [super initWithWindowNibName:@"ZonesWindow"];
    _delegate = theDelegate;
    
    return self;
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.window setLevel:NSStatusWindowLevel];
  
    self.datasource = [[ZonesDatasSource alloc] init:self];
    [self.datasource downloadZones];
}

#pragma mark - ZonesDatasSourceDelegate protocol
-(void) zonesResponse:(NSError*) theError {
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (theError != Nil) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Failure" message:@"Cannot get Object & Working Zones" delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
//        [alert show];
    } else {
        NSLog(@"Zone loaded successfully");
        [self.zoneTableView reloadData];
    }
}


#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  
    return self.datasource.listOfAllZones.count;
}

// This method is optional if you use bindings to provide the data
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // Group our "model" object, which is a dictionary
    
    // In IB the tableColumn has the identifier set to the same string as the keys in our dictionary
    NSString *identifier = [tableColumn identifier];
    Zone* currentZone = self.datasource.listOfAllZones[row];
   
    if ([identifier isEqualToString:@"ZoneTechnology"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        // Then setup properties on the cellView based on the column
        cellView.textField.stringValue = [BasicTypes getTechnoName:currentZone.techno];
        return cellView;
    } else if ([identifier isEqualToString:@"ZoneType"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        cellView.textField.stringValue = [BasicTypes getZoneName:currentZone.type];
        return cellView;
    } else if ([identifier isEqualToString:@"ZoneName"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        cellView.textField.stringValue = currentZone.name;
        return cellView;
    } else if ([identifier isEqualToString:@"ZoneDescription"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        cellView.textField.stringValue = currentZone.description;
        return cellView;
    }

    return nil;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
//    NSLog(@"Column Selected with Row %ld", (long)[self.theTableView selectedRow]);
  //  [self.delegate showSelectedCellOnMap:self.cellsOnMap[[self.theTableView selectedRow]]];
    
    Zone* currentZone = self.datasource.listOfAllZones[[self.zoneTableView selectedRow]];
    [self.delegate initiliazeWithZone:currentZone.name];

    
}


@end
