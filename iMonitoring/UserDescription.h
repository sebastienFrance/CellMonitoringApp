//
//  UserDescription.h
//  iMonitoring
//
//  Created by Sébastien Brugalières on 21/10/13.
//
//

#import <Foundation/Foundation.h>

@interface UserDescription : NSObject

@property(nonatomic) NSString* name;
@property(nonatomic) NSString* userDescription;
@property(nonatomic) Boolean isAdmin;
@property(nonatomic) NSString* firstName;
@property(nonatomic) NSString* lastName;
@property(nonatomic) NSString* email;
@property(nonatomic) NSDate* creationDate;
@property(nonatomic) NSDate* LastConnectionDate;

- (id) initWithDictionary:(NSDictionary*) cellDictionary;

#pragma mark - Comparisons

- (NSComparisonResult)compareByName:(UserDescription *)otherObject;
- (NSComparisonResult)compareByLastName:(UserDescription *)otherObject;
- (NSComparisonResult)compareByRole:(UserDescription *)otherObject;
- (NSComparisonResult)compareByLastConnectionDate:(UserDescription *)otherObject;

@end
