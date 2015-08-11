//
//  LocateCellTableViewController.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 19/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocateCellTableViewController.h"
#import "CellMonitoring.h"
#import "RequestUtilities.h"
#import "MBProgressHUD.h"
#import "SearchAddressViewCell.h"
#import "CellGroupViewCell.h"
#import "LocateCellDataSource.h"
#import "Utility.h"

@interface LocateCellTableViewController ()

@property (nonatomic) NSMutableArray* filteredListContent;
@property (nonatomic) LocateCellDataSource* theDatasource;

@property (strong, nonatomic) UISearchController *searchController;
@property (weak, nonatomic) IBOutlet UITableView *theTableView;

@end

@implementation LocateCellTableViewController

NSString *const SCOPE_ALL       = @"All";
NSString *const SCOPE_LTE       = @"LTE";
NSString *const SCOPE_WCDMA     = @"WCDMA";
NSString *const SCOPE_GSM       = @"GSM";
NSString *const SCOPE_ADDRESS   = @"Address";

#pragma mark - LocateCellDelegate protocol
-(void) cellStartingWithResponse:(NSMutableArray*) cells error:(NSError*) theError {
    if (theError != Nil) {
        UIAlertController* alert = [Utility getSimpleAlertView:@"Communication Error"
                                                       message:@"Cannot collect data from server."
                                                   actionTitle:@"OK"];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    self.filteredListContent = cells;    
    [self.filteredListContent sortUsingComparator:^(CellMonitoring* cell1, CellMonitoring* cell2) {
        return [cell1 compareByName:cell2];
    }];
    
    NSString* scope = [self getSelectedScope];
    
    // Display the address in the first row in case scope is "All" or "Address"
    if ([scope isEqualToString:SCOPE_ALL] || [scope isEqualToString:SCOPE_ADDRESS]) {
        [self.filteredListContent insertObject:self.searchController.searchBar.text atIndex:0];
    }
    
    [self.theTableView reloadData];
}


#pragma mark - initialization
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;

    
    self.theDatasource = [[LocateCellDataSource alloc] initWithCellDelegate:self];

    self.filteredListContent = [[NSMutableArray alloc] init];

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    self.searchController.searchBar.placeholder = @"Cell name";
    self.searchController.searchBar.scopeButtonTitles = @[SCOPE_ALL, SCOPE_LTE, SCOPE_WCDMA, SCOPE_GSM, SCOPE_ADDRESS];
    self.searchController.searchBar.delegate = self;
    
    self.theTableView.tableHeaderView = self.searchController.searchBar;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.definesPresentationContext = FALSE;
        [self.searchController.searchBar sizeToFit];
    } else {
        self.definesPresentationContext = TRUE;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        NSString* scope = [self getSelectedScope];

        // If the scope is "All" or "Address" and index is 0 then the row contains only the address and not a Cell
        if ([scope isEqualToString:SCOPE_ALL] || [scope isEqualToString:SCOPE_ADDRESS]) {
            return 54.0;
        }
    }
    return 77.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchController.active ? self.filteredListContent.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        NSString* scope = [self getSelectedScope];
        
        // If the scope is "All" or "Address" and index is 0 then the row contains only the address and not a Cell
        if ([scope isEqualToString:SCOPE_ALL] || [scope isEqualToString:SCOPE_ADDRESS]) {
            
            static NSString *searchIdentifier = @"AddressCellId";
            SearchAddressViewCell *cell = [self.theTableView dequeueReusableCellWithIdentifier:searchIdentifier forIndexPath:indexPath];
            
            cell.theAddress.text = self.filteredListContent[indexPath.row];
            return cell;
        }
    }

    static NSString *CellIdentifier = @"CellGroupId";
    CellGroupViewCell *cell = [self.theTableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    CellMonitoring* currentCell = self.filteredListContent[indexPath.row];
    
    [cell initializeWithCell:currentCell index:indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[self.view endEditing:YES];
    
    if (indexPath.row == 0) {
        NSString* scope = [self getSelectedScope];
        
        if ([scope isEqualToString:SCOPE_ALL] || [scope isEqualToString:SCOPE_ADDRESS]) {
            [self performReverseGeoCoding:self.filteredListContent[indexPath.row]];
        } else {
            [self showRegionForCell:self.filteredListContent[indexPath.row]];
        }
    } else {
        [self showRegionForCell:self.filteredListContent[indexPath.row]];
    }
}

#pragma mark - UISearchResultsUpdating protocol
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString* scope = [self getSelectedScope];
    
    if ([SCOPE_ADDRESS isEqualToString:scope]) {
        // just add the address and reload the table view
        [self.filteredListContent removeAllObjects]; // First clear the filtered array.
        [self.filteredListContent insertObject:self.searchController.searchBar.text atIndex:0];
        
        // return true to reload the table
        [self.theTableView reloadData];
    } else {
        NSString *searchString = searchController.searchBar.text;
        [self filterContentForSearchText:searchString scope:scope];
    }
}


#pragma mark - UISearchBarDelegate protocol

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self updateSearchResultsForSearchController:self.searchController];
}

#pragma mark - Utilities
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    
    if ([searchText isEqualToString:@""] == FALSE) {
        [self.theDatasource requestCellStartingWith:searchText technology:scope maxResults:50];
        
        // Fill the address row while loading from server
        if ([scope isEqualToString:SCOPE_ALL] || [scope isEqualToString:SCOPE_ADDRESS]) {
            self.filteredListContent = [[NSMutableArray alloc] init];
            [self.filteredListContent addObject:self.searchController.searchBar.text];
            [self.theTableView reloadData];
        }
    }
}

-(NSString*) getSelectedScope {
    return [self.searchController.searchBar scopeButtonTitles][[self.searchController.searchBar selectedScopeButtonIndex]];
}

-(void) performReverseGeoCoding:(NSString*) address {
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = [NSString stringWithFormat:@"Looking for %@", address];
    
    MKMapView* currentMap = [self.delegate getMapView];
    CLCircularRegion* aroundRegion = [[CLCircularRegion alloc] initWithCenter:currentMap.region.center
                                                                       radius:100000.0
                                                                   identifier:@"AreaRegion"];
    
    
    CLGeocoder* reverseGeoCoder = [[CLGeocoder alloc] init];
    [reverseGeoCoder geocodeAddressString:address inRegion:aroundRegion completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error){
            NSLog(@"Geocode failed with error: %@", error);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            UIAlertController* alert = [Utility getSimpleAlertView:@"Error"
                                                           message:@"Cannot find the location."
                                                       actionTitle:@"OK"];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        CLPlacemark* currentPlacemark = [placemarks lastObject];
        CLLocation *location = currentPlacemark.location;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            [self.navigationController popViewControllerAnimated:TRUE];
        }
        [self.delegate showRegionFromAddress:location.coordinate address:address];
    }];
}

-(void) showRegionForCell:(CellMonitoring*) theCell {
    CLLocationCoordinate2D newCoordinate = [theCell coordinate];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.navigationController popViewControllerAnimated:TRUE];
    }
    [self.delegate showRegionFromSelectedCell:newCoordinate withSelectedCell:theCell.id];
}



@end
