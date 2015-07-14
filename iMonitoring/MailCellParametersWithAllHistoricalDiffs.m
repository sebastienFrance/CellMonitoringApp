//
//  MailCellParametersWithAllHistoricalDiffs.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 20/03/2015.
//
//

#import "MailCellParametersWithAllHistoricalDiffs.h"
#import "NavCell.h"
#import "HistoricalParameters.h"
#import "CellMonitoring.h"
#import "DateUtility.h"
#import "CellParameters2HTMLTable.h"

@interface MailCellParametersWithAllHistoricalDiffs()

@property (nonatomic) NSArray* historicalData;
@property (nonatomic) CellMonitoring* theCell;

@end

@implementation MailCellParametersWithAllHistoricalDiffs

-(instancetype) init:(NSArray*) allHistorical cell:(CellMonitoring*) sourceCell {
    if (self = [super init]) {
        self.historicalData = allHistorical;
        self.theCell = sourceCell;
    }
    
    return self;
}

- (NSData*) buildNavigationData {
    return [NavCell buildNavigationDataForCell:self.theCell];
}

- (NSString*) getMailTitle {
    return [NSString stringWithFormat:@"Parameter history for cell %@", self.theCell.id];
}

- (NSString*) getAttachmentFileName {
    return [NSString stringWithFormat:@"%@.iMon", self.theCell.id];
}


- (NSString*) buildSpecificBody {
    NSMutableString* HTMLheader = [[NSMutableString alloc] init];
    [HTMLheader appendFormat:@"%@",self.theCell.cellShortInfoToHTML];
    
    Boolean firstRow = TRUE;
    for (HistoricalParameters* currentHistorical in self.historicalData) {
        if (firstRow == TRUE) {
            firstRow = FALSE;
            [HTMLheader appendString:[CellParameters2HTMLTable cellParametersToHTML:currentHistorical.theParameters]];
        }
        
        [HTMLheader appendString:[CellParameters2HTMLTable exportDiffOnlyForParameterHistorical:currentHistorical sectionTitle:@"Diff"]];
    }
    return HTMLheader;
}


@end
