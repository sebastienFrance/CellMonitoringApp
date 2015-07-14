//
//  CellKPis.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 22/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CellWithKPIValues.h"
#import "KPI.h"

@interface CellWithKPIValues()


@property (nonatomic) NSString* cellName;
@property (nonatomic) KPI* theKPI;
@property (nonatomic) NSNumber* worstValueOnPeriod;
@property (nonatomic) NSNumber* averageValue;
@property (nonatomic) NSNumber* lastKPIValue;

@property (nonatomic) float* valuesOfTheKPIFloat;
@property (nonatomic) NSUInteger valuesOfTheKPISize;

@end

@implementation CellWithKPIValues


- (id) init:(NSString*) theCellName kpi:(KPI*) theKPI values:(NSArray*) theKPIValues {
    if (self = [super init]) {
        _cellName = theCellName;
        _theKPI = theKPI;
        
        [self computeWorstAndAverage:theKPIValues];
     }
    
    return self;
}


-(void)dealloc {
    free(_valuesOfTheKPIFloat);
}

// Translate the list of string that contains the values of the KPI into
// a NSArray of NSNumber (float) and search for worst / averages values
- (void) computeWorstAndAverage:(NSArray*) theKPIValues {
    NSUInteger counter = 0;
    float averageKPIValue = 0;
    float worstKPIValue;
    
    
    float *rows = calloc(theKPIValues.count, sizeof(float));
    
    NSUInteger index = 0;
    for (NSString* value in theKPIValues) {
        
        if ([value isEqualToString:@"Nerr"]) {
            rows[index++] = NAN;
            continue;
        }
        
        if ([value isEqualToString:@"N/A"]) {
            rows[index++] = NAN;
            continue;
        }
        
        
        float floatValue = [value floatValue];
        rows[index++] = floatValue;
        
        if (counter == 0) {
            worstKPIValue = floatValue;
        } else {
            if (_theKPI.isDirectionIncrease) {
                if (floatValue > worstKPIValue) {
                    worstKPIValue = floatValue;
                }
            } else {
                if (floatValue < worstKPIValue) {
                    worstKPIValue = floatValue;
                }
            }
        }
        
        averageKPIValue += floatValue;
        counter++;
    }
    
    _valuesOfTheKPIFloat = rows;
    _valuesOfTheKPISize = theKPIValues.count;
    if (counter > 0) {
        _averageValueFloat = averageKPIValue /= counter;
        _averageValue = @(_averageValueFloat);
        _worstValueOnPeriod = @(worstKPIValue);
    } else {
        _averageValue = Nil;
        _worstValueOnPeriod = Nil;
    }
    
}


- (NSNumber*) lastKPIValue {
    float lastValue = _valuesOfTheKPIFloat[(self.valuesOfTheKPISize-1)];
    
    if (isnan(lastValue) == FALSE) {
        return @(lastValue);
    } else {
        return Nil;
    }
}

- (float) lastKPIValueFloat {
    return _valuesOfTheKPIFloat[(self.valuesOfTheKPISize-1)];
}

- (NSComparisonResult) compareReverseWithLastKPIValue:(CellWithKPIValues *)otherObject {
    NSComparisonResult result = [self compareWithLastKPIValue:otherObject];
    if (result == NSOrderedDescending) {
        return NSOrderedAscending;
    } else if (result == NSOrderedAscending) {
        return NSOrderedDescending;
    } else return result;
}


- (NSComparisonResult) compareWithLastKPIValue:(CellWithKPIValues *)otherObject {
    
    const register float selfLastKPIValueFloat = self.lastKPIValueFloat;
    const register float otherLastKPIValueFloat = otherObject.lastKPIValueFloat;
    
    if (isnan(otherLastKPIValueFloat)) {
        if (isnan(selfLastKPIValueFloat)) {
            return NSOrderedSame;
        } else {
            return NSOrderedAscending;
        }
    } else {
        if (isnan(selfLastKPIValueFloat)) {
            return NSOrderedDescending;
        }
    }

    if (otherLastKPIValueFloat == selfLastKPIValueFloat) {
        return NSOrderedSame;
    } 
    
    if (self.theKPI.isDirectionIncrease) {
        if (otherLastKPIValueFloat > selfLastKPIValueFloat) {
            return NSOrderedDescending;
        } else {
            return NSOrderedAscending;
        }
    } else {
        if (selfLastKPIValueFloat > otherLastKPIValueFloat) {
            return NSOrderedDescending;
        } else {
            return NSOrderedAscending;
        }
    }
    
}


- (NSComparisonResult) compareReverseWithAverageKPIValue:(CellWithKPIValues *)otherObject {
    NSComparisonResult result = [self compareWithAverageKPIValue:otherObject];
    if (result == NSOrderedDescending) {
        return NSOrderedAscending;
    } else if (result == NSOrderedAscending) {
        return NSOrderedDescending;
    } else return result;
}



- (NSComparisonResult) compareWithAverageKPIValue:(CellWithKPIValues *)otherObject {
    
    const register float selfAverageValueFloat = self.averageValueFloat;
    const register float otherAverageValueFloat = otherObject.averageValueFloat;
    
    if (isnan(otherAverageValueFloat)) {
        if (isnan(selfAverageValueFloat)) {
            return NSOrderedSame;
        } else {
            return NSOrderedAscending;
        }
    } else {
        if (isnan(selfAverageValueFloat)) {
            return NSOrderedDescending;
        }
    }
    
    if (otherAverageValueFloat ==  selfAverageValueFloat) {
        return NSOrderedSame;
    }
    
    if (self.theKPI.isDirectionIncrease) {
        if (otherAverageValueFloat > selfAverageValueFloat) {
            return NSOrderedDescending;
        } else {
            return NSOrderedAscending;
        }
    } else {
        if (selfAverageValueFloat > otherAverageValueFloat) {
            return NSOrderedDescending;
        } else {
            return NSOrderedAscending;
        }
    }
    
}



- (NSComparisonResult) compareWithCellName:(CellWithKPIValues *)otherObject {
    return ([self.cellName  compare:otherObject.cellName]);
}

- (NSString*) export2HTML:(Boolean) isAverageKPIs {

    NSNumber* KPIValue;
    if (isAverageKPIs) {
        KPIValue = self.averageValue;
    } else {
        KPIValue = self.lastKPIValue;
    }
    
    NSMutableString* HTMLString = [[NSMutableString alloc] init];
    
    [HTMLString appendFormat:@"<tr><td>%@</td>", self.cellName];
    
    NSString* theKPIStringValue = [self.theKPI getDisplayableValueFromNumber:KPIValue];
    if ([self.theKPI.unit isEqualToString:@"%"]) {
        theKPIStringValue = [theKPIStringValue stringByReplacingOccurrencesOfString:@"%" withString:@"&#37;"];
    } 
    
    [HTMLString appendFormat:@"<td style=\"background-color:%@;text-align:center\"><b>%@</b></td>", [self.theKPI getHTMLColorFromNumber:KPIValue], theKPIStringValue];
    [HTMLString appendFormat:@"</tr>"];
    return HTMLString;
}


@end
