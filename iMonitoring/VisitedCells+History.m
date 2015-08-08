//
//  VisitedCells+History.m
//  iMonitoring
//
//  Created by sébastien brugalières on 30/04/13.
//
//

#import "VisitedCells+History.h"
#import "Utility.h"
#import "CellMonitoring.h"
#import "DataManagement.h"
#import <MapKit/MapKit.h>

@implementation VisitedCells (History)


#define MAX_VISITED_CELLS 50

+ (VisitedCells*) createVisitedCells:(CellMonitoring *)theCell {
    VisitedCells* existingCell = [VisitedCells findVisitedCells:theCell.id];
    if (existingCell == Nil) {        
        NSUInteger visitedCellsCount = [VisitedCells getVisitedCellsCount];
        if (visitedCellsCount >= MAX_VISITED_CELLS) {
            [VisitedCells deleteOldestVisitedCells];
        }
        
        UIManagedDocument* managedDocument = [DataManagement sharedInstance].managedDocument;
        VisitedCells *visitedCells = (VisitedCells *)[NSEntityDescription insertNewObjectForEntityForName:@"VisitedCells" inManagedObjectContext:managedDocument.managedObjectContext];
        
        [visitedCells initializeFromCell:theCell];

        [[DataManagement sharedInstance] save];
        return  visitedCells;
    } else {
       // increment the visited count and update the lastVisited date
        existingCell.visitedCount = @(existingCell.visitedCount.unsignedIntegerValue +1);
        existingCell.lastVisitedDate = [NSDate date];
        [[DataManagement sharedInstance] save];
        return existingCell;
    }
}

- (void) initializeFromCell:(CellMonitoring*) theCell {
    self.cellInternalName = theCell.id;
    self.techno = @(theCell.cellTechnology);
    self.latitude = @(theCell.coordinate.latitude);
    self.longitude = @(theCell.coordinate.longitude);
    self.lastVisitedDate = [NSDate date];
    self.visitedCount = [NSNumber numberWithUnsignedInteger:1];
}

#pragma mark - Database operations

+ (void) deleteOldestVisitedCells {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"VisitedCells"];
    
    fetchRequest.fetchLimit = 1;
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"lastVisitedDate" ascending:YES]];
    
    NSError *error = nil;
    
    UIManagedDocument* managedDocument = [DataManagement sharedInstance].managedDocument;
    NSArray* result = [managedDocument.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (result == Nil) {
        NSLog(@"%s: Error when searching oldest VisitedCells from DB: %@",__PRETTY_FUNCTION__,[error localizedDescription]);
    }

    VisitedCells* toBeDeleted = result.lastObject;
    
    [[DataManagement sharedInstance] remove:toBeDeleted];

}

+ (NSUInteger) getVisitedCellsCount {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VisitedCells"];
    
    UIManagedDocument* managedDocument = [DataManagement sharedInstance].managedDocument;
    NSError *error = nil;
    NSUInteger count = [managedDocument.managedObjectContext countForFetchRequest:request error:&error];
    if (count == NSNotFound) {
        NSLog(@"%s: Error when counting VisitedCells from DB: %@",__PRETTY_FUNCTION__,[error localizedDescription]);
        return 0;
    }
    
    return count;
}

#pragma mark - Load data from DB

// Return an Array that contains the Cellbookmark stored in the DB
// If the DB is empty then an empty array is returned
+ (NSArray<VisitedCells*>*) loadVisitedCells {
    
        
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VisitedCells"];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"cellInternalName" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];
    
    
    UIManagedDocument* managedDocument = [DataManagement sharedInstance].managedDocument;
    NSError *error = nil;
    NSArray* result = [managedDocument.managedObjectContext executeFetchRequest:request error:&error];
    if (result == Nil) {
        NSLog(@"%s: Error when loading VisitedCells from DB: %@",__PRETTY_FUNCTION__,[error localizedDescription]);
        return [[NSArray alloc] init];
    }
    
    return result;
}


+ (VisitedCells*) findVisitedCells:(NSString*) cellInternalName {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VisitedCells"];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"cellInternalName" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];
    
    NSPredicate* thePredicate = [NSPredicate predicateWithFormat:@"cellInternalName = %@", cellInternalName];
    request.predicate = thePredicate;
    
    UIManagedDocument* managedDocument = [DataManagement sharedInstance].managedDocument;
    
    NSError *error = nil;
    NSArray *result = [managedDocument.managedObjectContext executeFetchRequest:request error:&error];
    if ((result == Nil) || (result.count != 1)) {
        return Nil;
    } else {
        return result.lastObject;
    }
}

#pragma mark - Accessors

- (CLLocationCoordinate2D) theCellCoordinate {
    CLLocationCoordinate2D cellCoordinate;
    
    cellCoordinate.latitude = [self.latitude doubleValue];
    cellCoordinate.longitude = [self.longitude doubleValue];
    
    return cellCoordinate;
}

- (DCTechnologyId) theTechnology {
    return [self.techno unsignedIntegerValue];
}

#pragma mark - Comparison

- (NSComparisonResult)compareByName:(VisitedCells *)otherObject {
    return [self.cellInternalName compare:otherObject.cellInternalName];
}

- (NSComparisonResult)compareByMostVisited:(VisitedCells *)otherObject {
    
    NSComparisonResult result = [self.visitedCount compare:otherObject.visitedCount];
    if (result == NSOrderedDescending) {
        return NSOrderedAscending;
    } else if (result == NSOrderedAscending) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
    
}

- (NSComparisonResult)compareByTechnology:(VisitedCells *)otherObject {
    DCTechnologyId sourceTechno = self.techno.unsignedIntegerValue;
    DCTechnologyId targetTechno = otherObject.techno.unsignedIntegerValue;
    
    if (sourceTechno == targetTechno) {
        return NSOrderedSame;
    } else if (sourceTechno == DCTechnologyLTE) {
        return NSOrderedAscending;
    } else if (sourceTechno == DCTechnologyWCDMA) {
        if (targetTechno == DCTechnologyGSM) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    } else if (sourceTechno == DCTechnologyGSM) {
        return NSOrderedDescending;
    } else {
        return NSOrderedDescending;
    }
}

- (NSComparisonResult)compareByLastVisited:(VisitedCells *)otherObject {
    NSComparisonResult result = [self.lastVisitedDate compare:otherObject.lastVisitedDate];
    if (result == NSOrderedAscending) {
        return NSOrderedDescending;
    } else if (result == NSOrderedDescending) {
        return NSOrderedAscending;
    } else {
        return NSOrderedSame;
    }
}



@end
