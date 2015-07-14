//
//  RegionBookmark+MarkedRegion.m
//  iMonitoring
//
//  Created by sébastien brugalières on 05/03/13.
//
//

#import "RegionBookmark+MarkedRegion.h"

#import <MapKit/MapKit.h>
#import "Utility.h"
#import "DataManagement.h"

@implementation RegionBookmark (MarkedRegion)

#pragma mark - Create RegionBookmark from DB
+ (RegionBookmark*) createMarkedRegion:(MKMapCamera*) theRegion color:(UIColor*) theColor name:(NSString*) theName {

    UIManagedDocument* managedDocument = [DataManagement sharedInstance].managedDocument;

    RegionBookmark *bookMark = (RegionBookmark *)[NSEntityDescription insertNewObjectForEntityForName:@"RegionBookmark" inManagedObjectContext:managedDocument.managedObjectContext];
    
    [bookMark setTheRegion:theRegion];
    bookMark.color = theColor;
    bookMark.creationDate = [NSDate date];
    bookMark.name = theName;
     
    [[DataManagement sharedInstance] save];
    
    return bookMark;
}

#pragma mark - Delete RegionBookmark from DB
+ (void) remove:(RegionBookmark*) bookmark {
    [[DataManagement sharedInstance] remove:bookmark];
}

#pragma mark - Load data from DB
// Return an Array that contains the Regionbookmark stored in the DB
// If the DB is empty then an empty array is returned
+ (NSArray*) loadBookmarks {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"RegionBookmark"];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];

    UIManagedDocument* managedDocument = [DataManagement sharedInstance].managedDocument;

    NSError* error = nil;
    NSArray* result = [[managedDocument.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (result == Nil) {
        NSLog(@"%s: Error when loading RegionBookmark from DB: %@",__PRETTY_FUNCTION__,[error localizedDescription]);
        return [[NSArray alloc] init];
    }
    return result;
}

#pragma mark - Accessors
- (void) setTheRegion:(MKMapCamera*)theRegion {
    self.latitude = @(theRegion.centerCoordinate.latitude);
    self.longitude = @(theRegion.centerCoordinate.longitude);
    self.altitude = @(theRegion.altitude);
    self.heading = @(theRegion.heading);
    self.pitch = @(theRegion.pitch);
}

- (MKMapCamera*) theRegion {
    
    
    CLLocationCoordinate2D regionCoordinate;
    regionCoordinate.latitude = [self latitude].doubleValue;
    regionCoordinate.longitude = [self longitude].doubleValue;
    
    MKMapCamera *regionCamera = [MKMapCamera cameraLookingAtCenterCoordinate:regionCoordinate
                                                        fromEyeCoordinate:regionCoordinate
                                                              eyeAltitude:[self altitude].doubleValue];
    
    regionCamera.pitch = [self pitch].floatValue;
    regionCamera.heading = [self heading].doubleValue;
    
    return regionCamera;
}

#pragma mark - Comparison
- (NSComparisonResult)compareByName:(RegionBookmark *)otherObject {
    return [self.name compare:otherObject.name];
}

- (NSComparisonResult)compareByColor:(RegionBookmark *)otherObject {
    NSUInteger sourceColorCode = [Utility getColorCodeForOrdering:self.color];
    NSUInteger targetColorCode = [Utility getColorCodeForOrdering:otherObject.color];
    
    if (sourceColorCode == targetColorCode) return NSOrderedSame;
    
    if (sourceColorCode < targetColorCode) return NSOrderedAscending;
    else return NSOrderedDescending;
}

- (NSComparisonResult)compareByTechnology:(RegionBookmark*)otherObject {
    return NSOrderedSame;
}

- (NSComparisonResult)compareByDate:(RegionBookmark *)otherObject {
    return [self.creationDate compare:otherObject.creationDate];
}


@end
