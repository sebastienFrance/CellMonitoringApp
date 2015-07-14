//"
//  CellParameterUtility.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 09/03/2015.
//
//

#import "CellParameterUtility.h"
#import "AttributeNameValue.h"
#import "Parameters.h"

@implementation CellParameterUtility

static const NSString* PARAM_ATTR_NAME = @"name";
static const NSString* PARAM_ATTR_VALUE = @"value";
static const NSString* PARAM_ATTR_SECTION = @"section";



+(Parameters*) buildParameters:(NSArray*) cellParameters {
    Parameters* parameterList = [[Parameters alloc] init];
    
    for (NSDictionary* currAttrNameValue in cellParameters) {
        [parameterList appendParameter:currAttrNameValue[PARAM_ATTR_SECTION] name:currAttrNameValue[PARAM_ATTR_NAME] value:currAttrNameValue[PARAM_ATTR_VALUE]];
    }
    
    return parameterList;
}



@end
