//
//  CellKPIDatasource.m
//  iMonitoring
//
//  Created by sébastien brugalières on 16/01/2014.
//
//

#import "CellKPIDatasource.h"

#import "MonitoringPeriodUtility.h"
#import "KPI.h"
#import "KPIDictionaryManager.h"
#import "KPIDictionary.h"
#import "CellKPIsDataSource.h"
#import "CellMonitoring.h"

@interface CellKPIDatasource()

@property (nonatomic) CellKPIsDataSource* cellDatasource;
@property (nonatomic) DCMonitoringPeriodView currentMonitoringPeriod;
@property (nonatomic) NSIndexPath* indexOfCurrentKPI;

@end


@implementation CellKPIDatasource

- (id)init:(CellKPIsDataSource*) cellDatasource initialMonitoringPeriod:(DCMonitoringPeriodView) monitoringPeriod initialIndex:(NSIndexPath*) index
{
    self = [super init];
    
    _cellDatasource = cellDatasource;
    _currentMonitoringPeriod = monitoringPeriod;
    _indexOfCurrentKPI = index;
    return self;
}

#pragma mark - KPIDatsource Protocol
- (KPI*) getKPI {
    return [self getKPI:self.indexOfCurrentKPI];
}

- (NSArray*) getKPIValues {
    return [self getKPIValues:self.indexOfCurrentKPI];
}

- (KPI*) getKPI:(NSIndexPath*)  index {
    KPIDictionaryManager* dc = [KPIDictionaryManager sharedInstance];
    
    
    
    return [dc.defaultKPIDictionary getKPIbyDomain:index techno:self.cellDatasource.theCell.cellTechnology];
}

- (NSArray*) getKPIValues:(NSIndexPath*) index {
    KPI* cellKPI = [self getKPI:index];
    NSDictionary* KPIValues = [self.cellDatasource getKPIsForMonitoringPeriod:self.currentMonitoringPeriod];
    
    if (KPIValues != Nil) {
        return KPIValues[cellKPI.internalName];
    } else {
        return Nil;
    }
}

- (NSArray*) getKPIValues:(NSIndexPath*) index period:(DCMonitoringPeriodView) monitoringPeriod {
    KPI* cellKPI = [self getKPI:index];
    NSDictionary* KPIValues = [self.cellDatasource getKPIsForMonitoringPeriod:monitoringPeriod];
    
    if (KPIValues != Nil) {
        return KPIValues[cellKPI.internalName];
    } else {
        return Nil;
    }
}

- (NSArray*) getKPIValuesOf:(KPI*) theKPI {
    NSDictionary* allKPIValues = [self.cellDatasource getKPIsForMonitoringPeriod:self.currentMonitoringPeriod];
    if (allKPIValues != Nil) {
        return allKPIValues[theKPI.internalName];
    } else {
        return Nil;
    }
}

- (void) moveToNextKPI {
    KPIDictionaryManager* dc = [KPIDictionaryManager sharedInstance];
    self.indexOfCurrentKPI = [dc.defaultKPIDictionary getNextKPIByDomain:self.indexOfCurrentKPI techno:self.cellDatasource.theCell.cellTechnology];
    if (self.indexOfCurrentKPI == Nil) {
        NSUInteger indexes[] = {0,0};
        NSIndexPath* indexOfCurrentKPI = [NSIndexPath indexPathWithIndexes:indexes length:2];
        self.indexOfCurrentKPI  = indexOfCurrentKPI;
    }
}


- (NSIndexPath*) moveToPreviousKPI:(NSIndexPath*) currentKPIIndex {
    KPIDictionaryManager* dc = [KPIDictionaryManager sharedInstance];
    return [dc.defaultKPIDictionary getPreviousKPIByDomain:currentKPIIndex techno:self.cellDatasource.theCell.cellTechnology];
}

- (void) moveToPreviousKPI {
    self.indexOfCurrentKPI = [self moveToPreviousKPI:self.indexOfCurrentKPI];
    if (self.indexOfCurrentKPI == Nil) {
        // Move to the last row of the last section
        // Get the list of the KPIs for the last section
        KPIDictionaryManager* dc = [KPIDictionaryManager sharedInstance];
        self.indexOfCurrentKPI = [dc.defaultKPIDictionary getLastKPIbyDomain:self.cellDatasource.theCell.cellTechnology];
        
    }
    
}

- (void) moveToNextMonitoringPeriod {
    self.currentMonitoringPeriod = [MonitoringPeriodUtility getNextMonitoringPeriod:self.currentMonitoringPeriod];
}

- (void) moveToPreviousMonitoringPeriod {
    self.currentMonitoringPeriod = [MonitoringPeriodUtility getPreviousMonitoringPeriod:self.currentMonitoringPeriod];
}

- (DCMonitoringPeriodView) getMonitoringPeriod {
    return self.currentMonitoringPeriod;
}



@end
