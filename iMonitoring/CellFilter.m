//
//  CellFilter.m
//  iMonitoring
//
//  Created by sébastien brugalières on 03/08/13.
//
//

#import "CellFilter.h"
#import "UserPreferences.h"
#import "CellMonitoring.h"
#import "CellBookmark+MarkedCell.h"

@interface CellFilter()

@property(nonatomic) NSArray* cellBookmark;

@property (nonatomic, readonly) Boolean isLTEFiltered;
@property (nonatomic, readonly) Boolean isGSMFiltered;
@property (nonatomic, readonly) Boolean isWCDMAFiltered;
@property (nonatomic, readonly) Boolean isMarkedCellsFiltered;
@property (nonatomic, readonly) NSString* filterCellName;

@property (nonatomic, readonly) NSDictionary<NSNumber*, NSSet<NSNumber*>*>* frequencyFilterAllTechnos;
@property (nonatomic, readonly) NSDictionary<NSNumber*,NSSet<NSString*>*>* releasesFilterAllTechnos;

@end


@implementation CellFilter

// Get the filter

- (id) init {
    if (self = [super init]) {
        UserPreferences* userPrefs  = [UserPreferences sharedInstance];
        _isLTEFiltered           = [userPrefs isCellFiltered:DCTechnologyLTE];
        _isGSMFiltered           = [userPrefs isCellFiltered:DCTechnologyGSM];
        _isWCDMAFiltered         = [userPrefs isCellFiltered:DCTechnologyWCDMA];
        _isMarkedCellsFiltered   = userPrefs.isFilterMarkedCells;
        _filterCellName          = userPrefs.FilterCellName;

        if (_isMarkedCellsFiltered) {
            _cellBookmark = [CellBookmark loadBookmarks];
        }

        _frequencyFilterAllTechnos = [userPrefs filterFrequenciesAllTechnos];
        _releasesFilterAllTechnos = [userPrefs filterReleasesAllTechnos];
    }
    return self;
}

-(Boolean) isFiltered:(CellMonitoring*) currentCell {


    if ([self isFilteredByBookmark:currentCell]) {
        return TRUE;
    }

    if ([self isFilteredByName:currentCell]) {
        return TRUE;
    }

    switch (currentCell.cellTechnology) {
        case DCTechnologyLTE: {
            if (self.isLTEFiltered) {
                if ([self isCellFilteredByFrequency:currentCell] == FALSE) {
                    return [self isCellFilteredByRelease:currentCell];
                } else {
                    return TRUE;
                }
            }
            break;
        }
        case DCTechnologyWCDMA: {
            if (self.isWCDMAFiltered) {
                if ([self isCellFilteredByFrequency:currentCell] == FALSE) {
                    return [self isCellFilteredByRelease:currentCell];
                } else {
                    return TRUE;
                }
            }
            break;
        }
        case DCTechnologyGSM: {
            if (self.isGSMFiltered) {
                if ([self isCellFilteredByFrequency:currentCell] == FALSE) {
                    return [self isCellFilteredByRelease:currentCell];
                } else {
                    return TRUE;
                }
            }
            break;
        }

        default:
            break;
    }

    return TRUE;
}

- (Boolean) isFilteredByBookmark:(CellMonitoring*) currentCell {
    if (self.isMarkedCellsFiltered == TRUE) {
        Boolean isMarked = FALSE;
        for (CellBookmark* currentBookmark in self.cellBookmark) {
            if ([currentBookmark.cellInternalName isEqualToString:currentCell.id]) {
                isMarked = TRUE;
                break;
            }
        }
        if (isMarked == FALSE) {
            return TRUE;
        }
    }

    return FALSE;
}

- (Boolean) isFilteredByName:(CellMonitoring*) currentCell {
    if ([self.filterCellName isEqualToString:@""] == FALSE) {
        NSRange rangeResult = [currentCell.id rangeOfString:self.filterCellName options:NSCaseInsensitiveSearch];
        if (rangeResult.location == NSNotFound) {
            return TRUE;
        }
    }

    return FALSE;
}

- (Boolean) isCellFilteredByFrequency:(CellMonitoring*) currentCell {

    NSSet* frequencyFilter = self.frequencyFilterAllTechnos[@(currentCell.cellTechnology)];
    if (frequencyFilter == Nil) {
        return FALSE;
    }

    NSNumber* cellFrequency = [NSNumber numberWithFloat:currentCell.normalizedDLFrequency];

    if ([frequencyFilter containsObject:cellFrequency]) {
        return TRUE;
    } else {
        return FALSE;
    }
}

- (Boolean) isCellFilteredByRelease:(CellMonitoring*) currentCell {

    NSSet<NSString*>* releaseFilter = self.releasesFilterAllTechnos[@(currentCell.cellTechnology)];
    if (releaseFilter == Nil) {
        return FALSE;
    }

    if ([releaseFilter containsObject:currentCell.releaseName]) {
        return TRUE;
    } else {
        return FALSE;
    }
}


@end
