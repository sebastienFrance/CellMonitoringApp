//
//  NeighborsLocateViewController.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 19/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "NeighborsLocateViewController.h"
#import "CellMonitoring.h"
#import "NeighborOverlay.h"
#import "NeighborsDataSourceUtility.h"
#import "NeighborsLocateViewCell.h"
#import "AroundMeProtocols.h"
#import "HistoricalCellNeighborsData.h"
#import "Utility.h"
#import "DateUtility.h"
#import "MailCellNeighborsRelations.h"
#import "MailCellNeighborsRelationsWithDiffs.h"

typedef NS_ENUM(NSUInteger, NeighborDisplayModeId) {
    NeighborDisplayModeNormal = 0,
    NeighborDisplayModeHistorical = 1,
};


@interface NeighborsLocateViewController ()

@property (nonatomic) NeighborsDataSourceUtility* dataSource;
@property (nonatomic) id<DisplayRegion> delegate;

@property (nonatomic) HistoricalCellNeighborsData* historicalCellNR;

@property(nonatomic) NeighborDisplayModeId displayMode;

@property (weak, nonatomic) IBOutlet UITableView *theTable;
@property (weak, nonatomic) IBOutlet UISegmentedControl *selectOrdering;


@end

@implementation NeighborsLocateViewController

-(void) initiliazeWith:(NeighborsDataSourceUtility*) theDatasource delegate:(id<DisplayRegion>) theDelegate {
    self.dataSource = theDatasource;
    self.delegate = theDelegate;
    self.displayMode = NeighborDisplayModeNormal;
}

-(void) initializeWith:(HistoricalCellNeighborsData*) theHistoricalCellNR {
    self.historicalCellNR = theHistoricalCellNR;
    self.displayMode = NeighborDisplayModeHistorical;
}


- (IBAction)orderDistanceHasChanged:(UISegmentedControl *)sender {
    [self.theTable reloadData];
    
    if ([self.theTable numberOfRowsInSection:0] > 0) {
        [self.theTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                             atScrollPosition:UITableViewScrollPositionTop
                                     animated:TRUE];
    }
}

- (IBAction)sendMail:(UIBarButtonItem *)sender {
    
    MailAbstract* theMail = Nil;
    if (self.displayMode == NeighborDisplayModeNormal) {
        theMail = [[MailCellNeighborsRelations alloc] init:self.dataSource];
    } else {
        theMail = [[MailCellNeighborsRelationsWithDiffs alloc] init:self.historicalCellNR];
    }
    
    [theMail presentActivityViewFrom:self];

}


- (void)viewDidLoad {
    self.theTable.delegate = self;
    self.theTable.dataSource = self;

    self.theTable.estimatedRowHeight = 114.0;
    self.theTable.rowHeight = UITableViewAutomaticDimension;



    if (self.displayMode == NeighborDisplayModeNormal) {
        [self initializeSegmentForNormalMode];
    } else {
        [self initializeSegmentForHistoricalMode];
    }
    
    // Do any additional setup after loading the view.
    [super viewDidLoad];
}


-(void) initializeSegmentForHistoricalMode {
    self.title = [NSString stringWithFormat:@"%@ (%@)",
                  self.historicalCellNR.currentNeighbors.centerCell.id,
                  [DateUtility getShortGMTDate:self.historicalCellNR.currentDate]];
    
    if (([self.historicalCellNR addedNRs:NeighborModeIntraFreq].count == 0) && ([self.historicalCellNR removedNRs:NeighborModeIntraFreq].count == 0)) {
        [self.selectOrdering setEnabled:FALSE forSegmentAtIndex:NeighborModeIntraFreq];
    }
    
    if (([self.historicalCellNR addedNRs:NeighborModeInterFreq].count == 0) && ([self.historicalCellNR removedNRs:NeighborModeInterFreq].count == 0)) {
        [self.selectOrdering setEnabled:FALSE forSegmentAtIndex:NeighborModeInterFreq];
    }
    
    if (([self.historicalCellNR addedNRs:NeighborModeInterRAT].count == 0) && ([self.historicalCellNR removedNRs:NeighborModeInterRAT].count == 0)) {
        [self.selectOrdering setEnabled:FALSE forSegmentAtIndex:NeighborModeInterRAT];
    }
    
    if (([self.historicalCellNR addedNRs:NeighborModeByANR].count == 0) && ([self.historicalCellNR removedNRs:NeighborModeByANR].count == 0)) {
        [self.selectOrdering setEnabled:FALSE forSegmentAtIndex:NeighborModeByANR];
    }
}

-(void) initializeSegmentForNormalMode {
    if (self.dataSource == Nil) {
        self.title = @"No data";
        return;
    }
    self.title = [NSString stringWithFormat:@"%@", self.dataSource.centerCell.id];

    if (self.dataSource.neighborsIntraFreq.count == 0) {
        [self.selectOrdering setEnabled:FALSE forSegmentAtIndex:NeighborModeIntraFreq];
    }
    
    if (self.dataSource.neighborsInterFreq.count == 0) {
        [self.selectOrdering setEnabled:FALSE forSegmentAtIndex:NeighborModeInterFreq];
    }
    
    if (self.dataSource.neighborsInterRAT.count == 0) {
        [self.selectOrdering setEnabled:FALSE forSegmentAtIndex:NeighborModeInterRAT];
    }
    
    if (self.dataSource.neighborsByANR.count == 0) {
        [self.selectOrdering setEnabled:FALSE forSegmentAtIndex:NeighborModeByANR];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    switch (self.displayMode) {
        case NeighborDisplayModeNormal: {
            if (self.selectOrdering.selectedSegmentIndex == NeighborModeInterFreq) {
                return self.dataSource.neighborsByInterFreq.count;
            } else {
                return 1;
            }
        }
        case NeighborDisplayModeHistorical: {
            return 1;
        }
        default: {
            NSLog(@"%s warning, unknown display mode", __PRETTY_FUNCTION__);
            return 0;
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (self.displayMode) {
        case NeighborDisplayModeNormal: {
            if (self.selectOrdering.selectedSegmentIndex == NeighborModeInterFreq) {
                NSUInteger i = 0;
                for (NSString* dlFrequency in self.dataSource.neighborsByInterFreq) {
                    if (i == section) {
                        float normalizedFreq = [Utility computeNormalizedDLFrequency:dlFrequency];
                        return [NSString stringWithFormat:@"Frequency : %@", [Utility displayLongDLFrequency:normalizedFreq earfcn:dlFrequency]];
                    } else {
                        i++;
                    }
                }
            }
            return Nil;
        }
        case NeighborDisplayModeHistorical: {
            return Nil;
        }
        default: {
            NSLog(@"%s warning, unknown display mode", __PRETTY_FUNCTION__);
            return Nil;
        }
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.displayMode == NeighborDisplayModeNormal) {
        return [self getNumberOfRowsInSectionForNormalMode:section];
    } else {
        return [self.historicalCellNR addedNRs:self.selectOrdering.selectedSegmentIndex].count +
        [self.historicalCellNR removedNRs:self.selectOrdering.selectedSegmentIndex].count;
    }
}

-(NSInteger) getNumberOfRowsInSectionForNormalMode:(NSInteger) section {
    switch (self.selectOrdering.selectedSegmentIndex) {
        case NeighborModeDistance: {
            return self.dataSource.neighborsOverlays.count;
        }
        case NeighborModeIntraFreq: {
            return self.dataSource.neighborsIntraFreq.count;
        }
        case NeighborModeInterFreq: {
            NSArray* neighborsFreq = [self getInterFreqNeighborsForSection:section];
            return neighborsFreq.count;
        }
        case NeighborModeInterRAT: {
            return self.dataSource.neighborsInterRAT.count;
        }
        case NeighborModeByANR: {
            return self.dataSource.neighborsByANR.count;
        }
        default: {
            return 0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NeighborCellId";
    NeighborsLocateViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    if (self.displayMode == NeighborDisplayModeNormal) {
        NeighborOverlay* currentNeighbor = [self getSelectedNeighbor:indexPath];
        [cell initializeWith:currentNeighbor];
    } else {
        if (indexPath.row < [self.historicalCellNR addedNRs:self.selectOrdering.selectedSegmentIndex].count) {
            NeighborOverlay* currentNeighbor = [self.historicalCellNR addedNRs:self.selectOrdering.selectedSegmentIndex][indexPath.row];
            [cell initializeWith:currentNeighbor addedNeighbor:TRUE];
        } else {
            NSUInteger index = indexPath.row - [self.historicalCellNR addedNRs:self.selectOrdering.selectedSegmentIndex].count;
            NeighborOverlay* currentNeighbor = [self.historicalCellNR removedNRs:self.selectOrdering.selectedSegmentIndex][index];
            [cell initializeWith:currentNeighbor addedNeighbor:FALSE];
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NeighborOverlay* neighbor = [self getSelectedNeighbor:indexPath];
    
    // We can display the neighbor only when the target is known and we have the delegate
    if ((neighbor.targetCell != Nil) && (self.delegate != Nil)) {
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            [self.navigationController popToRootViewControllerAnimated:TRUE];
        }
        [self.delegate showNeighborInRegion:neighbor];
    }
}

#pragma mark - Utilities

- (NeighborOverlay*) getSelectedNeighbor:(NSIndexPath*) indexPath {
    
    if (self.displayMode == NeighborDisplayModeNormal) {
        switch (self.selectOrdering.selectedSegmentIndex) {
            case NeighborModeDistance: {
                return (self.dataSource.neighborsOverlays)[indexPath.row];
            }
            case NeighborModeIntraFreq: {
                return (self.dataSource.neighborsIntraFreq)[indexPath.row];
            }
            case NeighborModeInterFreq: {
                NSArray* neighborsFreq = [self getInterFreqNeighborsForSection:indexPath.section];
                return neighborsFreq[indexPath.row];
            }
            case NeighborModeInterRAT: {
                return (self.dataSource.neighborsInterRAT)[indexPath.row];
            }
            case NeighborModeByANR: {
                return (self.dataSource.neighborsByANR)[indexPath.row];
            }
            default: {
                return Nil;
            }
                
        }
    } else {
        if (indexPath.row < [self.historicalCellNR addedNRs:self.selectOrdering.selectedSegmentIndex].count) {
            return [self.historicalCellNR addedNRs:self.selectOrdering.selectedSegmentIndex][indexPath.row];
        } else {
            NSUInteger index = indexPath.row - [self.historicalCellNR addedNRs:self.selectOrdering.selectedSegmentIndex].count;
            return  [self.historicalCellNR removedNRs:self.selectOrdering.selectedSegmentIndex][index];
        }
    }
}

- (NSArray*) getInterFreqNeighborsForSection:(NSUInteger) section {

    NSUInteger i = 0;
    for (NSArray* neighborFreq in [self.dataSource.neighborsByInterFreq objectEnumerator]) {
        if (i == section) {
            return neighborFreq;
        } else {
            i++;
        }
    }
    return Nil;

}

#pragma mark - KNPathTableViewController customization
- (UITableView*) tableView {
    return self.theTable;
}

-(void)infoPanelDidScroll:(UIScrollView *)scrollView atPoint:(CGPoint)point {
    NSIndexPath * indexPath = [self.theTable indexPathForRowAtPoint:point];
    
    NeighborOverlay* currentNeighbor = [self getSelectedNeighbor:indexPath];
    self.infoLabel.text = currentNeighbor.distance;
 }

- (float) maxWidthInfoLabel {
    float maxWidth = 0.0;
    
    if (self.displayMode == NeighborDisplayModeNormal) {
        maxWidth = [self computeMaxWidthForNormalMode];
    } else {
        maxWidth = [self computeMaxWidthForHistoricalMode];
    }
    
    
    return ceil(maxWidth);
}

-(float) computeMaxWidthForNormalMode {
    float maxWidth = 0.0;
    UIFont* theFont = [UIFont boldSystemFontOfSize:12];
    NSDictionary* myDico = @{NSFontAttributeName : theFont};
    CGSize initSize = CGSizeMake(10.0, 2.0);

    for (NeighborOverlay* currentNeighbor in self.dataSource.neighborsOverlays) {
        
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:currentNeighbor.distance attributes:myDico];
        
        NSStringDrawingContext* drawingContext = [[NSStringDrawingContext alloc] init];
        
        CGRect rect = [attrString boundingRectWithSize:initSize options:NSStringDrawingUsesDeviceMetrics context:drawingContext];
        
        maxWidth = rect.size.width > maxWidth ? rect.size.width : maxWidth;
        
    }
    
    return maxWidth;

}


-(float) computeMaxWidthForHistoricalMode {
    float maxWidth = 0.0;
    UIFont* theFont = [UIFont boldSystemFontOfSize:12];
    NSDictionary* myDico = @{NSFontAttributeName : theFont};
    CGSize initSize = CGSizeMake(10.0, 2.0);
    
    for (NeighborOverlay* currentNeighbor in [self.historicalCellNR removedNRs:NeighborModeDistance]) {
        
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:currentNeighbor.distance attributes:myDico];
        
        NSStringDrawingContext* drawingContext = [[NSStringDrawingContext alloc] init];
        
        CGRect rect = [attrString boundingRectWithSize:initSize options:NSStringDrawingUsesDeviceMetrics context:drawingContext];
        
        maxWidth = rect.size.width > maxWidth ? rect.size.width : maxWidth;
        
    }
    
    for (NeighborOverlay* currentNeighbor in [self.historicalCellNR addedNRs:NeighborModeDistance]) {
        
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:currentNeighbor.distance attributes:myDico];
        
        NSStringDrawingContext* drawingContext = [[NSStringDrawingContext alloc] init];
        
        CGRect rect = [attrString boundingRectWithSize:initSize options:NSStringDrawingUsesDeviceMetrics context:drawingContext];
        
        maxWidth = rect.size.width > maxWidth ? rect.size.width : maxWidth;
        
    }

    
    return maxWidth;
    
}


@end
