//
//  Parameters.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 12/03/2015.
//
//

#import <Foundation/Foundation.h>

@class AttributeNameValue;

@interface Parameters : NSObject

@property(nonatomic,readonly) NSArray* sections;

#pragma mark - Append parameters
-(void) appendParameter:(NSString*) sectionName name:(NSString*) parameterName value:(NSString*) parameterValue;
-(void) appendAttributeNameValue:(AttributeNameValue*) attrNameValue;

#pragma mark -Accessors
-(NSString*) parameterValue:(NSString*) sectionName name:(NSString*) parameterName;
-(NSArray*) parametersFromSection:(NSString*) sectionName;
-(NSDictionary*) parametersIndexedByNameFromSection:(NSString*) sectionName;

#pragma mark - Utility
// Gives for each Section the list of parameter name for which values are differents
// index: SectionName  value: NSArray of NSString (name of the parameters)
-(NSDictionary*) differencesWith:(Parameters*) other;

@end
