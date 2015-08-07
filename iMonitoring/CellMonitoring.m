//
//  CellMonitoring.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 17/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddressBook/AddressBook.h"
#import "AttributeNameValue.h"
#import "CellKPIsDataSource.h"
#import "CellMonitoring.h"
#import "CellMonitoringGroup.h"
#import "DateUtility.h"
#import "LocalizedCurrentLocation.h"
#import <CoreLocation/CLPlacemark.h>
#import <MapKit/MapKit.h>
#import "Utility.h"
#import "CellParameters2HTMLTable.h"

@interface CellMonitoring()

@property (nonatomic) CellKPIsDataSource* cache;


@property (nonatomic) NSDictionary* cellDictionary;
@property (nonatomic) float normalizedDLFrequency;

@end

@implementation CellMonitoring


static const NSString* PARAM_azimuth = @"azimuth";
static const NSString* PARAM_cellName = @"cellName";
static const NSString* PARAM_latitude = @"latitude";
static const NSString* PARAM_radius = @"radius";
static const NSString* PARAM_longitude = @"longitude";
static const NSString* PARAM_techno = @"techno";
static const NSString* PARAM_site = @"site";
static const NSString* PARAM_siteId = @"siteId";
static const NSString* PARAM_release = @"release";
static const NSString* PARAM_dlFrequency = @"dlFrequency";
static const NSString* PARAM_telecomId = @"telecomId";
static const NSString* PARAM_numberIntraFreqNR = @"numberIntraFreqNR";
static const NSString* PARAM_numberInterFreqNR = @"numberInterFreqNR";
static const NSString* PARAM_numberInterRATNR = @"numberInterRATNR";

#pragma mark - Initializations

- (id) initWithDictionary:(NSDictionary*) cellDictionary {
    if (self = [super init]) {
        _cellDictionary = cellDictionary;

        _normalizedDLFrequency = [Utility computeNormalizedDLFrequency:self.cellDictionary[PARAM_dlFrequency]];
    }
    
    return self;
}


- (NSString*) id {
    return self.cellDictionary[PARAM_cellName];
}

- (NSString*) azimuth {
    return self.cellDictionary[PARAM_azimuth];
}

- (NSString*) techno {
    return self.cellDictionary[PARAM_techno];
}

- (DCTechnologyId) cellTechnology {
    NSString* technology = self.cellDictionary[PARAM_techno];
    return [BasicTypes getTechnoFromName:technology];
}

- (NSString*) site {
    return self.cellDictionary[PARAM_site];
}

- (NSString*) siteId {
    return self.cellDictionary[PARAM_siteId];
}

-(NSString*) fullSiteName {
    if ((self.siteId != Nil) && (self.siteId.length > 0)) {
       return [NSString stringWithFormat:@"%@ (%@)", self.site, self.siteId];
    } else {
        return self.site;
    }
}

- (NSString*) releaseName {
    return self.cellDictionary[PARAM_release];
}

- (NSString*) dlFrequency {
    return self.cellDictionary[PARAM_dlFrequency];
}

- (NSString*) telecomId {
    return self.cellDictionary[PARAM_telecomId];
}


- (NSUInteger) radius {
    NSNumber* numberNR = self.cellDictionary[PARAM_radius];
    return [numberNR integerValue];
}

- (NSUInteger) numberIntraFreqNR {
    NSNumber* numberNR = self.cellDictionary[PARAM_numberIntraFreqNR];
    return [numberNR integerValue];

}

- (NSUInteger) numberInterFreqNR {
    NSNumber* numberNR = self.cellDictionary[PARAM_numberInterFreqNR];
    return [numberNR integerValue];

}

- (NSUInteger) numberInterRATNR {
    NSNumber* numberNR = self.cellDictionary[PARAM_numberInterRATNR];
    return [numberNR integerValue];
}

- (CLLocationCoordinate2D) coordinate {
    CLLocationCoordinate2D theCoordinate;
    NSNumber* longitude = self.cellDictionary[PARAM_longitude];
    NSNumber* latitude = self.cellDictionary[PARAM_latitude];
    
    theCoordinate.latitude =  [latitude doubleValue];
    theCoordinate.longitude = [longitude doubleValue];
    
    return theCoordinate;

}

- (void) initializeCellParameters:(Parameters*) cellParameters {
    _parametersBySection = cellParameters;
}


- (Boolean) hasAddress {
    return self.parentGroup.hasAddress;
}

- (NSString*) city {
    return self.parentGroup.city;
}

- (NSString*) country {
    return self.parentGroup.country;
}

- (NSString*) street {
    return self.parentGroup.street;
}

- (MKPlacemark*) cellPlacemark {
    return self.parentGroup.cellPlacemark;
}

- (void) initialiazeAddress:(CLPlacemark*) placemark {
    [self.parentGroup initialiazeAddress:placemark];
}

- (Boolean) hasTimezone {
    return self.parentGroup.hasTimezone;
}


- (NSString*) timezone {
    return self.parentGroup.timezone;
}

- (NSString*) timezoneAbbreviation {
    return self.parentGroup.timezoneAbbreviation;
}


#pragma mark - Cache management

- (CellKPIsDataSource*) getCache {
    // check if the cache exist and still valid else return nil
    
    if (_cache == Nil) {
        return Nil;
    }
    
    NSDate* requestDate = _cache.requestDate;
    NSDate* now = [[NSDate alloc] init];
    
    NSDate* requestDateNormalized = [DateUtility getDateNear15mn:requestDate];
    NSDate* nowNormalized = [DateUtility getDateNear15mn:now];
    
    NSString* requestDateStr = [DateUtility getDate:requestDateNormalized option:withHHmm];
    NSString* nowStr = [DateUtility getDate:nowNormalized option:withHHmm];
    
    if ([requestDateStr isEqualToString:nowStr]) {
        return _cache;
    } else {
        return Nil;
    }
}

- (void) setCache:(CellKPIsDataSource *)cache {
    _cache = cache;
}

#pragma mark - Utilities

- (NSComparisonResult)compareByName:(CellMonitoring *)otherObject {
    return [self.id compare:otherObject.id];
}

- (void) showDirection {
#warning SEB: To be completed on MAC 
#if TARGET_OS_IPHONE
    MKPlacemark* cellPlacemark = self.parentGroup.cellPlacemark;

    BOOL atLeastIOS6 = [[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0;
    
    if (atLeastIOS6) {
        NSDictionary *addressDict = @{(id)kABPersonAddressCountryCodeKey: cellPlacemark.ISOcountryCode,
                                      (id)kABPersonAddressCountryKey: cellPlacemark.country,
                                      (id)kABPersonAddressStateKey: cellPlacemark.subAdministrativeArea,
                                      (id)kABPersonAddressCityKey: cellPlacemark.locality,
                                      (id)kABPersonAddressStreetKey: self.street,
                                      (id)kABPersonAddressZIPKey: cellPlacemark.postalCode};
        
        MKPlacemark* placemark = [[MKPlacemark alloc] initWithCoordinate:self.coordinate addressDictionary:addressDict];
        
        //MKMapItem* map = [[MKMapItem alloc] initWithPlacemark:_cellPlacemark];
        MKMapItem* map = [[MKMapItem alloc] initWithPlacemark:placemark];
        map.name = [NSString stringWithFormat:@"%@ Cell - %@",self.techno ,self.id];
        
        
        NSDictionary *options = @{
                                  MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
                                  MKLaunchOptionsMapTypeKey:@(MKMapTypeSatellite),
                                  MKLaunchOptionsShowsTrafficKey:@YES,
                                  };

        
        [map openInMapsWithLaunchOptions:options];
    } else {
            NSString *direction = [NSString stringWithFormat:@"saddr=%@&daddr=%@ %@ %@",
                                   [LocalizedCurrentLocation currentLocationStringForCurrentLanguage],
                                   self.street,
                                   self.city,
                                   self.country];
        
            NSString *url = [NSString stringWithFormat: @"http://maps.google.com/maps?%@",
                             [direction stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
#endif
}


+ (MKCoordinateRegion) getRegionThatFitsCells:(NSArray*) theCellList {
    
    if ((theCellList == Nil) || (theCellList.count ==0)) {
        MKCoordinateRegion theRegion;
        theRegion.center.latitude = 0.0;
        theRegion.center.longitude = 0.0;
        theRegion.span.latitudeDelta = 10.0 ;
        theRegion.span.longitudeDelta = 10.0 ;
        
        return theRegion;
    }
    
    
    CLLocationDegrees minLatitude;
    CLLocationDegrees maxLatitude;
    
    CLLocationDegrees minLongitude;
    CLLocationDegrees maxLongitude;
    
    Boolean isInitalized = FALSE;
    
    for (CellMonitoring* currentCell in theCellList) {
        CLLocationCoordinate2D cellCoordinate = currentCell.coordinate;
        
        if (isInitalized == FALSE) {
            minLatitude = maxLatitude = cellCoordinate.latitude;
            minLongitude = maxLongitude = cellCoordinate.longitude;
            isInitalized = TRUE;
        } else {
            if (minLatitude > cellCoordinate.latitude) {
                minLatitude = cellCoordinate.latitude;
            }
            if (maxLatitude < cellCoordinate.latitude) {
                maxLatitude = cellCoordinate.latitude;
            }
            if (minLongitude > cellCoordinate.longitude) {
                minLongitude = cellCoordinate.longitude;
            }
            if (maxLongitude < cellCoordinate.longitude) {
                maxLongitude = cellCoordinate.longitude;
            }
        }
    }
    
    CLLocationDegrees latitude = (maxLatitude + minLatitude) / 2.0;
    CLLocationDegrees longitude = (maxLongitude + minLongitude) / 2.0;
    
    CLLocationDegrees maxDiffLatitude = fabs(maxLatitude - minLatitude);
    CLLocationDegrees maxDiffLongitude = fabs(maxLongitude - minLongitude);
    
    MKCoordinateRegion theRegion;
    
    theRegion.center.latitude = latitude;
    theRegion.center.longitude = longitude;
    theRegion.span.latitudeDelta = maxDiffLatitude ; 
    theRegion.span.longitudeDelta = maxDiffLongitude ;
    
    return theRegion;
}


-(NSString*) cellInfoToHTML {
    NSMutableString* HTMLCell = [[NSMutableString alloc] init];
    [HTMLCell appendString:[self cellShortInfoToHTML]];
    
    NSString* cellParameters = [CellParameters2HTMLTable cellParametersToHTML:self.parametersBySection];
    if (cellParameters != Nil) {
        [HTMLCell appendString:cellParameters];
    }
    return HTMLCell;
}

- (NSString*) cellShortInfoToHTML {
    NSMutableString* HTMLCell = [[NSMutableString alloc] init];
    [HTMLCell appendFormat:@"<h2> Cell Information </h2>"];
    [HTMLCell appendFormat:@"<ul><li>Name: %@</li>", self.id];
    
    if (self.hasAddress) {
        [HTMLCell appendFormat:@"<li>Address: %@ %@ %@ </li>", self.street, self.city, self.country];
    } else {
        [HTMLCell appendFormat:@"<li>Address: Not available </li>"];
    }
    
    if (self.hasTimezone) {
        [HTMLCell appendFormat:@"<li>Time zone: %@</li>", self.timezone];
    } else {
        [HTMLCell appendFormat:@"<li>Time zone: Not available</li>"];
    }
    [HTMLCell appendFormat:@"<li>Latitude:  %f</li>", self.coordinate.latitude];
    [HTMLCell appendFormat:@"<li>Longitude: %f</li>", self.coordinate.longitude];
    [HTMLCell appendFormat:@"<li>Technology:  %@</li>", self.techno];
    [HTMLCell appendFormat:@"<li>Frequency:  %@</li>", [Utility displayLongDLFrequency:[Utility computeNormalizedDLFrequency:self.dlFrequency] earfcn:self.dlFrequency]];
    [HTMLCell appendFormat:@"<li>Azimuth: %@</li></ul>", self.azimuth];
    
    return HTMLCell;
}


#if TARGET_OS_IPHONE
- (UIImageView*) getPinImageView {
#else
- (NSImageView*) getPinImageView {
#endif
    
    switch (self.cellTechnology) {
        case DCTechnologyLTE: {
            return [CellMonitoring getImageView:@"8_purple.png"];
        }
        case DCTechnologyWCDMA: {
            return [CellMonitoring getImageView:@"8_teal.png"];
        }
        case DCTechnologyGSM: {
            return [CellMonitoring getImageView:@"8_yellow.png"];
        }
        default: {
            return Nil;
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
    frame.size.height = 40;
    frame.size.width = 25;
    imageView.frame = frame;
    
    return imageView;
}
#endif

#if TARGET_OS_IPHONE
    - (UIImage*) getPinImage {
#else
        - (NSImage*) getPinImage {
#endif
            
            switch (self.cellTechnology) {
                case DCTechnologyLTE: {
                    return [CellMonitoring getImage:@"8_purple.png"];
                }
                case DCTechnologyWCDMA: {
                    return [CellMonitoring getImage:@"8_teal.png"];
                }
                case DCTechnologyGSM: {
                    return [CellMonitoring getImage:@"8_yellow.png"];
                }
                default: {
                    return Nil;
                }
            }
        }
        
#if TARGET_OS_IPHONE
        + (UIImage*) getImage:(NSString*) imageName {
            UIImage * image = [UIImage imageNamed:imageName];
            return image;
        }
#else
        + (NSImage*) getImage:(NSString*) imageName {
            NSImage * image = [NSImage imageNamed:[imageName stringByDeletingPathExtension]];
            return image;
        }
#endif


@end
