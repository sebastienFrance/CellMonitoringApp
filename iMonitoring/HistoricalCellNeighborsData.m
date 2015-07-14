//
//  HistoricalCellNeighborsData.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 27/01/2015.
//
//

#import "HistoricalCellNeighborsData.h"
#import "NeighborOverlay.h"
#import "DateUtility.h"
#import "BasicTypes.h"

@interface HistoricalCellNeighborsData()

@property(nonatomic) NeighborsDataSourceUtility* currentNeighbors;
@property(nonatomic) HistoricalCellNeighborsData* previousNeighbors;
@property(nonatomic) NSDate* currentDate;

@property(nonatomic) NSDictionary* removedNRsPerType;
@property(nonatomic) NSDictionary* addedNRsPerType;

@end

@implementation HistoricalCellNeighborsData

-(instancetype) initWithDateAndNeighbors:(NSDate*) date neighbors:(NeighborsDataSourceUtility*) theNeighbors {
    if (self = [super init]) {
        _currentDate = date;
        _currentNeighbors = theNeighbors;
        _removedNRsPerType = @{};
        _addedNRsPerType = @{};
    }
    
    return self;
}

- (NSComparisonResult) compareWithCurrentDate:(HistoricalCellNeighborsData *)otherObject {
    return [otherObject.currentDate compare:self.currentDate];
}

-(void) buildDiffWithPrevious:(HistoricalCellNeighborsData*) previousHistoricalNRs {
    self.previousNeighbors = previousHistoricalNRs;

    NSDictionary* currentNRs = self.currentNeighbors.allNeighorsByTargetCell;
    NSDictionary* previousNRs = self.previousNeighbors.currentNeighbors.allNeighorsByTargetCell;

    [self buildAddedNRs:currentNRs previous:previousNRs];
    [self buildRemovedNRs:currentNRs previous:previousNRs];
}

-(void) buildAddedNRs:(NSDictionary*) currentNRs previous:(NSDictionary*) previousNRs {

    NSMutableArray* theAddedIntraFreqNRs = [[NSMutableArray alloc] init];
    NSMutableArray* theAddedInterFreqNRs = [[NSMutableArray alloc] init];
    NSMutableArray* theAddedInterRATNRs = [[NSMutableArray alloc] init];
    NSMutableArray* theAddedMeasuredByANR = [[NSMutableArray alloc] init];

    NSMutableArray* theAllAddedNRs = [[NSMutableArray alloc] init];

    NSArray* allCurrentTargetCells = currentNRs.allKeys;
   
    for (NSString* currentTargetCell in allCurrentTargetCells) {
        NeighborOverlay* oldNeighbor = previousNRs[currentTargetCell];
        NeighborOverlay* addedNeighbor = currentNRs[currentTargetCell];

        // If the NR doesn't exist in previous data it's a new one
        if (oldNeighbor == Nil) {
            switch (addedNeighbor.NRType) {
                case NRInterFreq: {
                    [theAddedInterFreqNRs addObject:addedNeighbor];
                    break;
                }
                case NRIntraFreq: {
                    [theAddedIntraFreqNRs addObject:addedNeighbor];
                    break;
                }
                case NRInterRAT: {
                    [theAddedInterRATNRs addObject:addedNeighbor];
                    break;
                }
                default: {
                    NSLog(@"%s: unknown NRType for added NR", __PRETTY_FUNCTION__);
                    continue;
                }
            }

            if (addedNeighbor.measuredbyANR == TRUE) {
                [theAddedMeasuredByANR addObject:addedNeighbor];
            }


            [theAllAddedNRs addObject:addedNeighbor];
        }
    }

    self.addedNRsPerType = @{@(NeighborModeInterFreq) : [theAddedInterFreqNRs sortedArrayUsingSelector:@selector(compareDistance:)],
                               @(NeighborModeIntraFreq) : [theAddedIntraFreqNRs sortedArrayUsingSelector:@selector(compareDistance:)],
                               @(NeighborModeInterRAT)  : [theAddedInterRATNRs sortedArrayUsingSelector:@selector(compareDistance:)],
                               @(NeighborModeByANR)     : [theAddedMeasuredByANR sortedArrayUsingSelector:@selector(compareDistance:)],
                               @(NeighborModeDistance)  : [theAllAddedNRs sortedArrayUsingSelector:@selector(compareDistance:)]};
}

-(void) buildRemovedNRs:(NSDictionary*) currentNRs previous:(NSDictionary*) previousNRs {


    NSMutableArray* theRemovedIntraFreqNRs = [[NSMutableArray alloc] init];
    NSMutableArray* theRemovedInterFreqNRs = [[NSMutableArray alloc] init];
    NSMutableArray* theRemovedInterRATNRs = [[NSMutableArray alloc] init];
    NSMutableArray* theRemovedMeasuredByANR = [[NSMutableArray alloc] init];

    NSMutableArray* theAllRemovedNRs = [[NSMutableArray alloc] init];

    NSArray* allPreviousCells = previousNRs.allKeys;

    for (NSString* previousTargetCell in allPreviousCells) {
        NeighborOverlay* currentNeighbor = currentNRs[previousTargetCell];
        NeighborOverlay* removedNeighbor = previousNRs[previousTargetCell];

        // if the NR doesn't exist in the current data it means it has been removed
        if (currentNeighbor == Nil) {
            switch (removedNeighbor.NRType) {
                case NRInterFreq: {
                    [theRemovedInterFreqNRs addObject:removedNeighbor];
                    break;
                }
                case NRIntraFreq: {
                    [theRemovedIntraFreqNRs addObject:removedNeighbor];
                    break;
                }
                case NRInterRAT: {
                    [theRemovedInterRATNRs addObject:removedNeighbor];
                    break;
                }
                default: {
                    NSLog(@"%s: unknown NRType for removed NR", __PRETTY_FUNCTION__);
                    continue;
                }
            }

            if (currentNeighbor.measuredbyANR == TRUE) {
                [theRemovedMeasuredByANR addObject:removedNeighbor];
            }

            [theAllRemovedNRs addObject:removedNeighbor];
        }
    }


    self.removedNRsPerType = @{@(NeighborModeInterFreq) : [theRemovedInterFreqNRs sortedArrayUsingSelector:@selector(compareDistance:)],
                               @(NeighborModeIntraFreq) : [theRemovedIntraFreqNRs sortedArrayUsingSelector:@selector(compareDistance:)],
                               @(NeighborModeInterRAT)  : [theRemovedInterRATNRs sortedArrayUsingSelector:@selector(compareDistance:)],
                               @(NeighborModeByANR)     : [theRemovedMeasuredByANR sortedArrayUsingSelector:@selector(compareDistance:)],
                               @(NeighborModeDistance)  : [theAllRemovedNRs sortedArrayUsingSelector:@selector(compareDistance:)]};

}

-(NSArray*) removedNRs:(NeighborModeChoiceId) theMode {
    return self.removedNRsPerType[@(theMode)];
}

-(NSArray*) addedNRs:(NeighborModeChoiceId) theMode {
    return self.addedNRsPerType[@(theMode)];
}

@end
