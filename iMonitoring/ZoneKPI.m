//
//  ZoneKPI.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 22/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ZoneKPI.h"
#import "KPI.h"
#import "CellWithKPIValues.h"


@interface ZoneKPI()

@property(nonatomic) NSUInteger cellcount;
@property(nonatomic) KPI* theKPI;
@property(nonatomic) NSMutableArray* KPIAverageValueEvolution;
@property(nonatomic) NSMutableArray* KPIValuesOfCells;

@end

@implementation ZoneKPI
@synthesize theKPI = _theKPI;

- (id) init:(KPI*) theKPI {
    
    if (self = [super init]) {
        _theKPI = theKPI;
        _cellcount = 0;
        _KPIValuesOfCells = Nil;
    }
    
    return self;
}


- (void) addNewKPIsValues:(CellWithKPIValues*) theCellKPI {
    // Warning: Cannot do simply the sum because some value will be missing and then the 
    // average will be wrong because we don't have the same number of values to divide...
    
    _cellcount++;
    if (_KPIValuesOfCells == Nil) {
        _KPIValuesOfCells = [[NSMutableArray alloc] init];
    } 

    [_KPIValuesOfCells addObject:theCellKPI];
}


- (NSArray*) getKPIAverage {
    
    if (_KPIAverageValueEvolution != Nil) {
        return _KPIAverageValueEvolution;
    }
    
    
    // Compute the KPI average for the zone
    // Computation is done per column (period)
    
    if (_KPIValuesOfCells != Nil) {
        CellWithKPIValues* firstEntry = _KPIValuesOfCells[0];
        
        _KPIAverageValueEvolution = [[NSMutableArray alloc] initWithCapacity:firstEntry.valuesOfTheKPISize];
        
        for (NSUInteger i = 0; i < firstEntry.valuesOfTheKPISize; i++) {
            NSUInteger numberOfValidValues = 0;
            float sum = 0;
            for (CellWithKPIValues* currentCellKPIs in _KPIValuesOfCells) {
                float* currentCellValueFloat = currentCellKPIs.valuesOfTheKPIFloat;
                float currentKPIValue = currentCellValueFloat[i];
                if (isnan(currentKPIValue) == FALSE) {
                    numberOfValidValues++;
                    sum += currentKPIValue;
                }
            }
            if (numberOfValidValues > 0) {
                float floatAverage = sum / numberOfValidValues;
                NSNumber* averageValue = @(floatAverage);
                [_KPIAverageValueEvolution addObject:averageValue];
            } else {
                [_KPIAverageValueEvolution addObject:[NSNull null]];
            }
        }
    }
    _KPIValuesOfCells = Nil;
    
    return _KPIAverageValueEvolution;
    
}

- (NSNumber*) getLastValue {
    NSArray* averageValues = [self getKPIAverage];
    NSNumber* lastValue = averageValues.lastObject;
    
    if ((id) lastValue == [NSNull null]) {
        return Nil;
    } else {
        return lastValue;
    }
}

- (NSNumber*) getAverageValue {
    NSArray* averageValues = [self getKPIAverage];
    NSUInteger count = 0;
    float sum = 0;
    
    for (NSNumber* value in averageValues) {
        if ((id) value != [NSNull null]) {
            sum += [value floatValue];
            count++;
        }
    }
    
    if (count > 0) {
        return @(sum/count);
    } else {
        return Nil;
    }
    
}

- (NSString*) export2HTML {
    
    NSMutableString* HTML = [[NSMutableString alloc] init];
    
    KPI* currentKPI = _theKPI;
    NSArray* kpiValues = [self getKPIAverage];
    
    
    [HTML appendFormat:@"<tr><td><b>%@ </b></td>",currentKPI.name];
    for (NSNumber* values in kpiValues) {
        
        NSString* colorCode = [currentKPI getHTMLColorFromNumber:values];
        
        [HTML appendFormat:@"<td style=\"background-color:%@;text-align:center\">%@</td>",
         colorCode, [currentKPI getHTMLDisplayableValueFromNumber:values] ];
        
    }
    [HTML appendFormat:@"</tr>"];
    return HTML;
}

@end
