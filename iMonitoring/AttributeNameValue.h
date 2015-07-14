//
//  AttributeNameValue.h
//  iMonitoring
//
//  Created by sébastien brugalières on 07/01/13.
//
//

#import <Foundation/Foundation.h>

@interface AttributeNameValue : NSObject

@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSString* value;
@property (nonatomic, readonly) NSString* section;

- (id) initWithNameValue:(NSString*) theName value:(NSString*) theValue section:(NSString*) theSection;

-(Boolean) isEqualWith:(AttributeNameValue*) otherAttributeName;

@end
