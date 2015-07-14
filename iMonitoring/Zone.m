//
//  Zone.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 07/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Zone.h"

@implementation Zone 
@synthesize description = _description;
@synthesize name = _name;
@synthesize techno = _techno;
@synthesize type = _type;

- (id) init:(NSString*) theName description:(NSString*) theDescription techno:(DCTechnologyId) theTechno type:(DCZoneTypeId) theType {
    if (self = [super init]) {
        _name = theName;
        _description = theDescription;
        _techno = theTechno;
        _type = theType;
    }
    
    return self;
}



@end
