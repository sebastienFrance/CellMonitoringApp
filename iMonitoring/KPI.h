//
//  KPI.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 13/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//#import <UIKit/UIKit.h>
//#import "DataCenter.h"
#import "BasicTypes.h"
#import "MonitoringPeriodUtility.h"

typedef NS_ENUM(NSUInteger, KPIColorCodeId) {
    KPIColorgreen = 0,		
    KPIColoryellow = 1,
    KPIColororange = 2,
    KPIColorred = 3,
    KPIColorwhite = 4
};


@interface KPI : NSObject

@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSString* internalName;
@property (nonatomic, readonly) NSString* domain;

@property (nonatomic, readonly) NSString* shortDescription;
@property (nonatomic, readonly) NSString* formula;
@property (nonatomic, readonly) NSString* techno;
@property (nonatomic, readonly) NSString* unit;

@property (nonatomic, readonly) NSString* relatedKPI;

@property (nonatomic, readonly) KPI* theRelatedKPI;

@property (nonatomic, readonly) Boolean hasDirection;
@property (nonatomic, readonly) Boolean isDirectionIncrease;
@property (nonatomic, readonly) float lowThreshold;
@property (nonatomic, readonly) float mediumThreshold;
@property (nonatomic, readonly) float highThreshold;

@property (nonatomic, readonly) DCTechnologyId technology;

#pragma mark - Create and Configure
- (id) init:(NSDictionary*) KPIData techno:(NSString*) theTechno;
- (void) setThreshold:(NSString*) direction high:(NSString*) theHigh medium:(NSString*) theMedium low:(NSString*) theLow;

#pragma mark - get data from KPI

- (NSString*) KPIDescriptionToHTML;

// using Number
- (float) getKPIValueFromNumber:(NSNumber*) value;
- (NSString*) getDisplayableValueFromNumber:(NSNumber*) value;
- (NSString*) getHTMLDisplayableValueFromNumber:(NSNumber*) value;
#if TARGET_OS_IPHONE
- (UIColor*) getColorValueFromNumber:(NSNumber*) value;
- (UIColor*) getBackgroundColorValueFromNumber:(NSNumber*) value;
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
- (NSColor*) getColorValueFromNumber:(NSNumber*) value;
- (NSColor*) getBackgroundColorValueFromNumber:(NSNumber*) value;
#endif
- (KPIColorCodeId) getColorIdFromNumber:(NSNumber*) value;
- (NSString*) getHTMLColorFromNumber:(NSNumber*) value;

// using float
- (float) getKPIValueFromFloat:(float) value;
- (NSString*) getDisplayableValueFromFloat:(float) value;
- (NSString*) getHTMLDisplayableValueFromFloat:(float) value;
#if TARGET_OS_IPHONE
- (UIColor*) getColorValueFromFloat:(float) value;
- (UIColor*) getBackgroundColorValueFromFloat:(float) value;
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
- (NSColor*) getColorValueFromFloat:(float) value;
- (NSColor*) getBackgroundColorValueFromFloat:(float) value;
#endif
- (KPIColorCodeId) getColorIdFromFloat:(float) value;
- (NSString*) getHTMLColorFromFloat:(float) value;

+(NSString*) displayCurrentAndPreviousValue:(NSString*) currentValue preValue:(NSString*) previousValue monitoringPeriod:(DCMonitoringPeriodView) theMonitoringPeriod requestDate:(NSDate*) theRequestedDate;

@end
