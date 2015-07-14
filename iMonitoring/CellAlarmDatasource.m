//
//  CellAlarmDatasource.m
//  iMonitoring
//
//  Created by sébastien brugalières on 10/09/13.
//
//

#import "CellAlarmDatasource.h"
#import "CellAlarm.h"
#import "RequestUtilities.h"

@interface CellAlarmDatasource()

@property(nonatomic) NSMutableArray* listeners;


@end

@implementation CellAlarmDatasource


#pragma mark - HTML Request Callbacks
- (void) dataReady: (id) theData clientId:(NSString *)theClientId {
    
    if ([theClientId isEqualToString:@"cellAlarms"]) {
        [self cellAlarmsReady:theData];
    } else {
        NSLog(@"%s Unknown clientId: %@", __PRETTY_FUNCTION__, theClientId);
    }
}


- (void) connectionFailure:(NSString*) theClientId {
    if ([theClientId isEqualToString:@"cellAlarms"]) {
        for (id<CellAlarmListener> currentListener in self.listeners) {
            [currentListener alarmLoadingFailure];
        }
    } else {
        NSLog(@"%s Unknown clientId: %@", __PRETTY_FUNCTION__, theClientId);
    }
}

- (void) cellAlarmsReady:(id) theData {
    NSArray* data = theData;
    
    NSMutableArray* alarms = [[NSMutableArray alloc] init];
    
    _criticalAlarmCounter = 0;
    _majorAlarmCounter = 0;
    _minorAlarmCounter = 0;
    _warningAlarmCounter = 0;
    
    _alarmWithHighestSeverity = Nil;
    
    for (NSDictionary* currentAlarmData in data) {
        CellAlarm* newAlarm = [[CellAlarm alloc] initWithAlarmData:currentAlarmData];
        
        if (self.alarmWithHighestSeverity == Nil) {
            _alarmWithHighestSeverity = newAlarm;
        } else if ([newAlarm compareWithSeverity:self.alarmWithHighestSeverity] == NSOrderedAscending) {
            _alarmWithHighestSeverity = newAlarm;
        }
        
        [self incrementAlarmCounter:newAlarm];
        
        [alarms addObject:newAlarm];
    }
    
    _alarmsOrderedByDate = [alarms sortedArrayUsingSelector:@selector(compareWithDateAndTime:)];
    _alarmsOrderedBySeverity = [alarms sortedArrayUsingSelector:@selector(compareWithSeverity:)];
    
    for (id<CellAlarmListener> currentListener in self.listeners) {
        [currentListener alarmLoaded];
    }
}


- (void) incrementAlarmCounter:(CellAlarm*) theAlarm {
    switch (theAlarm.severity) {
        case Critical: {
            _criticalAlarmCounter++;
            break;
        }
        case Major: {
            _majorAlarmCounter++;
            break;
        }
        case Minor: {
            _minorAlarmCounter++;
            break;
        }
        case Warning: {
            _warningAlarmCounter++;
            break;
        }
        default:
            break;
    }
}

#pragma mark - Interface
- (void) loadAlarms {
    [RequestUtilities getCellAlarms:self.theCell delegate:self clientId:@"cellAlarms"];
}

- (void) subscribe:(id<CellAlarmListener>) listener {
    [self.listeners addObject:listener];
    
}
- (void) unsubscribe:(id<CellAlarmListener>) listener {
    [self.listeners removeObjectIdenticalTo:listener];
}

#pragma mark - Initialization
- (id)init:(CellMonitoring *) theCell {
    
    if (self = [super init]) {
        _theCell = theCell;
        _listeners = [[NSMutableArray alloc] init];
    }
    return self;
}




@end
