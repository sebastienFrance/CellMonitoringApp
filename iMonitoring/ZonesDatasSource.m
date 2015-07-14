//
//  ZonesDatasSource.m
//  iMonitoring
//
//  Created by sébastien brugalières on 30/12/2013.
//
//

#import "ZonesDatasSource.h"
#import "Zone.h"

@interface ZonesDatasSource()

@property (nonatomic, weak) id<ZonesDatasSourceDelegate> delegate;

@end

@implementation ZonesDatasSource

- (id)init:(id<ZonesDatasSourceDelegate>) theDelegate {
    if (self = [super init] ) {
        _delegate = theDelegate;
    }
    
    return self;
}

-(void) downloadZones {
    [RequestUtilities getZoneList:self clientId:@"getZoneList"];
}


- (void) dataReady: (id) theData clientId:(NSString *)theClientId {
    
    if ([theClientId isEqualToString:@"getZoneList"]) {
        
        NSArray* data = theData;
        
        
        NSMutableDictionary* theListOfWorkingZones = [[NSMutableDictionary alloc] initWithCapacity:3];
        NSMutableDictionary* theListOfObjectZones = [[NSMutableDictionary alloc] initWithCapacity:3];
        
        NSMutableArray* fullZoneList = [[NSMutableArray alloc] initWithCapacity:data.count];
        
        for (NSDictionary* currZone in data) {
            NSString* theName = currZone[@"name"];
            NSString* theDescription = currZone[@"description"];
            NSString* theTechno = currZone[@"techno"];
            NSNumber* theType = currZone[@"type"];
            
            DCTechnologyId techno = DCTechnologyUNKNOWN;
            if ([theTechno isEqualToString:kTechnoLTE]) {
                techno = DCTechnologyLTE;
            } else if ([theTechno isEqualToString:kTechnoWCDMA]) {
                techno = DCTechnologyWCDMA;
            } else if ([theTechno isEqualToString:kTechnoGSM]) {
                techno = DCTechnologyGSM;
            }
            
            DCZoneTypeId type = [theType unsignedIntegerValue];
            
            Zone* newZone = [[Zone alloc] init:theName description:theDescription techno:techno type:type];
            [fullZoneList addObject:newZone];
            
            if (type == DCObjectZone) {
                NSMutableArray* objectZones = theListOfObjectZones[@(techno)];
                if (objectZones == Nil) {
                    objectZones = [[NSMutableArray alloc] init];
                    theListOfObjectZones[@(techno)] = objectZones;
                }
                
                [objectZones addObject:newZone];
            } else if (type == DCWorkingZone) {
                NSMutableArray* workingZones = theListOfWorkingZones[@(techno)];
                if (workingZones == Nil) {
                    workingZones = [[NSMutableArray alloc] init];
                    theListOfWorkingZones[@(techno)] = workingZones;
                }
                [workingZones addObject:newZone];
            }
        }
        
        // order each array
        for (NSMutableArray* currentZones in [theListOfWorkingZones objectEnumerator]) {
            [currentZones sortUsingComparator:^(Zone* obj1, Zone* obj2) {
                
                return [obj1.name compare:obj2.name];
            }];
        }
        // order each array
        for (NSMutableArray* currentZones in [theListOfObjectZones objectEnumerator]) {
            [currentZones sortUsingComparator:^(Zone* obj1, Zone* obj2) {
                
                return [obj1.name compare:obj2.name];
            }];
        }
        
        _listOfObjectZones = theListOfObjectZones;
        _listOfWorkingZones = theListOfWorkingZones;
        _listOfAllZones = fullZoneList;
        
        [self.delegate zonesResponse:Nil];
        
    } else {
        NSLog(@"ZoneViewController: unknown clientId");
        NSError* error = [[NSError alloc] initWithDomain:@"Communication Error" code:1 userInfo:Nil];
        [self.delegate zonesResponse:error];
    }
}

//  ----------- Cannot retreive the KPI dictionaries from the server ----------
- (void) connectionFailure:(NSString*) theClientId {
    NSError* error = [[NSError alloc] initWithDomain:@"Communication Error" code:1 userInfo:Nil];
    [self.delegate zonesResponse:error];
}



@end
