//
//  Zone.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 07/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicTypes.h"

@interface Zone : NSObject {
    NSString* _description;
    NSString* _name;
    DCTechnologyId _techno;
    DCZoneTypeId _type;
    
}

@property (nonatomic, readonly) NSString* description;
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) DCTechnologyId techno;
@property (nonatomic, readonly) DCZoneTypeId type;

- (id) init:(NSString*) theName description:(NSString*) theDescription techno:(DCTechnologyId) theTechno type:(DCZoneTypeId) theType;

@end
