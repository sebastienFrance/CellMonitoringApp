//
//  NeighborsHistoricalDataSource.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 24/01/2015.
//
//

#import "NeighborsHistoricalDataSource.h"
#import "NeighborsDataSourceUtility.h"
#import "HistoricalCellNeighborsData.h"
#import "DateUtility.h"

@interface NeighborsHistoricalDataSource()

@property (nonatomic) CellMonitoring* centerCell;

@property (nonatomic, weak) id<NeighborsHistoricalLoadingItf> delegate;
@property (nonatomic) NSArray* theHistoricalData;

@end

@implementation NeighborsHistoricalDataSource

NSString *const kCellsWithNeighbors = @"CellsWithNeighbors";
NSString *const kDate = @"Date";

#pragma mark - HTMLDataResponse
- (void) connectionFailure:(NSString*) theClientId {
    NSLog(@"%s: Errror connection Failure", __PRETTY_FUNCTION__);
    [self.delegate neighborsHistoricalDataLoadingFailure];
}


- (void) dataReady:(id) theData clientId:(NSString*) theClientId {
    NSArray* data = theData;
    
    NSMutableArray* allHistoricalDataArray = [[NSMutableArray alloc] initWithCapacity:data.count];
    
    for (NSDictionary* NRData in data) {
        NSArray* neighborsAndTargetCells = NRData[kCellsWithNeighbors];
        if ((neighborsAndTargetCells != Nil) && (neighborsAndTargetCells.count > 0)) {
            NeighborsDataSourceUtility* currentNeighbors = [[NeighborsDataSourceUtility alloc] init:neighborsAndTargetCells centerCell:self.centerCell];
            
            NSString* currentDateString = NRData[kDate];
            NSDate* currentDate = [DateUtility getDateFromShortString:currentDateString];
            
            HistoricalCellNeighborsData* historicalNR = [[HistoricalCellNeighborsData alloc]
                                                         initWithDateAndNeighbors:currentDate
                                                         neighbors:currentNeighbors];
            [allHistoricalDataArray addObject:historicalNR];
        }
    }
    
    self.theHistoricalData = [allHistoricalDataArray sortedArrayUsingSelector:@selector(compareWithCurrentDate:)];
    for (NSUInteger i = 0; i < (self.theHistoricalData.count - 1); i++) {
        HistoricalCellNeighborsData* currentHistoricalNRs = self.theHistoricalData[i];
        HistoricalCellNeighborsData* previousHistoricalNRs = self.theHistoricalData[i+1];
        [currentHistoricalNRs buildDiffWithPrevious:previousHistoricalNRs];
    }
 
    [self.delegate neighborsHistoricalDataIsLoaded:Nil];
}

#pragma mark - Initialization

- (id) init:(id<NeighborsHistoricalLoadingItf>) delegate {
    
    if (self = [super init]) {
        _delegate = delegate;
    }
    
    return self;
    
}

#pragma mark - Request to download NRs

- (void) loadData:(CellMonitoring*) theCenterCell {
    _centerCell = theCenterCell;
    [RequestUtilities getCellWithNeighborsWithHistorical:self cell:self.centerCell clientId:@"CellNeighborsHistorical"];
}

@end
