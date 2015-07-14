//
//  MailCellNeighborsRelations.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 15/02/2015.
//
//

#import "MailAbstract.h"

@class NeighborsDataSourceUtility;

@interface MailCellNeighborsRelations : MailAbstract

-(instancetype) init:(NeighborsDataSourceUtility*) dataSource;


@end
