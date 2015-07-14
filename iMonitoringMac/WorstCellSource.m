//
//  WorstCellSource.m
//  iMonitoring
//
//  Created by sébastien brugalières on 12/01/2014.
//
//

#import "WorstCellSource.h"
#import "WorstKPIDataSource.h"

@interface WorstCellSource()

@property (nonatomic) WorstKPIDataSource* datasource;

@property (nonatomic) NSDictionary* sourceKPIs;

@property(nonatomic) NSUInteger indexOfCurrentKPI;

@end

@implementation WorstCellSource

- (id) init:(WorstKPIDataSource*) theDatasource initialIndex:(NSUInteger) index isAverage:(Boolean) isAverageKPIs{
    
    if (self = [super init]) {
        _datasource = theDatasource;
        _indexOfCurrentKPI = index;
        
        if (isAverageKPIs == FALSE) {
            _sourceKPIs = self.datasource.KPIs;
        } else {
            _sourceKPIs = self.datasource.worstAverageKPIs;
        }
        
    }
    
    return self;
}


#pragma mark - WorstKPIItf protocol
- (void) goToIndex:(NSUInteger) index {
    self.indexOfCurrentKPI = index;
}

- (NSArray*) getKPIValues {
    NSEnumerator *enumerator = [self.sourceKPIs objectEnumerator];
    
    NSArray* KPIsPerCell;
    
    for (int i = 0 ; i <= self.indexOfCurrentKPI; i++) {
        KPIsPerCell = [enumerator nextObject];
    }
    
    return KPIsPerCell;
}

- (void) moveToNextKPI {
    // Return the list of KPIs and for each KPI the list of values
    
    self.indexOfCurrentKPI++;
    
    if (self.indexOfCurrentKPI == self.sourceKPIs.count) {
        self.indexOfCurrentKPI = 0;
    }
    
}

- (void) moveToPreviousKPI {
    if (self.indexOfCurrentKPI == 0) {
        self.indexOfCurrentKPI = self.sourceKPIs.count -1;
    } else {
        self.indexOfCurrentKPI--;
    }
    
}

- (CellMonitoring*) getCellbyName:(NSString*) theCellName {
    NSDictionary* cells = self.datasource.cellIndexedByName;
    
    if (cells != Nil) {
        return cells[theCellName];
    } else {
        return Nil;
    }
}



@end
