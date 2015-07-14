//
//  HistoricalCellParametersData.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 09/03/2015.
//
//

#import <Foundation/Foundation.h>

@class Parameters;

@interface HistoricalParameters : NSObject

@property(nonatomic, readonly) NSDate* theDate;

// Return True when no data is available for the date
@property(nonatomic, readonly) Boolean hasParameters;

// Gives for each Section the list of parameter name for which values are differents
// index: SectionName  value: NSArray of NSString (name of the parameters)
@property(nonatomic, readonly) NSDictionary* theDifferences;

// Original parameters
@property(nonatomic, readonly) Parameters* theParameters;

// Parameters used to build the differences
@property(nonatomic, readonly) Parameters* theOtherParameters;
@property(nonatomic, readonly) NSDate* theOtherDate;


-(instancetype) initWithDateAndParameters:(NSDate*) date parameters:(Parameters*) theParameters;

-(NSUInteger) differencesCount;
-(void) differencesWith:(HistoricalParameters*) otherParameters;
-(Boolean) hasParameterInDifferences:(NSString*) sectionName parameterName:(NSString*) name;

-(NSComparisonResult) compareWithDate:(HistoricalParameters*) other;

@end
