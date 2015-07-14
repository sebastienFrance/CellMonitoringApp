//
//  CellParameters2HTMLTable.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 19/03/2015.
//
//

#import <Foundation/Foundation.h>

@class Parameters;
@class HistoricalParameters;

@interface CellParameters2HTMLTable : NSObject

+(NSString*) cellParametersToHTML:(Parameters*) theParameters;

+(NSString*) exportFullParameterHistorical:(HistoricalParameters*) historicalParameters sectionTitle:(NSString*) section;
+(NSString*) exportDiffOnlyForParameterHistorical:(HistoricalParameters*) historicalParameters sectionTitle:(NSString*) section;

@end
