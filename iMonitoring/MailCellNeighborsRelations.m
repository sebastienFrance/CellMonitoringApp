//
//  MailCellNeighborsRelations.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 15/02/2015.
//
//

#import "MailCellNeighborsRelations.h"
#import "NeighborsDataSourceUtility.h"
#import "NavCell.h"
#import "CellNeighbors2HTMLTable.h"

@interface MailCellNeighborsRelations()

@property(nonatomic) NeighborsDataSourceUtility* theDatasource;

@end


@implementation MailCellNeighborsRelations

-(instancetype) init:(NeighborsDataSourceUtility*) dataSource {
    if (self = [super init]) {
        _theDatasource = dataSource;
    }
    
    return self;
    
}


- (NSData*) buildNavigationData {
    return [NavCell buildNavigationDataForCell:self.theDatasource.centerCell];
}

- (NSString*) getMailTitle {
    return [NSString stringWithFormat:@"Neighbors for Cell %@ (%@)", self.theDatasource.centerCell.id, self.theDatasource.centerCell.techno];
}

- (NSString*) getAttachmentFileName {
    return [NSString stringWithFormat:@"%@.iMon", self.theDatasource.centerCell.id];
}


- (NSString*) buildSpecificBody {
    NSMutableString* HTMLheader = [[NSMutableString alloc] init];
    [HTMLheader appendFormat:@"%@",[self.theDatasource.centerCell cellInfoToHTML]];
    
    [HTMLheader appendFormat:@"%@", [CellNeighbors2HTMLTable exportCellNeighborsDatasource:self.theDatasource sectionTitle:@"Neighbors"]];

    return HTMLheader;
}



@end
