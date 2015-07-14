//
//  MailCellNeighborsRelationsWithDiffs.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 15/02/2015.
//
//

#import "MailCellNeighborsRelationsWithDiffs.h"
#import "HistoricalCellNeighborsData.h"
#import "NavCell.h"
#import "CellNeighbors2HTMLTable.h"

@interface MailCellNeighborsRelationsWithDiffs()

@property(nonatomic) HistoricalCellNeighborsData* theHistoricalNRs;

@end

@implementation MailCellNeighborsRelationsWithDiffs


-(instancetype) init:(HistoricalCellNeighborsData*) historicalCellNR {
    if (self = [super init]) {
        _theHistoricalNRs = historicalCellNR;
    }
    
    return self;
}

- (NSData*) buildNavigationData {
    return [NavCell buildNavigationDataForCell:self.theHistoricalNRs.currentNeighbors.centerCell];
}

- (NSString*) getMailTitle {
    return [NSString stringWithFormat:@"Neighbors delta for Cell %@ (%@)", self.theHistoricalNRs.currentNeighbors.centerCell.id, self.theHistoricalNRs.currentNeighbors.centerCell.techno];
}

- (NSString*) getAttachmentFileName {
    return [NSString stringWithFormat:@"%@.iMon", self.theHistoricalNRs.currentNeighbors.centerCell.id];
}


- (NSString*) buildSpecificBody {
    NSMutableString* HTMLheader = [[NSMutableString alloc] init];
    [HTMLheader appendFormat:@"%@",[self.theHistoricalNRs.currentNeighbors.centerCell cellInfoToHTML]];
    
    [HTMLheader appendFormat:@"%@", [CellNeighbors2HTMLTable exportCellNeighborsDatasource:self.theHistoricalNRs.currentNeighbors sectionTitle:@"Neighbors"]];
    
    NSArray* removedNRs = [self.theHistoricalNRs removedNRs:NeighborModeDistance];
    [HTMLheader appendFormat:@"%@", [CellNeighbors2HTMLTable exportCellNeighbors:removedNRs
                                                                    sectionTitle:[NSString stringWithFormat:@"Deleted neighbors (%lu)", (unsigned long)removedNRs.count]]];
    
    NSArray* addedNRs = [self.theHistoricalNRs addedNRs:NeighborModeDistance];
    [HTMLheader appendFormat:@"%@", [CellNeighbors2HTMLTable exportCellNeighbors:addedNRs
                                                                    sectionTitle:[NSString stringWithFormat:@"Added neighbors (%lu)", (unsigned long)addedNRs.count]]];
    return HTMLheader;
}

@end
