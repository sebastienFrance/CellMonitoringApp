//
//  CellParameters2HTMLTable.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 19/03/2015.
//
//

#import "CellParameters2HTMLTable.h"
#import "Parameters.h"
#import "AttributeNameValue.h"
#import "HistoricalParameters.h"
#import "DateUtility.h"

@implementation CellParameters2HTMLTable

+(NSString*) cellParametersToHTML:(Parameters*) theParameters {
    return [CellParameters2HTMLTable cellParametersToHTML:theParameters sectionTitle:@"Cell Parameters"];
}

+(NSString*) cellParametersToHTML:(Parameters*) theParameters sectionTitle:(NSString*) title {
    
    if (theParameters == Nil) {
        return @"";
    } else {
        NSMutableString* HTMLCellParameters = [[NSMutableString alloc] init];
        [HTMLCellParameters appendFormat:@"<h2> %@ </h2>", title];
        
        [HTMLCellParameters appendString:@"<table border=\"1\">"];
        [HTMLCellParameters appendString:@"<tr>"];
        [HTMLCellParameters appendString:@"<th> Section</th>"];
        [HTMLCellParameters appendString:@"<th> Name</th>"];
        [HTMLCellParameters appendString:@"<th> Value</th>"];
        [HTMLCellParameters appendString:@"</tr>"];
        
        for (NSString* currentSectionName in theParameters.sections) {
            for (AttributeNameValue* currentAttrNameValue in [theParameters parametersFromSection:currentSectionName]) {
                NSString* attrNameValue2HTML = [CellParameters2HTMLTable cellAttrNameValue2HTML:currentSectionName attribute:currentAttrNameValue];
                [HTMLCellParameters appendString:attrNameValue2HTML];
            }
        }
        [HTMLCellParameters appendString:@"</table>"];
        
        return HTMLCellParameters;
    }
}


+(NSString*) cellAttrNameValue2HTML:(NSString*) sectionName attribute:(AttributeNameValue*) attrNameValue {
    NSMutableString* HTMLCellAttrNameValue = [[NSMutableString alloc] init];
    [HTMLCellAttrNameValue appendString:@"<tr>"];
    [HTMLCellAttrNameValue appendFormat:@"<td>%@</td>", sectionName];
    [HTMLCellAttrNameValue appendFormat:@"<td>%@</td>", attrNameValue.name];
    [HTMLCellAttrNameValue appendFormat:@"<td>%@</td>", attrNameValue.value];
    [HTMLCellAttrNameValue appendString:@"</tr>"];
    
    return HTMLCellAttrNameValue;
}

+(NSString*) exportFullParameterHistorical:(HistoricalParameters*) historicalParameters sectionTitle:(NSString*) section {
    if (historicalParameters == Nil) {
        return @"";
    } else {
        NSMutableString* htmlForHistorical = [[NSMutableString alloc] init];
        
        NSString* theTitleSection = [NSString stringWithFormat:@"Cell Parameters (%@)", [DateUtility getSimpleLocalizedDate:historicalParameters.theDate]];
        
        [htmlForHistorical appendString:[CellParameters2HTMLTable cellParametersToHTML:historicalParameters.theParameters
                                                                          sectionTitle:theTitleSection]];
        
        [htmlForHistorical appendString:[CellParameters2HTMLTable exportDiffOnlyForParameterHistorical:historicalParameters sectionTitle:section]];
        
        
        return htmlForHistorical;
    }
}

+(NSString*) exportDiffOnlyForParameterHistorical:(HistoricalParameters*) historicalParameters sectionTitle:(NSString*) section {
    if (historicalParameters == Nil) {
        return @"";
    } else {
        if (historicalParameters.differencesCount > 0) {
            NSMutableString* htmlForHistorical = [[NSMutableString alloc] init];
            
            [htmlForHistorical appendFormat:@"<h2> %@ (from %@ to %@)</h2>",section, [DateUtility getSimpleLocalizedDate:historicalParameters.theOtherDate], [DateUtility getSimpleLocalizedDate:historicalParameters.theDate]];
            
            [htmlForHistorical appendString:@"<table border=\"1\">"];
            [htmlForHistorical appendString:@"<tr>"];
            [htmlForHistorical appendString:@"<th> Section</th>"];
            [htmlForHistorical appendString:@"<th> Name</th>"];
            [htmlForHistorical appendString:@"<th> New value</th>"];
            [htmlForHistorical appendString:@"<th> Old value</th>"];
            [htmlForHistorical appendString:@"</tr>"];
            
            for (NSString* currentSection in historicalParameters.theDifferences.allKeys) {
                for (NSString* currentParameterName in historicalParameters.theDifferences[currentSection]) {
                    NSString* currentParameterValue = [historicalParameters.theParameters parameterValue:currentSection name:currentParameterName];
                    NSString* previousParameterValue = [historicalParameters.theOtherParameters parameterValue:currentSection name:currentParameterName];
                    
                    [htmlForHistorical appendString:[CellParameters2HTMLTable parameterDifferencesRow2HTML:currentSection
                                                                                             parameterName:currentParameterName
                                                                                         newParameterValue:currentParameterValue
                                                                                         oldParameterValue:previousParameterValue]];
                }
            }
            [htmlForHistorical appendString:@"</table>"];
            return htmlForHistorical;
        } else {
            return @"";
        }
    }
}

+(NSString*) parameterDifferencesRow2HTML:(NSString*) section parameterName:(NSString*) name newParameterValue:(NSString*) newValue oldParameterValue:(NSString*) oldValue {
    NSMutableString* htmlRow = [[NSMutableString alloc] init];
    
    [htmlRow appendString:@"<tr>"];
    [htmlRow appendFormat:@"<td>%@</td>", section];
    [htmlRow appendFormat:@"<td>%@</td>", name];
    [htmlRow appendFormat:@"<td>%@</td>", newValue];
    [htmlRow appendFormat:@"<td>%@</td>", oldValue];
    [htmlRow appendString:@"</tr>"];
    
    return htmlRow;

}

@end
