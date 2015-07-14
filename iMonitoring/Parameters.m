//
//  Parameters.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 12/03/2015.
//
//

#import "Parameters.h"
#import "AttributeNameValue.h"

@interface Parameters()

// Index: Section Name Value: NSArray of AttributeNameValue
@property(nonatomic) NSMutableDictionary* parametersOrderedBySection;

@end


@implementation Parameters

-(instancetype) init {
    if (self = [super init]) {
        _parametersOrderedBySection = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

#pragma mark - Append Parameter

-(void) appendParameter:(NSString*) sectionName name:(NSString*) parameterName value:(NSString*) parameterValue {
    if (sectionName != Nil && parameterName != Nil && parameterValue != Nil) {
        AttributeNameValue* newParameter = [[AttributeNameValue alloc] initWithNameValue:parameterName value:parameterValue section:sectionName];
        [self appendParameterInSection:sectionName attrNameValue:newParameter];
    }
}

-(void) appendAttributeNameValue:(AttributeNameValue*) attrNameValue {
    if (attrNameValue != Nil) {
        [self appendParameterInSection:attrNameValue.section attrNameValue:attrNameValue];
    }
}

-(void) appendParameterInSection:(NSString*) sectionName attrNameValue:(AttributeNameValue*) nameValue {
    NSMutableArray* nameValueList = self.parametersOrderedBySection[sectionName];
    if (nameValueList == Nil) {
        nameValueList = [[NSMutableArray alloc] init];
        self.parametersOrderedBySection[sectionName] = nameValueList;
    }
    
    [nameValueList addObject:nameValue];
}

#pragma mark - Accessors

-(NSString*) parameterValue:(NSString*) sectionName name:(NSString*) parameterName {
    if (sectionName != Nil && parameterName != Nil) {
        NSArray* attrNameValueList = self.parametersOrderedBySection[sectionName];
        for (AttributeNameValue* currentAttrNameValue in attrNameValueList) {
            if ([currentAttrNameValue.name isEqualToString:parameterName]) {
                return currentAttrNameValue.value;
            }
        }
        return Nil;
    } else {
        return Nil;
    }
}

-(NSArray*) parametersFromSection:(NSString*) sectionName {
    return self.parametersOrderedBySection[sectionName];
}

-(NSDictionary*) parametersIndexedByNameFromSection:(NSString*) sectionName {
    NSMutableDictionary* parametersByName = [[NSMutableDictionary alloc] init];
    for (AttributeNameValue* currentAttrNameValue in self.parametersOrderedBySection[sectionName]) {
        parametersByName[currentAttrNameValue.name] = currentAttrNameValue;
    }
    return parametersByName;
}

-(NSArray*) sections {
    return self.parametersOrderedBySection.allKeys;
}

#pragma mark - Differences between 2 Parameters

-(NSDictionary*) differencesWith:(Parameters*) other {
    
    NSMutableDictionary* allParametersDifferencesPerSection = [[NSMutableDictionary alloc] init];
    
    for (NSString* currentSection in self.sections) {
        NSArray* paramDifferences = [self buildDifferencesForSection:currentSection previous:other];
        if (paramDifferences != Nil && paramDifferences.count > 0) {
            allParametersDifferencesPerSection[currentSection] = paramDifferences;
        }
    }
    
    return allParametersDifferencesPerSection;
}

// List of differences ordered by parameter name
-(NSArray*) buildDifferencesForSection:(NSString*) sectionName previous:(Parameters*) other {
 
    NSArray* currentParameters = [self parametersFromSection:sectionName];
    if (currentParameters == Nil) {
        return Nil;
    }
    
    NSDictionary* previousParameters = [other parametersIndexedByNameFromSection:sectionName];
    if (previousParameters == Nil) {
        return Nil;
    }
    
    NSMutableArray* parameterList = [[NSMutableArray alloc] init];
    
    for (AttributeNameValue* currentParameter in currentParameters) {
        AttributeNameValue* previousParameter = previousParameters[currentParameter.name];
        if (previousParameter != Nil) {
            if ([currentParameter.value isEqualToString:previousParameter.value] == FALSE) {
                [parameterList addObject:currentParameter.name];
            }
        }
    }
    return parameterList;
}

@end
