//
//  CellAlarmDatasource.h
//  iMonitoring
//
//  Created by sébastien brugalières on 10/09/13.
//
//

#import <Foundation/Foundation.h>
#import "HTMLRequest.h"
#import "CellMonitoring.h"

@class CellAlarm;

@protocol CellAlarmListener <NSObject>

- (void) alarmLoadingFailure;
- (void) alarmLoaded;

@end


@interface CellAlarmDatasource : NSObject<HTMLDataResponse>

@property(nonatomic, readonly) CellMonitoring* theCell;
@property(nonatomic, readonly) NSArray* alarmsOrderedBySeverity;
@property(nonatomic, readonly) NSArray* alarmsOrderedByDate;
@property(nonatomic, readonly) CellAlarm* alarmWithHighestSeverity;

@property(nonatomic, readonly) NSUInteger criticalAlarmCounter;
@property(nonatomic, readonly) NSUInteger majorAlarmCounter;
@property(nonatomic, readonly) NSUInteger minorAlarmCounter;
@property(nonatomic, readonly) NSUInteger warningAlarmCounter;

- (id)init:(CellMonitoring *) theCell;

- (void) subscribe:(id<CellAlarmListener>) listener;
- (void) unsubscribe:(id<CellAlarmListener>) listener;
- (void) loadAlarms;

@end
