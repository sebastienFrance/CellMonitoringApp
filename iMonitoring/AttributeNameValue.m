//
//  AttributeNameValue.m
//  iMonitoring
//
//  Created by sébastien brugalières on 07/01/13.
//
//

#import "AttributeNameValue.h"

@implementation AttributeNameValue


- (id) initWithNameValue:(NSString*) theName value:(NSString*) theValue section:(NSString*) theSection {
    if (self = [super init]) {
        _name = theName;
        _value = theValue;
        _section = theSection;
    }
    return self;
}

-(Boolean) isEqualWith:(AttributeNameValue*) otherAttributeName {
    if ([self.name isEqualToString:otherAttributeName.name] &&
        [self.value isEqualToString:otherAttributeName.value] &&
        [self.section isEqualToString:otherAttributeName.section]) {
        return TRUE;
    } else {
        return FALSE;
    }
}


@end
