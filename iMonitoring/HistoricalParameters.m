//
//  HistoricalCellParametersData.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 09/03/2015.
//
//

#import "HistoricalParameters.h"
#import "AttributeNameValue.h"
#import "DateUtility.h"
#import "Parameters.h"

@interface HistoricalParameters()

@property(nonatomic) NSDictionary* theDifferences;

@end


@implementation HistoricalParameters

-(instancetype) initWithDateAndParameters:(NSDate*) date parameters:(Parameters*) theParameters {
    if (self = [super init]) {
        _theDate = date;
        _theParameters = theParameters;
        _theDifferences = [[NSDictionary alloc] init];
    }
    
    return self;
}

-(Boolean) hasParameters {
    if (self.theParameters != Nil && self.theParameters.sections.count > 0) {
        return TRUE;
    } else {
        return FALSE;
    }
}

-(NSComparisonResult) compareWithDate:(HistoricalParameters*) other {
    return [other.theDate compare:self.theDate];
}

// Objective is to ONLY compare parameters that exists in both
-(void) differencesWith:(HistoricalParameters*) otherParameters {

    if (otherParameters == Nil) {
        self.theDifferences = [[NSDictionary alloc] init];
    } else {
        _theOtherParameters = otherParameters.theParameters;
        _theOtherDate = otherParameters.theDate;

        // if the other historicalParameter doesn't exist, don't need to compare
        if (otherParameters.theParameters.sections.count > 0) {
            self.theDifferences = [self.theParameters differencesWith:otherParameters.theParameters];
        } else {
            self.theDifferences = [[NSDictionary alloc] init];
        }
    }
}

-(NSUInteger) differencesCount {
    NSUInteger count = 0;
    for (NSArray* differences in self.theDifferences.allValues) {
        count += differences.count;
    }
    
    return count;
}

-(Boolean) hasParameterInDifferences:(NSString*) sectionName parameterName:(NSString*) name {
    // look if this attribute is identifed as different
    NSArray* diffParametersInSection = self.theDifferences[sectionName];
    if (diffParametersInSection == Nil || diffParametersInSection.count == 0) {
        // it's not different so we can display the current value only
        return FALSE;
    } else {
        for (NSString* currentAttName in diffParametersInSection) {
            if ([currentAttName isEqualToString:name]) {
                return TRUE;
            }
        }
        
        return FALSE;
    }
}


@end
