//
//  UserDescription.m
//  iMonitoring
//
//  Created by Sébastien Brugalières on 21/10/13.
//
//

#import "UserDescription.h"

@interface UserDescription()

@property(nonatomic) NSDictionary* userData;

@end

@implementation UserDescription

- (id) initWithDictionary:(NSDictionary*) theUser {
    if (self = [super init]) {
        _userData = theUser;
    }

    return self;
}

- (NSComparisonResult)compareByName:(UserDescription *)otherObject {
    return [self.name compare:otherObject.name];
}

- (NSComparisonResult)compareByLastName:(UserDescription *)otherObject {
    return [self.lastName compare:otherObject.lastName];
}

- (NSComparisonResult)compareByRole:(UserDescription *)otherObject {
    
    
    if (self.isAdmin == TRUE) {
        if (otherObject.isAdmin == TRUE) {
            return [self compareByName:otherObject];
        } else {
            return NSOrderedAscending;
        }
    } else {
        if (otherObject.isAdmin == TRUE) {
            return NSOrderedDescending;
        } else {
            return [self compareByName:otherObject];
        }
    }
}

- (NSComparisonResult)compareByLastConnectionDate:(UserDescription *)otherObject {
    
    NSDate* source = self.LastConnectionDate;
    NSDate* other = otherObject.LastConnectionDate;
    
    if (source == Nil) {
        if (other == Nil) {
            return NSOrderedSame;
        } else {
            return NSOrderedDescending;
        }
    } else {
        if (other == Nil) {
            return NSOrderedAscending;
        } else {
            NSComparisonResult dateComparison =[source compare:other];
            if (dateComparison == NSOrderedAscending) {
                return NSOrderedDescending;
            } else if (dateComparison == NSOrderedDescending) {
                return NSOrderedAscending;
            } else {
                return NSOrderedSame;
            }
        }
    }
}


- (NSString*) name {
    return _userData[@"name"];
}

- (NSString*) userDescription {
    return _userData[@"description"];
}

- (Boolean) isAdmin {
    NSNumber* value = _userData[@"admin"];
    return [value boolValue];
}

- (NSString*) firstName {
    return _userData[@"firstName"];
}

- (NSString*) lastName {
    return _userData[@"lastName"];
}

- (NSString*) email {
    return _userData[@"EMail"];
}

- (NSDate*) creationDate {
    NSNumber* creationDateLong = _userData[@"creationDate"];
    
    // Date is reported by the server in Milliseconds from 1970
    return [NSDate dateWithTimeIntervalSince1970:(creationDateLong.unsignedLongLongValue / 1000)];
}

- (NSDate*) LastConnectionDate {
    NSNumber* creationDateLong = _userData[@"lastConnectionDate"];
    
    if (creationDateLong.longValue == 0) {
        return Nil;
    } else {
        return [NSDate dateWithTimeIntervalSince1970:(creationDateLong.unsignedLongLongValue / 1000)];
    }
}


@end
