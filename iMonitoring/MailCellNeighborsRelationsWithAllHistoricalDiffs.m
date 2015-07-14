//
//  MailCellNeighborsRelationsWithAllHistoricalDiffs.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 16/02/2015.
//
//

#import "MailCellNeighborsRelationsWithAllHistoricalDiffs.h"
#import "HistoricalCellNeighborsData.h"
#import "NavCell.h"
#import "CellNeighbors2HTMLTable.h"
#import "DateUtility.h"

@interface MailCellNeighborsRelationsWithAllHistoricalDiffs()

@property(nonatomic) NSArray* allHistoricalNRs;

@end

@implementation MailCellNeighborsRelationsWithAllHistoricalDiffs


-(instancetype) init:(NSArray*) theHistoricalNRs {
    if (self = [super init]) {
        _allHistoricalNRs = theHistoricalNRs;
    }
    
    return self;
}

- (NSData*) buildNavigationData {
    if ((self.allHistoricalNRs != Nil) && (self.allHistoricalNRs.count > 0)) {
        HistoricalCellNeighborsData* anHistoricalNRs = self.allHistoricalNRs[0];
        return [NavCell buildNavigationDataForCell:anHistoricalNRs.currentNeighbors.centerCell];
    } else {
        return Nil;
    }
}

- (NSString*) getMailTitle {
    if ((self.allHistoricalNRs != Nil) && (self.allHistoricalNRs.count > 0)) {
        HistoricalCellNeighborsData* anHistoricalNRs = self.allHistoricalNRs[0];
        return [NSString stringWithFormat:@"Neighbors history for Cell %@ (%@)", anHistoricalNRs.currentNeighbors.centerCell.id, anHistoricalNRs.currentNeighbors.centerCell.techno];
    } else {
        return @"No historical data";
    }
 }

- (NSString*) getAttachmentFileName {
    if ((self.allHistoricalNRs != Nil) && (self.allHistoricalNRs.count > 0)) {
        HistoricalCellNeighborsData* anHistoricalNRs = self.allHistoricalNRs[0];
        return [NSString stringWithFormat:@"%@.iMon", anHistoricalNRs.currentNeighbors.centerCell.id];
    } else {
        return Nil;
    }
}

- (NSString*) buildSpecificBody {
    NSMutableString* HTMLheader = [[NSMutableString alloc] init];
    HistoricalCellNeighborsData* anHistoricalNRs = self.allHistoricalNRs[0];
    [HTMLheader appendFormat:@"%@",[anHistoricalNRs.currentNeighbors.centerCell cellInfoToHTML]];
    
    [HTMLheader appendFormat:@"%@", [CellNeighbors2HTMLTable exportCellNeighborsHistorical:anHistoricalNRs]];

    
    for (HistoricalCellNeighborsData* currentHistoricalNRs in self.allHistoricalNRs) {
        
        NSArray* removedNRs = [currentHistoricalNRs removedNRs:NeighborModeDistance];
        [HTMLheader appendFormat:@"%@", [CellNeighbors2HTMLTable exportCellNeighbors:removedNRs
                                                                        sectionTitle:[NSString stringWithFormat:@"%lu Deleted neighbors (%@)",
                                                                                      (unsigned long)removedNRs.count,
                                                                                      [DateUtility getShortGMTDate:currentHistoricalNRs.currentDate]]]];
        
        NSArray* addedNRs = [currentHistoricalNRs addedNRs:NeighborModeDistance];
        [HTMLheader appendFormat:@"%@", [CellNeighbors2HTMLTable exportCellNeighbors:addedNRs
                                                                        sectionTitle:[NSString stringWithFormat:@"%lu Added neighbors (%@)",
                                                                                      (unsigned long)addedNRs.count,
                                                                                      [DateUtility getShortGMTDate:currentHistoricalNRs.currentDate]]]];
        
    }
    return HTMLheader;
}



@end
