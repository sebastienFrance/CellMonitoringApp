//
//  CellBookmarks+MarkedCell.m
//  iMonitoring
//
//  Created by sébastien brugalières on 03/03/13.
//
//

#import "CellBookmark+MarkedCell.h"
#import "Utility.h"
#import "CellMonitoring.h"
#import "DataManagement.h"

@implementation CellBookmark (MarkedCell)

static NSArray* _cacheCellBookmark = Nil;

#pragma mark - Create CellBookmark in DB

+ (CellBookmark*) createCellBookmark:(CellMonitoring*) theCell comments:(NSString*) theComments color:(UIColor*) theColor {

    UIManagedDocument* managedDocument = [DataManagement sharedInstance].managedDocument;
    CellBookmark *bookMark = (CellBookmark *)[NSEntityDescription insertNewObjectForEntityForName:@"CellBookmark" inManagedObjectContext:managedDocument.managedObjectContext];

    bookMark.cellInternalName = theCell.id;
    bookMark.techno = @(theCell.cellTechnology);
    bookMark.latitude = @(theCell.coordinate.latitude);
    bookMark.longitude = @(theCell.coordinate.longitude);
    bookMark.comment = theComments;
    bookMark.creationDate = [NSDate date];
    bookMark.color = theColor;
    
    [[DataManagement sharedInstance] save];
    _cacheCellBookmark = Nil;
    return bookMark;
 }

#pragma mark - Load data from DB

// Return an Array that contains the Cellbookmark stored in the DB
// If the DB is empty then an empty array is returned
+ (NSArray<CellBookmark*>*) loadBookmarks {
    
    if (_cacheCellBookmark == Nil) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CellBookmark"];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"cellInternalName" ascending:NO];
        request.sortDescriptors = @[sortDescriptor];
        
        
        UIManagedDocument* managedDocument = [DataManagement sharedInstance].managedDocument;
        NSError *error = nil;
        NSArray* result = [managedDocument.managedObjectContext executeFetchRequest:request error:&error];
        if (result == Nil) {
            NSLog(@"%s: Error when loading CellBookmark from DB: %@",__PRETTY_FUNCTION__,[error localizedDescription]);
            return [[NSArray alloc] init];
        }
        _cacheCellBookmark = result;
    }
    

    return _cacheCellBookmark;
}


+ (CellBookmark*) findCellBookmark:(NSString*) cellInternalName {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CellBookmark"];
    
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

+ (Boolean) isCellMarked:(CellMonitoring*) theCell {
    NSArray* cellBookmarks = [CellBookmark loadBookmarks];
    for (CellBookmark* currentCellBookmark in cellBookmarks) {
        if ([currentCellBookmark.cellInternalName isEqualToString:theCell.id]) {
            return TRUE;
        }
    }
    return FALSE;
}

#pragma mark - Delete CellBookmark from DB

+ (void) remove:(CellBookmark*) bookmark{
    [[DataManagement sharedInstance] remove:bookmark];
    _cacheCellBookmark = Nil;
}

+ (void) removeCellBookmark:(NSString*) cellId {
    CellBookmark* cellToBeDeleted = [CellBookmark findCellBookmark:cellId];
    [[DataManagement sharedInstance] remove:cellToBeDeleted];
    _cacheCellBookmark = Nil;
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

- (NSComparisonResult)compareByName:(CellBookmark *)otherObject {
    return [self.cellInternalName compare:otherObject.cellInternalName];
}

- (NSComparisonResult)compareByColor:(CellBookmark *)otherObject {
    NSUInteger sourceColorCode = [Utility getColorCodeForOrdering:self.color];
    NSUInteger targetColorCode = [Utility getColorCodeForOrdering:otherObject.color];
    
    if (sourceColorCode == targetColorCode) return NSOrderedSame;
    
    if (sourceColorCode < targetColorCode) return NSOrderedAscending;
    else return NSOrderedDescending;
    
    
}


- (NSComparisonResult)compareByTechnology:(CellBookmark *)otherObject {
    DCTechnologyId sourceTechno = [self.techno unsignedIntegerValue];
    DCTechnologyId targetTechno = [otherObject.techno unsignedIntegerValue];
    
    
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



- (NSComparisonResult)compareByDate:(CellBookmark *)otherObject {
    return [self.creationDate compare:otherObject.creationDate];
}


@end
