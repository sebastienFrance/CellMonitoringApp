//
//  MailCellParametersWithDiffs.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 19/03/2015.
//
//

#import "MailCellParametersWithDiffs.h"
#import "NavCell.h"
#import "HistoricalParameters.h"
#import "CellMonitoring.h"
#import "DateUtility.h"
#import "CellParameters2HTMLTable.h"

@interface MailCellParametersWithDiffs()

@property (nonatomic) HistoricalParameters* cellParametersDifferences;
@property (nonatomic) CellMonitoring* theCell;

@end

@implementation MailCellParametersWithDiffs


-(instancetype) init:(HistoricalParameters*) cellHistorical cell:(CellMonitoring*) sourceCell {
    if (self = [super init]) {
        self.cellParametersDifferences = cellHistorical;
        self.theCell = sourceCell;
    }
    
    return self;
}

- (NSData*) buildNavigationData {
    return [NavCell buildNavigationDataForCell:self.theCell];
}

- (NSString*) getMailTitle {
    return [NSString stringWithFormat:@"Parameter history for cell %@ (%@)", self.theCell.id, [DateUtility getSimpleLocalizedDate:self.cellParametersDifferences.theDate]];
}

- (NSString*) getAttachmentFileName {
    return [NSString stringWithFormat:@"%@.iMon", self.theCell.id];
}


- (NSString*) buildSpecificBody {
    NSMutableString* HTMLheader = [[NSMutableString alloc] init];
    [HTMLheader appendFormat:@"%@",self.theCell.cellShortInfoToHTML];
    
    [HTMLheader appendFormat:@"%@", [CellParameters2HTMLTable exportFullParameterHistorical:self.cellParametersDifferences sectionTitle:@"Differences"]];
    
    return HTMLheader;
}

@end
