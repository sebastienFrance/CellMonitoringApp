//
//  DashboardSelectionPopoverViewController.m
//  iMonitoring
//
//  Created by sébastien brugalières on 19/01/2014.
//
//

#import "DashboardSelectionPopoverViewController.h"
#import "cellDataSource.h"
#import "DaboardSelectionPopoverViewCell.h"
#import "BasicTypes.h"
#import "MainMapWindowController.h"

@interface DashboardSelectionPopoverViewController ()

@property (nonatomic) NSArray* stringValues;
@property (nonatomic) NSArray* technologies;

@end

@implementation DashboardSelectionPopoverViewController

-(id) init:(cellDataSource*) datasource {
    
    self = [super initWithNibName:@"DashboardSelectionPopover" bundle:Nil];
    
    if (self) {
        NSMutableArray* rows = [[NSMutableArray alloc] init];
        NSMutableArray* techno = [[NSMutableArray alloc] init];
        
        NSUInteger cellCount = [datasource getFilteredCellCountForTechnoId:DCTechnologyLTE];
        if (cellCount > 0) {
            NSString* content = [NSString stringWithFormat:@"%@ (%lu)", [BasicTypes getTechnoName:DCTechnologyLTE], (unsigned long)cellCount];
            [rows addObject:content];
            NSNumber* theTechno = [NSNumber numberWithInteger:DCTechnologyLTE];
            [techno addObject:theTechno];
        }

        cellCount = [datasource getFilteredCellCountForTechnoId:DCTechnologyWCDMA];
        if (cellCount > 0) {
            NSString* content = [NSString stringWithFormat:@"%@ (%lu)", [BasicTypes getTechnoName:DCTechnologyWCDMA], (unsigned long)cellCount];
            [rows addObject:content];
            NSNumber* theTechno = [NSNumber numberWithInteger:DCTechnologyWCDMA];
            [techno addObject:theTechno];
        }

        cellCount = [datasource getFilteredCellCountForTechnoId:DCTechnologyGSM];
        if (cellCount > 0) {
            NSString* content = [NSString stringWithFormat:@"%@ (%lu)", [BasicTypes getTechnoName:DCTechnologyGSM], (unsigned long)cellCount];
            [rows addObject:content];
            NSNumber* theTechno = [NSNumber numberWithInteger:DCTechnologyGSM];
            [techno addObject:theTechno];
        }
        _stringValues = rows;
        _technologies = techno;
        
    }
    return self;
    
    
}
- (IBAction)showButtonPushed:(NSButton *)sender {
    NSNumber* technoNumber = self.technologies[sender.tag];
    DCTechnologyId theTechno = [technoNumber unsignedIntegerValue];
    
    [[MainMapWindowController sharedInstance] openDashboardView:theTechno];
}


#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.stringValues.count;
}

// This method is optional if you use bindings to provide the data
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    // Group our "model" object, which is a dictionary
    
    // In IB the tableColumn has the identifier set to the same string as the keys in our dictionary
    NSString *identifier = [tableColumn identifier];
    
    if ([identifier isEqualToString:@"MainCell"]) {
        // We pass us as the owner so we can setup target/actions into this main controller object
        DaboardSelectionPopoverViewCell *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        
        cellView.cellTechnology.stringValue = self.stringValues[row];
        cellView.cellButton.tag = row;
        
        NSNumber* technoNumber = self.technologies[row];
        DCTechnologyId theTechno = [technoNumber unsignedIntegerValue];
        
        cellView.cellImage.image = [self getPinImage:theTechno];
                
        return cellView;
    }
    
    return nil;
}

#if TARGET_OS_IPHONE
- (UIImage*) getPinImage:(DCTechnologyId) theTechnology {
#else
    - (NSImage*) getPinImage:(DCTechnologyId) theTechnology {
#endif
        
        switch (theTechnology) {
            case DCTechnologyLTE: {
                return [DashboardSelectionPopoverViewController getImage:@"8_purple.png"];
            }
            case DCTechnologyWCDMA: {
                return [DashboardSelectionPopoverViewController getImage:@"8_teal.png"];
            }
            case DCTechnologyGSM: {
                return [DashboardSelectionPopoverViewController getImage:@"8_yellow.png"];
            }
            default: {
                return Nil;
            }
        }
    }
    
#if TARGET_OS_IPHONE
    + (UIImage*) getImage:(NSString*) imageName {
        UIImage * image = [UIImage imageNamed:imageName];
        return image;
    }
#else
    + (NSImage*) getImage:(NSString*) imageName {
        NSImage * image = [NSImage imageNamed:[imageName stringByDeletingPathExtension]];
        return image;
    }
#endif


@end
