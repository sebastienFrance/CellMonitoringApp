//
//  MarkedCellsViewController.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 28/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MarkedRegionsViewController.h"
#import "MarkedRegionTableViewCell.h"
#import "CellMonitoring.h"
#import "AroundMeViewController.h"
#import "RegionBookmark+MarkedRegion.h"
#import "DataCenter.h"

@interface MarkedRegionsViewController ()

@property NSMutableArray<RegionBookmark*>* bookmarkRegions;

@end

@implementation MarkedRegionsViewController
@synthesize theTable;

- (IBAction)segmentPushed:(UISegmentedControl *)sender {
    
    switch (sender.selectedSegmentIndex) {
        case 0: {
            // order by color
            [_bookmarkRegions sortUsingSelector:@selector(compareByColor:)];
            break;
        }
        case 1: {
            // order by date            
            [_bookmarkRegions sortUsingSelector:@selector(compareByDate:)];
            break;
        }
        case 2: {
            // order by Name
            [_bookmarkRegions sortUsingSelector:@selector(compareByName:)];
            break;
        }
        default: {
            NSLog(@"MarkedRegionsViewController::Error, unknown selected segment");
            break;
        }
    }
    [theTable reloadData];
    
    if (_bookmarkRegions.count > 0) {
        [theTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:TRUE];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray<RegionBookmark*> *bookmarks = [RegionBookmark loadBookmarks];
    _bookmarkRegions = [[NSMutableArray alloc] initWithArray:bookmarks];
    [_bookmarkRegions sortUsingSelector:@selector(compareByColor:)];
    
    theTable.delegate = self;
    theTable.dataSource = self;
    
    self.theTable.estimatedRowHeight = 59.0;
    self.theTable.rowHeight = UITableViewAutomaticDimension;

}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.navigationController setToolbarHidden:FALSE];
        self.navigationController.hidesBarsOnTap = FALSE;
    } else {
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _bookmarkRegions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MarkedRegionTableViewCellId";
    MarkedRegionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    RegionBookmark* currentRegion = _bookmarkRegions[indexPath.row];

    [cell initWithRegionBookmark:currentRegion];

    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<AroundMeViewItf> vc = [[DataCenter sharedInstance] aroundMeItf];
    RegionBookmark* theBookmarkRegion = _bookmarkRegions[indexPath.row];
    
    [vc initiliazeWithRegion:theBookmarkRegion];

    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.navigationController popViewControllerAnimated:TRUE];
    }
    
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


// Method called when the "Edit" button is pressed to delete or move a row from the table

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        RegionBookmark* bookmarkToRemove = self.bookmarkRegions[indexPath.row];
        [RegionBookmark remove:bookmarkToRemove];
        
        [self.bookmarkRegions removeObjectAtIndex:indexPath.row];
        
        [theTable beginUpdates];
        [theTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [theTable endUpdates];
    }   
}



@end
