//
//  HTMLMailUtility.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 16/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MonitoringPeriodUtility.h"


@interface HTMLMailUtility : NSObject

+ (NSString*) convertKPIsTableHeader:(NSDate*) theRequestDate timezone:(NSString*) theTimezone;
+ (NSString*) convertKPIsTableHeader:(NSDate*) theRequestDate timezone:(NSString*) theTimezone monitoringPeriod:(DCMonitoringPeriodView) theMonitoringPeriod;

+ (NSString*) getGreenColorCode;
+ (NSString*) getYellowColorCode;
+ (NSString*) getOrangeColorCode;
+ (NSString*) getRedColorCode;
+ (NSString*) getNoValueColorCode;
+ (NSString*) getBlueColorCode;

@end
