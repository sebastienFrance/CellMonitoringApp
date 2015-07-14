//
//  ZoneKPISource.m
//  iMonitoring
//
//  Created by sébastien brugalières on 11/01/2014.
//
//

#import "ZoneKPISource.h"
#import "WorstKPIDataSource.h"

@interface ZoneKPISource()

@property(nonatomic) NSUInteger indexOfCurrentKPI;
@property (nonatomic) WorstKPIDataSource* datasource;

@end

@implementation ZoneKPISource

- (id) init:(WorstKPIDataSource*) theDatasource initialIndex:(NSUInteger) index {
    
    if (self = [super init]) {
        _datasource = theDatasource;
        _indexOfCurrentKPI = index;
    }
    
    return self;
}


#pragma mark - ZoneKPIDataSource protocol
- (void) goToIndex:(NSUInteger) index {
    self.indexOfCurrentKPI = index;
}

- (void) moveToNextZoneKPI {
    self.indexOfCurrentKPI++;
    
    if (self.indexOfCurrentKPI == [self.datasource.zoneKPIs allValues].count) {
        self.indexOfCurrentKPI = 0;
    }
    
}
- (void) moveToPreviousZoneKPI {
    if (self.indexOfCurrentKPI == 0) {
        self.indexOfCurrentKPI = [self.datasource.zoneKPIs allValues].count - 1;
    } else {
        self.indexOfCurrentKPI--;
    }
}

- (DCMonitoringPeriodView) getZoneMonitoringPeriod {
    MonitoringPeriodUtility* dc = [MonitoringPeriodUtility sharedInstance];
    return dc.monitoringPeriod;
}


- (KPI*) getZoneKPI {
    
    NSEnumerator *enumerator = [self.datasource.zoneKPIs objectEnumerator];
    ZoneKPI* currentZoneKPI;
    
    for (int i = 0 ; i <= self.indexOfCurrentKPI; i++) {
        currentZoneKPI = [enumerator nextObject];
    }
    
    return currentZoneKPI.theKPI;;
}

- (NSArray*) getZoneKPIValues {
    NSEnumerator *enumerator = [self.datasource.zoneKPIs objectEnumerator];
    ZoneKPI* currentZoneKPI;
    
    for (int i = 0 ; i <= self.indexOfCurrentKPI; i++) {
        currentZoneKPI = [enumerator nextObject];
    }
    return [currentZoneKPI getKPIAverage];
}
- (WorstKPIDataSource*) getDetailedDataSource {
    return self.datasource;
}

- (ZoneKPI*) getFullZoneKPI {
    NSEnumerator *enumerator = [self.datasource.zoneKPIs objectEnumerator];
    ZoneKPI* currentZoneKPI;
    
    for (int i = 0 ; i <= self.indexOfCurrentKPI; i++) {
        currentZoneKPI = [enumerator nextObject];
    }
    
    
    return currentZoneKPI;
}

@end
