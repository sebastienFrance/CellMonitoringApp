//
//  MarkedCellsViewController.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 28/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MarkedCellsViewController.h"
#import "MarkedTableViewCell.h"
#import "CellMonitoring.h"
#import "AroundMeViewController.h"
#import "AroundMeViewMgt.h"
#import "DataCenter.h"
#import "CellBookmark+MarkedCell.h"

@interface MarkedCellsViewController ()

@property (strong) NSMutableArray* cells;

@end

@implementation MarkedCellsViewController
@synthesize theTable;

- (IBAction)segmentPushed:(UISegmentedControl *)sender {
    
    switch (sender.selectedSegmentIndex) {
        case 0: {
            // order by color
            [self.cells sortUsingSelector:@selector(compareByColor:)];
            break;
        }
        case 1: {
            // order by date            
            [self.cells sortUsingSelector:@selector(compareByDate:)];
            break;
        }
        case 2: {
            // order by Name
            [self.cells sortUsingSelector:@selector(compareByName:)];
            break;
        }
        case 3: {
            // order by Technology
            [self.cells sortUsingSelector:@selector(compareByTechnology:)];
            break;
        }
        default: {
            NSLog(@"%s Error, unknown selected segment", __PRETTY_FUNCTION__);
            break;
        }
    }
    [theTable reloadData];
    
    // protect again empty tables!
    if (self.cells.count > 0) {
        [theTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:TRUE];
    }

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:YES animated:YES];
    [super viewWillAppear:animated];

    self.cells = [[CellBookmark loadBookmarks] mutableCopy];
    [self.cells sortUsingSelector:@selector(compareByColor:)];
    
    [theTable reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.cells = [[CellBookmark loadBookmarks] mutableCopy];
    [self.cells sortUsingSelector:@selector(compareByColor:)];
    
    theTable.delegate = self;
    theTable.dataSource = self;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MarkedTableViewCellId";
    MarkedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [cell initialiazeWithCellBookmark:self.cells[indexPath.row]];
    
    return cell;
    
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


// Method called when the "Edit" button is pressed to delete or move a row from the table

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        CellBookmark* cellToRemove = self.cells[indexPath.row];
        
        
        [self.cells removeObjectAtIndex:indexPath.row];
        [CellBookmark remove:cellToRemove];
        
        [theTable beginUpdates];
        [theTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [theTable endUpdates];
    }   
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) { 
        [self.navigationController popViewControllerAnimated:TRUE];
    } else {
        // it's the iPad
        [self dismissViewControllerAnimated:TRUE completion:Nil];
    }
    id<AroundMeViewItf> vc = [[DataCenter sharedInstance] aroundMeItf];
    CellBookmark* theCell = self.cells[indexPath.row];
    CLLocationCoordinate2D newCoordinate = [theCell theCellCoordinate];
    [vc.viewMgt showRegionFromSelectedCell:newCoordinate withSelectedCell:theCell.cellInternalName];

}


@end
