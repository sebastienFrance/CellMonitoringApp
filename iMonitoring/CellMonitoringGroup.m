//
//  CellMonitoringGroup.m
//  iMonitoring
//
//  Created by sébastien brugalières on 11/04/13.
//
//

#import "CellMonitoringGroup.h"
#import "CellMonitoring.h"
#import "AzimuthsOverlay.h"
#import "UserPreferences.h"
#import "AddressBook/AddressBook.h"
#import "CellBookmark+MarkedCell.h"
#import "CellFilter.h"

@interface CellMonitoringGroup()


@property (nonatomic) CLLocationCoordinate2D groupCoordinate;

@property (nonatomic) NSUInteger LTECellCounter;
@property (nonatomic) NSUInteger WCDMACellCounter;
@property (nonatomic) NSUInteger GSMCellCounter;

@property (nonatomic) NSArray* cellAzimuthOverlays;

@property (nonatomic) NSMutableArray* allCellsFromGroup;
@property (nonatomic) NSArray* filteredCells;

@property (nonatomic) AzimuthsOverlay* overlay;


@end

@implementation CellMonitoringGroup

- (id) initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if (self = [super init]) {
        _groupCoordinate = coordinate;
        _allCellsFromGroup = [[NSMutableArray alloc] init];
        _cellAzimuthOverlays = Nil;
        _LTECellCounter = _WCDMACellCounter = _GSMCellCounter = 0;
        _filteredCells = Nil;
    }
    return self;
}

- (void) addCell:(CellMonitoring*) theCell {
    [self.allCellsFromGroup addObject:theCell];
    
// Optimization, should not be done each time a new cell is added
//    [self refreshCellGroupFromFilter];
}

- (void) commit {
    CellFilter* currentCellFilter = [[CellFilter alloc] init];

    [self refreshCellGroupFromFilter:currentCellFilter];
}

- (NSUInteger) getFilteredCellCountForTechnoId:(DCTechnologyId) technology {
    switch (technology) {
        case DCTechnologyLTE: {
            return self.LTECellCounter;
        }
        case DCTechnologyWCDMA: {
            return self.WCDMACellCounter;
        }
        case DCTechnologyGSM: {
            return self.GSMCellCounter;
        }
        default: {
            return 0;
        }
    }
}

- (NSArray*) getFilteredCellsForTechnoId:(DCTechnologyId) technology {
    NSMutableArray* cellForTechno = [[NSMutableArray alloc] initWithCapacity:self.filteredCells.count];
    
    for (CellMonitoring* currentCell in self.filteredCells) {
        if (currentCell.cellTechnology == technology) {
            [cellForTechno addObject:currentCell];
        }
    }
    return cellForTechno;
}

- (NSArray*) getAllCellsForTechnoId:(DCTechnologyId) technology {
    NSMutableArray* cellForTechno = [[NSMutableArray alloc] initWithCapacity:self.filteredCells.count];

    for (CellMonitoring* currentCell in self.allCellsFromGroup) {
        if (currentCell.cellTechnology == technology) {
            [cellForTechno addObject:currentCell];
        }
    }
    return cellForTechno;

}

- (Boolean) hasVisibleCells {
    if (self.filteredCells.count > 0) {
        return TRUE;
    } else {
        return FALSE;
    }
}

- (Boolean) hasTimezone {
    if (_timezone == Nil) {
        return FALSE;
    } else {
        return TRUE;
    }
}


- (void) initializeTimezone:(NSTimeZone *)timezone {

    _timezone = [timezone localizedName:NSTimeZoneNameStyleGeneric
                                    locale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
   _timezoneAbbreviation = [timezone localizedName:NSTimeZoneNameStyleShortStandard
                                                locale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
}

- (Boolean) hasAddress {
    if ((self.street == Nil) || (self.city == Nil) || (self.country == Nil)) {
        return FALSE;
    } else {
        return TRUE;
    }
}

- (void) initialiazeAddress:(CLPlacemark *)currentPlacemark {
    //85 Larkspur ...
    //Brewster NY 10548
    //USA
    _cellPlacemark = [[MKPlacemark alloc] initWithPlacemark:currentPlacemark];
    NSString* subThoroughfare = currentPlacemark.subThoroughfare;
    if (([subThoroughfare isEqualToString:@"(null)"]) || (subThoroughfare == Nil)) {
        subThoroughfare = @"";
    }
    
    NSString* thoroughfare = currentPlacemark.thoroughfare;
    if (([thoroughfare isEqualToString:@"(null)"]) || (thoroughfare == Nil))  {
        thoroughfare = @"";
    }
    
    
    NSString* theStreet = [NSString stringWithFormat:@"%@ %@", subThoroughfare, thoroughfare];
    NSString*  result = [theStreet stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _street = result;
    
    NSString* theCity = [NSString stringWithFormat:@"%@ %@ %@",  currentPlacemark.locality,currentPlacemark.administrativeArea, currentPlacemark.postalCode];
    result = [theCity stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _city = theCity;
    
    _country = [NSString stringWithFormat:@"%@",currentPlacemark.country];

    [self initializeTimezone:currentPlacemark.timeZone];
}

+ (MKCoordinateRegion) getRegionThatFitsCells:(NSArray*) theCellGroupList {
    if ((theCellGroupList == Nil) || (theCellGroupList.count == 0)) {
        MKCoordinateRegion theRegion;
        theRegion.center.latitude = 0.0;
        theRegion.center.longitude = 0.0;
        theRegion.span.latitudeDelta = 10.0 ;
        theRegion.span.longitudeDelta = 10.0 ;
        
        return theRegion;
    }

    NSMutableArray* filteredList = [[NSMutableArray alloc] init];
    
    for (CellMonitoringGroup* currentGroup in theCellGroupList) {
        [filteredList addObjectsFromArray:currentGroup.filteredCells];
    }
    
    return [CellMonitoring getRegionThatFitsCells:filteredList];
}

- (AzimuthsOverlay*) azimuthOverlays {
    return self.overlay;
}

- (NSArray*) filteredCells {
    if (_filteredCells == Nil) {
        CellFilter* currentCellFilter = [[CellFilter alloc] init];
        [self refreshCellGroupFromFilter:currentCellFilter];
    }
    return _filteredCells;
}

- (NSArray*) refreshCellGroupFromFilter:(CellFilter*) cellFilter {
     
    NSMutableArray* newfilteredCells = [[NSMutableArray alloc] init];
    
    self.LTECellCounter = self.WCDMACellCounter = self.GSMCellCounter = 0;

    for (CellMonitoring* currentCell in self.allCellsFromGroup) {

        if ([cellFilter isFiltered:currentCell] == FALSE) {
            switch (currentCell.cellTechnology) {
                case DCTechnologyLTE: {
                    self.LTECellCounter++;
                    break;
                }
                case DCTechnologyWCDMA: {
                    self.WCDMACellCounter++;
                    break;
                }
                case DCTechnologyGSM: {
                    self.GSMCellCounter++;
                    break;
                }
                default: {
                    NSLog(@"%s Error: unknown techno for cell", __PRETTY_FUNCTION__);
                }
            }

            [newfilteredCells addObject:currentCell];
        }
    }
        
    self.filteredCells = newfilteredCells;
    
    NSUInteger sectorRadius = [UserPreferences sharedInstance].SectorRadius;
    Boolean displaySectorAngle = [UserPreferences sharedInstance].isDisplaySectorAngle;
    
    if (self.filteredCells.count > 0) {
        self.overlay = [[AzimuthsOverlay alloc] initWithCell:self.filteredCells azimuthRadius:sectorRadius displaySectorAngle:displaySectorAngle];
    } else {
        self.overlay = Nil;
    }

    return newfilteredCells;
}

/*
- (NSArray*) refreshCellGroupFromFilter:(CellFilter*) cellFilter {

    Boolean hasFilterCellName = TRUE;
    if ([cellFilter.filterCellName isEqualToString:@""]) {
        hasFilterCellName = FALSE;
    }

    NSMutableArray* newfilteredCells = [[NSMutableArray alloc] init];

    self.LTECellCounter = self.WCDMACellCounter = self.GSMCellCounter = 0;

    NSArray* cellBookmark = Nil;
    if (cellFilter.isMarkedCellsFiltered == TRUE) {
        cellBookmark = [CellBookmark loadBookmarks];
    }

    for (CellMonitoring* currentCell in self.allCellsFromGroup) {
        if (cellFilter.isMarkedCellsFiltered == TRUE) {
            Boolean isMarked = FALSE;
            for (CellBookmark* currentBookmark in cellBookmark) {
                if ([currentBookmark.cellInternalName isEqualToString:currentCell.id]) {
                    isMarked = TRUE;
                    break;
                }
            }
            if (isMarked == FALSE) {
                continue;
            }
        }

        if (hasFilterCellName) {
            NSRange rangeResult = [currentCell.id rangeOfString:cellFilter.filterCellName options:NSCaseInsensitiveSearch];
            if (rangeResult.location == NSNotFound) {
                continue;
            }
        }

        Boolean cellToBeAdded = FALSE;
        switch (currentCell.cellTechnology) {
            case DCTechnologyLTE: {
                if (cellFilter.isLTEFiltered) {
                    cellToBeAdded = TRUE;
                    self.LTECellCounter++;
                }
                break;
            }
            case DCTechnologyWCDMA: {
                if (cellFilter.isWCDMAFiltered) {
                    cellToBeAdded = TRUE;
                    self.WCDMACellCounter++;
                }
                break;
            }
            case DCTechnologyGSM: {
                if (cellFilter.isGSMFiltered) {
                    cellToBeAdded = TRUE;
                    self.GSMCellCounter++;
                }
                break;
            }

            default:
                break;
        }

        if (cellToBeAdded == TRUE) {
            [newfilteredCells addObject:currentCell];


        }
    }

    self.filteredCells = newfilteredCells;

    NSUInteger sectorRadius = [UserPreferences sharedInstance].SectorRadius;
    Boolean displaySectorAngle = [UserPreferences sharedInstance].isDisplaySectorAngle;

    if (self.filteredCells.count > 0) {
        self.overlay = [[AzimuthsOverlay alloc] initWithCell:self.filteredCells azimuthRadius:sectorRadius displaySectorAngle:displaySectorAngle];
    } else {
        self.overlay = Nil;
    }

    return newfilteredCells;
}
*/


#pragma mark - MKAnnotation protocol

- (CLLocationCoordinate2D)coordinate {
    return self.groupCoordinate;
}

// required if you set the MKPinAnnotationView's "canShowCallout" property to YES
- (NSString *)title
{
    if (self.filteredCells.count == 1) {
        CellMonitoring* theCell = self.filteredCells[0];
        return theCell.id;
    }
    
    if ([self isMultiTechnoGroup]) {
        return @"Multi-Techno";       
    } else {
        if (self.filteredCells.count == 0) {
            return @"No Cells";
        }
        
        CellMonitoring* firstCell = self.filteredCells[0];
        return firstCell.techno;       
    }
}

// optional
- (NSString *)subtitle
{
    if (self.filteredCells.count == 1) {
        CellMonitoring* currentCell = self.filteredCells[0];
        return currentCell.techno;
    }

    NSMutableString* subTitle = [[NSMutableString alloc] init];
    
    Boolean appendSeparator = FALSE;
    if (self.LTECellCounter > 0) {
        [subTitle appendFormat:@"LTE(%ld)", (unsigned long)self.LTECellCounter];
        appendSeparator = TRUE;
    }
    
    if (self.WCDMACellCounter > 0) {
        if (appendSeparator) {
            [subTitle appendString:@" / "];
        }
        [subTitle appendFormat:@"WCDMA(%ld)", (unsigned long)self.WCDMACellCounter];
        appendSeparator = TRUE;
    }
    
    if (self.GSMCellCounter > 0) {
        if (appendSeparator) {
            [subTitle appendString:@" / "];
        }
        [subTitle appendFormat:@"GSM(%ld)", (unsigned long)self.GSMCellCounter];
    }
    
    return subTitle;
}


- (Boolean) isMultiTechnoGroup {
    if (((self.LTECellCounter > 0) && (self.WCDMACellCounter > 0)) ||
        ((self.LTECellCounter > 0) && (self.GSMCellCounter > 0)) ||
        ((self.WCDMACellCounter > 0) && (self.GSMCellCounter > 0))) {
        return TRUE;
    } else {
        return FALSE;
    }
    
}

static NSString* multiTechnoAnnotationId = @"multiTechnoAnnotationId";

static NSString* LTEAnnotationId = @"LTEAnnotationId";
static NSString* WCDMAAnnotationId = @"WCDMAAnnotationId";
static NSString* GSMAnnotationId = @"GSMAnnotationId";

static NSString* unknownAnnotationId = @"unknownAnnotationId";


- (NSString*) annotationIdentifier {
    
    if ([self isMultiTechnoGroup]) {
        return multiTechnoAnnotationId;
    } else {
        
        if (self.filteredCells.count == 0) {
            return unknownAnnotationId;
        }
        
        CellMonitoring* firstCell = self.filteredCells[0];
        switch (firstCell.cellTechnology) {
            case DCTechnologyLTE: {
                return LTEAnnotationId;
                break;
            }
            case DCTechnologyWCDMA: {
                return WCDMAAnnotationId;
                break;
            }
            case DCTechnologyGSM: {
                return GSMAnnotationId;
                break;
            }
            default: {
                
            }
        }
    }
    return unknownAnnotationId;
}

- (void) setPinImageAnnotation:(Boolean) isCenterCell pinView:(MKAnnotationView*) thePinView {
    
    if (isCenterCell) {
        [thePinView addSubview:[CellMonitoringGroup getImageView:@"3_red.png"]];
    } else {
        if ([self isMultiTechnoGroup]) {
            [thePinView addSubview:[CellMonitoringGroup getImageView:@"8_orange.png"]];
        } else {
            
            if (self.filteredCells.count == 0) {
                [thePinView addSubview:[CellMonitoringGroup getImageView:@"8_black.png"]];
                return;
            }
            
            CellMonitoring* firstCell = self.filteredCells[0];
            switch (firstCell.cellTechnology) {
                case DCTechnologyLTE: {
                    [thePinView addSubview:[CellMonitoringGroup getImageView:@"8_purple.png"]];
                    break;
                }
                case DCTechnologyWCDMA: {
                    [thePinView addSubview:[CellMonitoringGroup getImageView:@"8_teal.png"]];
                    break;
                }
                case DCTechnologyGSM: {
                    [thePinView addSubview:[CellMonitoringGroup getImageView:@"8_yellow.png"]];
                    break;
                }
                default: {
                    
                }
            }
        }
    }
}

#if TARGET_OS_IPHONE
+ (UIImageView*) getImageView:(NSString*) imageName {
    UIImage * image = [UIImage imageNamed:imageName];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    CGRect frame = imageView.frame;
    frame.size.height = 40;
    frame.size.width = 25;
    imageView.frame = frame;

    return imageView;
}
#else 
+ (NSImageView*) getImageView:(NSString*) imageName {
    NSImage * image = [NSImage imageNamed:[imageName stringByDeletingPathExtension]];
    NSImageView* imageView = [[NSImageView alloc] init];
    [imageView setImage:image];
    [imageView setImageScaling:NSScaleToFit];
    CGRect frame = imageView.frame;
    frame.size.width = 28;
    frame.size.height = 51;
    imageView.frame = frame;
    
    return imageView;
}
#endif
@end
