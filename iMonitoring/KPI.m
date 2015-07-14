//
//  KPI.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 13/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KPI.h"
#import "KPIDictionary.h"
#import "HTMLMailUtility.h"
#import "KPIDictionaryManager.h"
#import "DateUtility.h"

@implementation KPI


//KPIDictionaries[x].KPIs[y].KPIs[z].name = external name of the KPI
//KPIDictionaries[x].KPIs[y].KPIs[z].internalName
//KPIDictionaries[x].KPIs[y].KPIs[z].shortDescription
//KPIDictionaries[x].KPIs[y].KPIs[z].domain
//KPIDictionaries[x].KPIs[y].KPIs[z].formula
//KPIDictionaries[x].KPIs[y].KPIs[z].unit
//KPIDictionaries[x].KPIs[y].KPIs[z].direction
//KPIDictionaries[x].KPIs[y].KPIs[z].low
//KPIDictionaries[x].KPIs[y].KPIs[z].medium
//KPIDictionaries[x].KPIs[y].KPIs[z].high
//KPIDictionaries[x].KPIs[y].KPIs[z].relatedKPI

- (id) init:(NSDictionary*) KPIData techno:(NSString*) theTechno {
    if (self = [super init]) {
        _name = KPIData[@"name"];
        _shortDescription = KPIData[@"shortDescription"];
        _formula = KPIData[@"formula"];
        _internalName = KPIData[@"internalName"];
        _domain = KPIData[@"domain"];
        _unit = KPIData[@"unit"];

        NSString* direction = KPIData[@"direction"];
        if ((direction != Nil) && ([direction isEqualToString:@""] == FALSE)) {
 
            [self setThreshold:direction high:KPIData[@"high"] medium:KPIData[@"medium"] low:KPIData[@"low"]];
        }
        
        NSString* relatedKPI = KPIData[@"relatedKPI"];
        if (relatedKPI != Nil  && ([relatedKPI isEqualToString:@""] == FALSE)) {
            _relatedKPI = relatedKPI;
        }
        _techno = theTechno;
    }
    
    return self;
 
}


- (void) setThreshold:(NSString*) direction high:(NSString*) theHigh medium:(NSString*) theMedium low:(NSString*) theLow {
    _hasDirection = TRUE;
    
    if ([direction isEqualToString:@"increase"]) {
        _isDirectionIncrease = TRUE;
    } else {
        _isDirectionIncrease = FALSE;
    }
    
    if (theHigh != Nil) {
        _highThreshold = [theHigh doubleValue];
    }

    if (theMedium != Nil) {
        _mediumThreshold = [theMedium doubleValue];
    }

    if (theLow != Nil) {
        _lowThreshold = [theLow doubleValue];
    }
}


- (id) init {
    if (self = [super init]) {
        _hasDirection = FALSE;
    }
    
    return self;
}

- (DCTechnologyId) technology {
    if ([self.techno isEqualToString:@"LTE"]) {
        return DCTechnologyLTE;
    } else if ([self.techno isEqualToString:@"WCDMA"]) {
        return DCTechnologyWCDMA;
    } else if ([self.techno isEqualToString:@"GSM"]) {
        return DCTechnologyGSM;
    } else {
        return DCTechnologyUNKNOWN;        
    }
}

- (float) getKPIValueFromNumber:(NSNumber*) value {
    
    if ((id)value == [NSNull null]) {
        return 0.0;
    } else {
        if ([self.unit isEqualToString:@"%"]) {
            return [value floatValue]/100.0;
        } else {
            return [value floatValue];
        }
    }

}

- (float) getKPIValueFromFloat:(float) value {
    
    if (isnan(value)) {
        return 0.0;
    } else {
        if ([self.unit isEqualToString:@"%"]) {
            return value/100.0;
        } else {
            return value;
        }
    }
}



- (KPI*) theRelatedKPI {
    if (_relatedKPI != Nil) {
        KPIDictionary* dictionary = [KPIDictionaryManager sharedInstance].defaultKPIDictionary;
        return [dictionary findKPIbyInternalName:_relatedKPI];
    } else {
        return Nil;
    }
}

-(NSString*) getDisplayableValueFromNumber:(NSNumber*) value {
    if ((value == Nil) || ((id) value == [NSNull null])) {
        return @"No Value";
    }
    
    return [self getDisplayableValueFromFloat:[value floatValue]];
}

-(NSString*) getDisplayableValueFromFloat:(float) value {
    if (isnan(value)) {
        return @"No Value";
    }
    
    if ([self.unit isEqualToString:@"%"] == TRUE) {
        return [NSString stringWithFormat:@"%.02f%%", value];
    } else {
        return [NSString stringWithFormat:@"%.00f", value];
    }
}


// 
-(NSString*) getHTMLDisplayableValueFromNumber:(NSNumber*) value {
    if ((value == Nil) || ((id) value == [NSNull null])) {
        return @"No Value";
    }
    
    return [self getHTMLDisplayableValueFromFloat:[value floatValue]];
}


-(NSString*) getHTMLDisplayableValueFromFloat:(float) value {
    if (isnan(value)) {
        return @"No Value";
    }
    
    if ([self.unit isEqualToString:@"%"] == TRUE) {
        return [NSString stringWithFormat:@"%.02f&#37;", value];
    } else {
        return [NSString stringWithFormat:@"%.00f", value];
    }
}

#if TARGET_OS_IPHONE
- (UIColor*) getBackgroundColorValueFromNumber:(NSNumber*) value  {
    if ((value == Nil) || ((id) value == [NSNull null])) {
        return [UIColor lightGrayColor];
    } else {
        return [self getBackgroundColorValueFromFloat:[value floatValue]];
    }
}
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
- (NSColor*) getBackgroundColorValueFromNumber:(NSNumber*) value  {
    if ((value == Nil) || ((id) value == [NSNull null])) {
        return [NSColor lightGrayColor];
    } else {
        return [self getBackgroundColorValueFromFloat:[value floatValue]];
    }
}
#endif

#if TARGET_OS_IPHONE
- (UIColor*) getBackgroundColorValueFromFloat:(float) value  {
    if (isnan(value)) {
        return [UIColor lightGrayColor];
    } else {
        if (_hasDirection) {
            if (_isDirectionIncrease) {
                if (value <= _lowThreshold) {
                    return [UIColor colorWithRed:0.0 green:0.8 blue:0.0 alpha:0.1];
                } else if (value <= _mediumThreshold) {
                    return [UIColor colorWithRed:0.8 green:0.8 blue:0.0 alpha:0.1];
                } else if (value <= _highThreshold) {
                    return [UIColor colorWithRed:0.98 green:0.65 blue:0.45 alpha:0.1];
                } else {
                    return [UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:0.1];
                }
            } else {
                if (value >= _lowThreshold) {
                    return [UIColor colorWithRed:0.0 green:0.8 blue:0.0 alpha:0.1];
                } else if (value >= _mediumThreshold) {
                    return [UIColor colorWithRed:0.8 green:0.8 blue:0.0 alpha:0.1];
                    
                } else if (value >= _highThreshold) {
                    return [UIColor colorWithRed:0.98 green:0.65 blue:0.45 alpha:0.1];
                    
                } else {
                    return [UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:0.1];
                }
                
            }
            
        }
        
        return [UIColor whiteColor];
    }
}
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
- (NSColor*) getBackgroundColorValueFromFloat:(float) value  {
    if (isnan(value)) {
        return [NSColor lightGrayColor];
    } else {
        if (_hasDirection) {
            if (_isDirectionIncrease) {
                if (value <= _lowThreshold) {
                    return [NSColor colorWithRed:0.0 green:0.8 blue:0.0 alpha:0.1];
                } else if (value <= _mediumThreshold) {
                    return [NSColor colorWithRed:0.8 green:0.8 blue:0.0 alpha:0.1];
                } else if (value <= _highThreshold) {
                    return [NSColor colorWithRed:0.98 green:0.65 blue:0.45 alpha:0.1];
                } else {
                    return [NSColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:0.1];
                }
            } else {
                if (value >= _lowThreshold) {
                    return [NSColor colorWithRed:0.0 green:0.8 blue:0.0 alpha:0.1];
                } else if (value >= _mediumThreshold) {
                    return [NSColor colorWithRed:0.8 green:0.8 blue:0.0 alpha:0.1];
                    
                } else if (value >= _highThreshold) {
                    return [NSColor colorWithRed:0.98 green:0.65 blue:0.45 alpha:0.1];
                    
                } else {
                    return [NSColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:0.1];
                }
                
            }
            
        }
        
        return [NSColor whiteColor];
    }
}
#endif

#if TARGET_OS_IPHONE

- (UIColor*) getColorValueFromNumber:(NSNumber*) value  {
    if ((value == Nil) || ((id) value == [NSNull null])) {
        return [UIColor lightGrayColor];
    } else {
        return [self getColorValueFromFloat:[value floatValue]];
   }
}
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
- (NSColor*) getColorValueFromNumber:(NSNumber*) value  {
    if ((value == Nil) || ((id) value == [NSNull null])) {
        return [NSColor lightGrayColor];
    } else {
        return [self getColorValueFromFloat:[value floatValue]];
    }
}
#endif

#if TARGET_OS_IPHONE

- (UIColor*) getColorValueFromFloat:(float) value  {
    if (isnan(value)) {
        return [UIColor lightGrayColor];
    } else {
        if (_hasDirection) {
            if (_isDirectionIncrease) {
                if (value <= _lowThreshold) {
                    return [UIColor greenColor];
                } else if (value <= _mediumThreshold) {
                    return [UIColor yellowColor];
                    
                } else if (value <= _highThreshold) {
                    return [UIColor orangeColor];
                    
                } else {
                    return [UIColor redColor];
                }
            } else {
                if (value >= _lowThreshold) {
                    return [UIColor greenColor];
                } else if (value >= _mediumThreshold) {
                    return [UIColor yellowColor];
                    
                } else if (value >= _highThreshold) {
                    return [UIColor orangeColor];
                    
                } else {
                    return [UIColor redColor];
                }
                
            }
            
        }
        
        return [UIColor lightGrayColor];
    }
}
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
- (NSColor*) getColorValueFromFloat:(float) value  {
    if (isnan(value)) {
        return [NSColor lightGrayColor];
    } else {
        if (_hasDirection) {
            if (_isDirectionIncrease) {
                if (value <= _lowThreshold) {
                    return [NSColor greenColor];
                } else if (value <= _mediumThreshold) {
                    return [NSColor yellowColor];
                    
                } else if (value <= _highThreshold) {
                    return [NSColor orangeColor];
                    
                } else {
                    return [NSColor redColor];
                }
            } else {
                if (value >= _lowThreshold) {
                    return [NSColor greenColor];
                } else if (value >= _mediumThreshold) {
                    return [NSColor yellowColor];
                    
                } else if (value >= _highThreshold) {
                    return [NSColor orangeColor];
                    
                } else {
                    return [NSColor redColor];
                }
                
            }
            
        }
        
        return [NSColor lightGrayColor];
    }
}
#endif

- (KPIColorCodeId) getColorIdFromNumber:(NSNumber*) value {
    if ((value == Nil) || ((id) value == [NSNull null])) {
        return KPIColorwhite;
    } else {
        return [self getColorIdFromFloat:[value floatValue]];
    }
}

- (KPIColorCodeId) getColorIdFromFloat:(float) value {
    if (isnan(value)) {
        return KPIColorwhite;
    } else {
        if (_hasDirection) {
            if (_isDirectionIncrease) {
                if (value <= _lowThreshold) {
                    return KPIColorgreen;
                } else if (value <= _mediumThreshold) {
                    return KPIColoryellow;
                    
                } else if (value <= _highThreshold) {
                    return KPIColororange;
                    
                } else {
                    return KPIColorred;
                }
            } else {
                if (value >= _lowThreshold) {
                    return KPIColorgreen;
                } else if (value >= _mediumThreshold) {
                    return KPIColoryellow;
                    
                } else if (value >= _highThreshold) {
                    return KPIColororange;
                    
                } else {
                    return KPIColorred;
                }
                
            }
            
        }
        
        return KPIColorgreen;
    }
}


- (NSString*) getHTMLColorFromNumber:(NSNumber*) value {
    if ((value == Nil) || ((id) value == [NSNull null])) {
        return @"white";
    } else {
        return [self getHTMLColorFromFloat:[value floatValue]];
    }
}

- (NSString*) getHTMLColorFromFloat:(float) value {
    if (isnan(value)) {
        return @"white";
    } else {
        KPIColorCodeId colorId = [self getColorIdFromFloat:value];
        
        switch (colorId) {
            case KPIColorgreen: {
                return @"green";
                break;
            }
            case KPIColoryellow: {
                return @"yellow";
                break;
            }
            case KPIColororange: {
                return @"orange";
                break;
            }
            case KPIColorred: {
                return @"red";
                break;
            }
            default: {
                return @"green";
            }
        }
    }
}


- (NSString*) KPIDescriptionToHTML {
    
    NSMutableString* HTMLKPIDomain = [[NSMutableString alloc] init];
    [HTMLKPIDomain appendFormat:@"<h2>KPI: %@ </h2>", self.name];
    [HTMLKPIDomain appendFormat:@"<p><b>Description:</b> %@<br>", self.shortDescription];
    [HTMLKPIDomain appendFormat:@"<b>Formula:</b> %@<br>", self.formula];
    [HTMLKPIDomain appendFormat:@"<b>Domain:</b> %@<br>", self.domain];
    
    NSString* theUnit;
    
    if ([self.unit isEqualToString:@"%"]) {
        [HTMLKPIDomain appendFormat:@"<b>Unit:</b> %@</p>", [self.unit stringByReplacingOccurrencesOfString:@"%" withString:@"&#37;"]];
        theUnit = [self.unit stringByReplacingOccurrencesOfString:@"%" withString:@"&#37;"];
    } else {
        [HTMLKPIDomain appendFormat:@"<b>Unit:</b> %@</p>", self.unit];
        theUnit = self.unit;
    }
    
    
    if (_hasDirection) {
        NSString* direction;
        if (_isDirectionIncrease) {
            direction = @"Severity increases when value increase";
        } else {
            direction = @"Severity increases when value decrease";
        }
        [HTMLKPIDomain appendFormat:@"<p>%@</p>", direction];
        
        [HTMLKPIDomain appendFormat:@"<table border=\"1\">"];
        [HTMLKPIDomain appendFormat:@"<tr><th>Severity</th><th>Threshold value</th></tr>"];
        [HTMLKPIDomain appendFormat:@"<tr><td>High Threshold</td><td style=\"background-color:red;text-align:center\"><b>%g%@</b></td></tr>", _highThreshold, theUnit];  
        [HTMLKPIDomain appendFormat:@"<tr><td>Medium Threshold</td><td style=\"background-color:orange;text-align:center\"><b>%g%@</b></td></tr>", _mediumThreshold, theUnit];  
        [HTMLKPIDomain appendFormat:@"<tr><td>Low Threshold</td><td style=\"background-color:yellow;text-align:center\"><b>%g%@</b></td></tr>", _lowThreshold, theUnit];  
        [HTMLKPIDomain appendFormat:@"</table>"];
    }
     return HTMLKPIDomain;
}

+(NSString*) displayCurrentAndPreviousValue:(NSString*) currentValue preValue:(NSString*) previousValue monitoringPeriod:(DCMonitoringPeriodView) theMonitoringPeriod requestDate:(NSDate*) theRequestedDate {
    
    NSString* formatString;
    
    if (previousValue == Nil) {
        previousValue = @"None";
    }
    
    switch (theMonitoringPeriod) {
        case last6Hours15MnView: {
            formatString = [NSString stringWithFormat:@"%@ (-15Min: %@)",currentValue, previousValue];
            break;
        }
        case last24HoursHourlyView: {
            formatString = [NSString stringWithFormat:@"%@ (H-1: %@)",currentValue, previousValue];
            break;
        }
        case Last7DaysDailyView: {
            formatString = [NSString stringWithFormat:@"%@: %@ (%@: %@)",
                            [DateUtility getDayMinusNumberOfDay:theRequestedDate minusDay:0 shortFormat:TRUE],
                            currentValue,
                            [DateUtility getDayMinusNumberOfDay:theRequestedDate minusDay:1 shortFormat:TRUE],
                            previousValue];
            break;
        }
        case Last4WeeksWeeklyView: {
            formatString = [NSString stringWithFormat:@"%@: %@ (%@: %@)",
                            [DateUtility getWeekMinusNumberOfWeek:theRequestedDate minusWeek:0 shortFormat:TRUE],
                            currentValue,
                            [DateUtility getWeekMinusNumberOfWeek:theRequestedDate minusWeek:1 shortFormat:TRUE],
                            previousValue];
            break;
        }
        case Last6MonthsMontlyView: {
            formatString = [NSString stringWithFormat:@"%@: %@ (%@: %@)",
                            [DateUtility getMonthMinusNumberOfMonth:theRequestedDate minusMonth:0 shortFormat:TRUE],
                            currentValue,
                            [DateUtility getMonthMinusNumberOfMonth:theRequestedDate minusMonth:1 shortFormat:TRUE],
                            previousValue];
            break;
        }
        default: {
            formatString = [NSString stringWithFormat:@"%@ (H-1: %@)",currentValue, previousValue];
            break;
        }
    }
    return formatString;
    
}


@end
