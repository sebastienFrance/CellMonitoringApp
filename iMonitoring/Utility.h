//
//  Utility.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 10/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapModeItf.h"

@interface Utility : NSObject

#pragma mark - zip methods
+ (NSData*) unzipFromData:(NSData *) theData outputFileName:(NSString*) fileName;

#pragma mark - AlertView methods

+(UIAlertController*) getSimpleAlertView:(NSString*) title
                                 message:(NSString*) theMessage
                             actionTitle:(NSString*) actionTitle;

#pragma mark - utility methods


+(NSString*) extractTimezoneFromData:(id) theData;
+(NSString*) extractLongTimezoneFrom:(NSTimeZone*)timezoneData;
+(NSString*) extractShortTimezoneFrom:(NSTimeZone*) timezoneData;

// Index to get the min / max entry from the NSArray result
typedef NS_ENUM(NSUInteger, ArrayMinMaxEntry)  {
    MinArrayEntry = 0,
    MaxArrayEntry = 1,
} ;

+ (NSArray*) getMinMaxValue:(NSArray*) KPIValues;
#if TARGET_OS_IPHONE
+ (NSUInteger) getColorCodeForOrdering:(UIColor*) color;
#endif

+ (NSString*) displayShortDLFrequency:(float) DLFrequency;
+ (NSString*) displayLongDLFrequency:(float) DLFrequency earfcn:(NSString*) dlEARFCN;
+ (float) computeNormalizedDLFrequency:(NSString*) dlEARFCNString;


+(NSString*) mapViewTitleForMapMode:(MapModeEnabled) mode;
+(NSString*) hudLoadingLabelForMapMode:(MapModeEnabled) mode;

+(UIImage*) imageFromJSONByteString:(NSArray*) imageByteString;
+ (UIImage *)normalizedImage:(UIImage*) sourceImage;

+(UIColor*) getLightColorForBookmark:(UIColor*) theColor;
@end
