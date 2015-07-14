//
//  WorstKPIDataSource.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 12/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WorstKPIDataSource.h"
#import "CellWithKPIValues.h"
#import "KPIDictionary.h"
#import "KPI.h"
#import "CellMonitoring.h"
#import "ZoneKPI.h"
#import "Utility.h"
#import "KPIDictionaryManager.h"

@interface WorstKPIDataSource() {
    // Key: KPI name
    // Value: NSMutableArray, each entry contains a CellKPis which has
    //                        - the KPI
    //                        - cellName
    //                        - List of values for the KPIs on the period
    // The content is ordered by the last KPIs value for the worst cell
    NSMutableDictionary* _KPIs;
    
    // Exactly same content as _KPIs except the ordering.
    // The content is ordered to find the worst cell on the average on the period
    NSMutableDictionary* _worstAverageKPIs;
    
    // Contains for each KPI its average on the zone
    // Index: KPI Name
    // Value: ZoneKPI
    NSMutableDictionary* _zoneKPIs;
    
}

@property (nonatomic) NSUInteger requestCounter;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) dispatch_queue_t serializedQueue;

@end


@implementation WorstKPIDataSource

//[{"KPIName":"_RB_Blocking_Rate_Mod_C","KPIValues":"0.13%,0.15%,0.00%,0.14%,0.10%,0.00%,0.00%,0.00%,0.12%,0.00%,0.00%,0.00%,0.00%,0.00%,0.00%,0.00%,0.00%,0.13%,0.00%,0.06%,0.00%,0.07%,0.00%,0.08%,0.07%","cellName":"DCU2085X"},{"KPIName":"_RB_Blocking_Rate_Mod_C","KPIValues":"0.07%,0.23%,0.13%,0.00%,0.00%,0.06%,0.00%,0.05%,0.00%,0.00%,0.00%,0.00%,0.00%,0.06%,0.00%,0.00%,0.05%,0.11%,0.04%,0.00%,0.10%,0.09%,0.04%,0.07%,0.03%","cellName":"DCU2085Y"},{"KPIName":"_RB_Blocking_Rate_Den","KPIValues":"744,647,723,730,990,1248,1099,658,850,459,366,370,607,499,456,631,695,754,721,1751,1552,1343,1137,1315,1459","cellName":"DCU2085X"},{"KPIName":"_RB_Blocking_Rate_Den","KPIValues":"1481,1317,1488,1531,1361,1664,1698,1852,1616,1579,1790,732,727,1570,2219,2224,1976,1884,2416,2843,3060,3294,2795,2789,2927","cellName":"DCU2085Y"},{"KPIName":"TotalNumberOfCalls_Traffic040_C_Ps","KPIValues":"711,614,690,697,937,1196,1061,635,818,454,364,364,604,495,455,628,688,737,697,1665,1479,1226,1045,1227,1379","cellName":"DCU2085X"},

- (void) extractTimezone:(NSData *) theData {
    _timezone = [Utility extractTimezoneFromData:theData];
}

- (void) dataReady:(id) theData clientId:(NSString*) theClientId {
    
    if (self.requestCounter == -1) {
        // just ignore, it means an error has happened.
        return;
    }
    
    
    if ([theClientId isEqualToString:@"TimeZone"]) {
        [self extractTimezone:theData];
        return;
    }
    
    NSLog(@"%s get a response %lu (with clientId: %@)", __PRETTY_FUNCTION__, (unsigned long)_requestCounter, theClientId);
    
    // should be done by each thread
    
    dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    dispatch_async(aQueue, ^{
        
        NSArray* data = theData;

        if (data == Nil) {
            NSLog(@"Empty response with counter: %lu", (unsigned long)self.requestCounter);
            if (theData == Nil) {
                NSLog(@"the data is nil");
            }
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError* error = [[NSError alloc] initWithDomain:@"Communication Error" code:1 userInfo:Nil];
                [self.delegate worstDataIsLoaded:error];
                self.requestCounter = -1;
                return;
            });
        }
        
        // for each Cell we get a Dictionary where the key is the KPIName and value is an Array of KPIValues...
        KPIDictionary* kpiDico = [[KPIDictionaryManager sharedInstance] defaultKPIDictionary];
        
        NSMutableArray* arrayOfKPIsForACell = [[NSMutableArray alloc] initWithCapacity:data.count];
        for (NSDictionary* currCell in data) {
             
            NSString* kpiName = currCell[@"KPIName"];
            
            KPI* theKPI = [kpiDico findKPIbyInternalName:kpiName forTechno:self.technology];
            if (theKPI.hasDirection == false) {
                continue;
            }

            NSArray* stringValues = currCell[@"KPIValues"];
            NSString* cellName = currCell[@"cellName"];

            CellWithKPIValues* KPIsForACell = [[CellWithKPIValues alloc] init:cellName kpi:theKPI values:stringValues];
            [arrayOfKPIsForACell addObject:KPIsForACell];
        }
        
        dispatch_async(self.serializedQueue, ^{
            if (self.KPIs == Nil) {
                _KPIs = [[NSMutableDictionary alloc] init];
                _worstAverageKPIs = [[NSMutableDictionary alloc] init];
                _zoneKPIs = [[NSMutableDictionary alloc] init];
            }
            
            for (CellWithKPIValues* KPIsForACell in arrayOfKPIsForACell) {
                
                NSString* kpiName = KPIsForACell.theKPI.name;
                
                ZoneKPI* theZoneKPI = _zoneKPIs[kpiName];
                if (theZoneKPI == Nil) {
                    theZoneKPI = [[ZoneKPI alloc] init:KPIsForACell.theKPI];
                    _zoneKPIs[kpiName] = theZoneKPI;
                }
                [theZoneKPI addNewKPIsValues:KPIsForACell];
                
                
                NSMutableArray* KPIsPerCell = _KPIs[kpiName];
                if (KPIsPerCell == Nil) {
                    KPIsPerCell = [[NSMutableArray alloc] init];
                    _KPIs[kpiName] = KPIsPerCell;
                }
                
                NSMutableArray* KPIsPerCellForAverage = _worstAverageKPIs[kpiName];
                if (KPIsPerCellForAverage == Nil) {
                    KPIsPerCellForAverage = [[NSMutableArray alloc] init];
                    _worstAverageKPIs[kpiName] = KPIsPerCellForAverage;
                }
                
                [KPIsPerCell addObject:KPIsForACell];
                [KPIsPerCellForAverage addObject:KPIsForACell];
            }
            
            self.requestCounter--;
            
            if (self.requestCounter == 0) {
                
                NSLog(@"%s all responses have been received", __PRETTY_FUNCTION__);
                // reorder the cells for a KPIs by last KPI value
                for (NSMutableArray* currentKPIsPerCell in _KPIs.allValues) {
                    [currentKPIsPerCell sortUsingSelector:@selector(compareWithLastKPIValue:)];
                }
                for (NSMutableArray* currentKPIsPerCell in _worstAverageKPIs.allValues) {
                    [currentKPIsPerCell sortUsingSelector:@selector(compareWithAverageKPIValue:)];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate worstDataIsLoaded:Nil];
                });
            }
            
        });
        
    });
    
}



- (void) connectionFailure:(NSString*) theClientId {

    // If timezone is missing it's not blocking we can continue
    if ([theClientId isEqualToString:@"TimeZone"]) {
        return;
    }

    // avoid multiple popup if there are several errors
    if (_requestCounter != -1) {
        NSError* error = [[NSError alloc] initWithDomain:@"Communication Error" code:1 userInfo:Nil];

        [_delegate worstDataIsLoaded:error];
        _requestCounter = -1;
    }
}

- (id) init:(id<WorstKPIDataLoadingItf>) delegate {

    if (self = [super init]) {
        _delegate = delegate;
        _timezone = Nil;
        _serializedQueue = dispatch_queue_create("com.SebCompany.CellMonitoring.serializedQueue", NULL);
    }
    
    return self;
   
}

- (void) initialize:(NSArray*) cells techno:(DCTechnologyId) theTechno centerCoordinate:(CLLocationCoordinate2D) coordinate {
    
    NSMutableDictionary* theCellsIndexedByName = [[NSMutableDictionary alloc] initWithCapacity:cells.count];
    for (CellMonitoring* currentCell in cells) {
        theCellsIndexedByName[currentCell.id] = currentCell;
    }
    
    _cellIndexedByName = theCellsIndexedByName;
    
    _technology = theTechno;
    _coordinate = coordinate;
}

- (Boolean) hasTimezone {
    if (_timezone != Nil) {
        return TRUE;
    } else {
        return FALSE;
    }
}

// 
- (void) loadData:(DCMonitoringPeriodView) monitoringPeriod {
    _requestDate = [[NSDate alloc] init];    

    _requestCounter = [RequestUtilities getCellsKPIsWithDirection:self.cellIndexedByName.allValues
                                                           techno:self.technology
                                                      periodicity:monitoringPeriod
                                                         delegate:self clientId:@"cells"];
    
    [RequestUtilities getTimeZone:_coordinate delegate:self clientId:@"TimeZone"];
}


@end
