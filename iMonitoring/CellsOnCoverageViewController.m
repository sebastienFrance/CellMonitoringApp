//
//  CellsOnCoverageViewController.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 18/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CellsOnCoverageViewController.h"
#import "CellMonitoring.h"
#import "MapRefreshItf.h"
#import "CellGroupViewCell.h"

@interface CellsOnCoverageViewController ()


@property (nonatomic) NSMutableArray* filteredListContent;
@property (nonatomic) NSArray* theFullCellList;

@property (strong, nonatomic) UISearchController *searchController;
@property (weak, nonatomic) IBOutlet UITableView *theTableView;

@end

@implementation CellsOnCoverageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    
    [self initSearchController];

    self.theTableView.estimatedRowHeight = 88.0;
    self.theTableView.rowHeight = UITableViewAutomaticDimension;
    
    
    // cells by alphabetical order
    self.theFullCellList = [[self.delegate getCellsFromMap] sortedArrayUsingComparator:^(CellMonitoring* cell1, CellMonitoring* cell2) {
        return  [cell1 compareByName:cell2];
    }];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // to avoid bug when the cell is not automatically resized on first display
    [self.theTableView reloadData];
}

-(void) initSearchController {
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = TRUE;
    
    self.searchController.searchBar.scopeButtonTitles = @[@"All", @"LTE", @"WCDMA", @"GSM"];
    self.searchController.searchBar.placeholder = @"Cell name or Site name (:siteId)";
    self.searchController.searchBar.delegate = self;
    
    self.theTableView.tableHeaderView = self.searchController.searchBar;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.definesPresentationContext = FALSE;
        [self.searchController.searchBar sizeToFit];
    } else {
        self.definesPresentationContext = TRUE;
    }

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

//-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 77.0;
//}
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return @"Cells on map";
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchController.active) {
        return self.filteredListContent.count;
    } else {
        return self.theFullCellList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        static NSString *CellIdentifier = @"CellGroupId";
    CellGroupViewCell *cell = [self.theTableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    CellMonitoring* currentCell = [self getCurrentCell:tableView index:indexPath];
    [cell initializeWithCell:currentCell index:indexPath.row];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CellMonitoring* selectedCell = [self getCurrentCell:tableView index:indexPath];
    
    [self.navigationController popViewControllerAnimated:TRUE];
    
    [self.delegate showSelectedCellOnMap:selectedCell];
}

-(CellMonitoring*) getCurrentCell:(UITableView*) theTableView index:(NSIndexPath*) indexPath {
    if (self.searchController.active) {
        return self.filteredListContent[indexPath.row];
    } else {
        return self.theFullCellList[indexPath.row];
    }
}

#pragma mark - UISearchResultsUpdating protocol
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    
    NSArray* scopeButton = searchController.searchBar.scopeButtonTitles;
    NSUInteger selectedScope = searchController.searchBar.selectedScopeButtonIndex;
    [self filterContentForSearchText:searchString scope:scopeButton[selectedScope]];

    [self.theTableView reloadData];
}

#pragma mark - UISearchBarDelegate protocol

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self updateSearchResultsForSearchController:self.searchController];
}

#pragma mark - Utility method for filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    self.filteredListContent = [[NSMutableArray alloc] init];
	
	// Search cells matching the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
    Boolean searchCellId = TRUE;
    
    // When text start with ':' we want to search using siteId instead of cell.id
    if (searchText != Nil && searchText.length > 1) {
        if ([searchText characterAtIndex:0] == ':') {
            searchText = [searchText substringFromIndex:1];
            searchCellId = FALSE;
        }
    }
    
    for (CellMonitoring *cell in self.theFullCellList) {
		if ([scope isEqualToString:@"All"] || [cell.techno isEqualToString:scope]) {
            NSString* cellParam = searchCellId ? cell.id : cell.siteId;
            
            NSComparisonResult result = [cellParam compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, searchText.length)];
            if (result == NSOrderedSame) {
                [self.filteredListContent addObject:cell];
            }
		}
	}
}


@end
