//
//  Utility.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 10/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Utility.h"
#import "SSZipArchive.h"

@implementation Utility


+ (NSString*) extractTimezoneFromData:(id) theData {
    //return [Utility extractTimezoneFromGoogleData:theData];
    return [Utility extractLongTimezoneFrom:theData];
}


#pragma mark - Google

// Returns timezoneId because required to perform date computation
+ (NSString*) extractTimezoneFromGoogleData:(id) theData {
    if (theData == Nil) {
        return @"Timezone not found";
    }
    
    NSDictionary* data = theData;
    
    if ((data == Nil) || (data.count == 0)) {
        return @"Timezone not found";
    }
    
    NSString* status = data[@"status"];
    if ((status == Nil) || ([status isEqualToString:@"OK"] == FALSE)) {
        return @"Timezone not found";
    }
    
    NSString* timezoneId = data[@"timeZoneId"];
    if (timezoneId == Nil) {
        return  @"Timezone not found";
    } else {
        return timezoneId;
    }
}

+(NSString*) extractLongTimezoneFrom:(NSTimeZone*)timezoneData {
    return [timezoneData localizedName:NSTimeZoneNameStyleGeneric
                                locale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
}

+(NSString*) extractShortTimezoneFrom:(NSTimeZone*) timezoneData {
    return [timezoneData localizedName:NSTimeZoneNameStyleShortStandard
                                locale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
}

#pragma mark - Yahoo!
// Yahoo return something like this. We just need to extract from ResultSet the Result and then the timezone!

// Format with YQL (2013)
// Expected answer: {"query":{"count":1,"created":"2013-04-17T20:00:17Z","lang":"en-US","results":{"geonames":{"timezone":{"timezoneId":"America/Los_Angeles"}}}}}


+ (NSString*) extractTimeZoneFromYahooData:(id) theData {
    if (theData == Nil) {
        return @"Timezone not found";
    }
    
    NSDictionary* data = theData;

    if (data == Nil) {
        return @"Timezone not found";
    }
    
    NSString* timezoneString = Nil;
    if (data.count >= 1) {
        NSDictionary* query = data[@"query"];
        if (query == Nil) {
            return @"Timezone not found";
        }
        
        // In case Yahoo! doesn't find an result
        NSNumber* counts = query[@"count"];
        if (counts == Nil || [counts integerValue] == 0) {
            return @"Timezone not found";
        }
        
        NSDictionary* results = query[@"results"];
        if (results == Nil || results.count == 0) {
            return @"Timezone not found";
        }
        NSDictionary* geonames = results[@"geonames"];
        if (geonames == Nil) {
            return @"Timezone not found";
        }
        NSDictionary* timezone = geonames[@"timezone"];
        if (timezone == Nil) {
            return @"Timezone not found";
        }
        
        timezoneString = timezone[@"timezoneId"];
    }
    
    return timezoneString;
}

// Format with API V1.0
//{"ResultSet":{"version":"1.0","Error":0,"ErrorMessage":"No error","Locale":"us_US","Quality":99,"Found":1,"Results":[{"quality":99,"latitude":"37.787082","longitude":"-122.400929","offsetlat":"37.787082","offsetlon":"-122.400929","radius":500,"name":"37.787082 -122.400929","line1":"655 Mission St","line2":"San Francisco, CA  94105-4126","line3":"","line4":"United States","house":"655","street":"Mission St","xstreet":"","unittype":"","unit":"","postal":"94105-4126","neighborhood":"","city":"San Francisco","county":"San Francisco County","state":"California","country":"United States","countrycode":"US","statecode":"CA","countycode":"","timezone":"America\/Los_Angeles","hash":"","woeid":12797156,"woetype":11,"uzip":"94105"}]}}

// Format with API V2.0
//"@lang" = "en-US";//ResultSet =     {    "@lang" = "en-US";    "@version" = "2.0";    Error = 0;    ErrorMessage = "No error";    Found = 1;    Locale = "en-US";    Quality = 99;
//    Result =         { city = "San Antonio";country = "United States";countrycode = US;county = "Bexar County";countycode = "";hash = "";house = "";latitude = "29.451144";line1 = "29.451000 -98.646000";line2 = "San Antonio, TX 78251";line3 = "";line4 = "United States";longitude = "-98.645241";name = "29.451000 -98.646000";neighborhood = "";offsetlat = "29.451144";offsetlon = "-98.645241";postal = 78251;quality = 72;radius = 400;state = Texas;statecode = TX;street = "";timezone = "America/Chicago";unit = "";unittype = "";uzip = 78251;woeid = 12792016;woetype = 11;xstreet = "";    };};}


+ (NSString*) extractTimeZoneFromYahooDataWithAPIV1:(id) theData {
    NSDictionary* data = theData;

    NSLog(@"timezone %@", data);
    NSString* timezone = Nil;
    if (data.count >= 1) {
        NSDictionary* keyValues = data[@"ResultSet"];
        
        // For V1.0 of the API
        NSArray* resultvalues = keyValues[@"Results"];
        //
        NSDictionary* values = resultvalues[0];
        
        //NSDictionary* values = [keyValues objectForKey:@"Result"];
        
        timezone = values[@"timezone"];
    }
    
    return timezone;
}

#pragma mark - Zip methods

+ (NSData*) unzipFromData:(NSData *) theData outputFileName:(NSString*) fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cacheDirectory = [paths lastObject];
    
    NSString *zipfileName = @"Topo.zip";
    NSString *storeFilePath = [NSString stringWithFormat:@"%@/%@", cacheDirectory, zipfileName];
    
    if ([theData writeToFile:storeFilePath atomically:FALSE] == FALSE) {
        NSLog(@"Cannot create file %@", storeFilePath);
        return nil;
    }
    
    // here we go, unzipping code
    Boolean success = [SSZipArchive unzipFileAtPath:storeFilePath toDestination:cacheDirectory overwrite:TRUE password:Nil error:Nil];
    if (success) {
        NSFileManager* fileManager = [NSFileManager defaultManager];
        
        NSError* error;
        BOOL result = [fileManager removeItemAtPath:storeFilePath error:&error];
        if (result == FALSE) {
            NSLog(@"Error removing item: %@ error is: %@",storeFilePath,error);
            return Nil;
        }
        
        // The string "dummy name" is the name of string used in the Server when creating the .zip file
        NSString* unzippedFileName = [NSString stringWithFormat:@"%@/%@", cacheDirectory, fileName];
        NSData* theunzippedData = [NSData dataWithContentsOfFile:unzippedFileName options:NSDataReadingUncached error:&error];
        if (theunzippedData == Nil) {
            NSLog(@"Error reading unzipped file : %@", error );
        }
        
        result = [fileManager removeItemAtPath:unzippedFileName error:&error];
        if (result == FALSE) {
            NSLog(@"Error removing item: %@ error is: %@",unzippedFileName,error);
        }
        return theunzippedData;
        
    } else {
        NSLog(@"Error when unzipping: %@", storeFilePath);
        return Nil;
    }

}


#pragma mark - MinMax
// Return Min & Max value from an Array that contains float
+ (NSArray*) getMinMaxValue:(NSArray*) KPIValues {
    
    Boolean isInitialized = FALSE;
    float minValue;
    float maxValue;
    
    for (NSNumber* value in KPIValues) {
        
        // ignore invalid values
        if ((id) value == [NSNull null]) {
            continue;
        }
        
        float floatCurrValue = [value floatValue];
        
        if (isInitialized == FALSE) {
            isInitialized = TRUE;
            minValue = maxValue = floatCurrValue;
            continue;
        }
        
        if (floatCurrValue > maxValue) {
            maxValue = floatCurrValue;
        }
        
        if (floatCurrValue < minValue) {
            minValue = floatCurrValue;
        }
    }
    
    return @[@(minValue), @(maxValue)];
}

#pragma mark - ColorCode ordering
#if TARGET_OS_IPHONE
+ (NSUInteger) getColorCodeForOrdering:(UIColor*) color {
    static NSUInteger redColor = 0;
    static NSUInteger orangeColor = 1;
    static NSUInteger yellowColor = 2;
    static NSUInteger greenColor = 3;
    static NSUInteger blueColor = 4;
    static NSUInteger unknownColor = 5;
    
    
    if ([color isEqual:[UIColor redColor]]) {
        return redColor;
    }
    
    if ([color isEqual:[UIColor orangeColor]]) {
        return orangeColor;
    }
    
    if ([color isEqual:[UIColor yellowColor]]) {
        return yellowColor;
    }
    
    if ([color isEqual:[UIColor greenColor]]) {
        return greenColor;
    }
    
    if ([color isEqual:[UIColor blueColor]]) {
        return blueColor;
    }
    
    return unknownColor;
}

#endif


+ (NSString*) displayShortDLFrequency:(float) DLFrequency {
    if (DLFrequency >= 1000) {
        return [NSString stringWithFormat:@"%.2f Ghz", (DLFrequency/1000.0)];
    } else {
        return [NSString stringWithFormat:@"%.0f Mhz", DLFrequency];
    }
}
+ (NSString*) displayLongDLFrequency:(float) DLFrequency earfcn:(NSString*) dlEARFCN {
    return [NSString stringWithFormat:@"%@ (%@)", [Utility displayShortDLFrequency:DLFrequency], dlEARFCN];
}

+(float) computeNormalizedDLFrequency:(NSString*) dlEARFCNString {
    if (dlEARFCNString == Nil) {
        return 0;
    } else {
        float NDL = [dlEARFCNString floatValue];

        float FDL_Low = 0.0;
        float NDL_Offset = 0.0;

        if (NDL <= 599) {
            FDL_Low = 2110;
            NDL_Offset = 0.0;
        } else if (NDL <= 1199) {
            FDL_Low = 1930;
            NDL_Offset = 600;
        } else if (NDL <= 1949) {
            FDL_Low = 1805;
            NDL_Offset = 1200;
        } else if (NDL <= 2399) {
            FDL_Low = 2110;
            NDL_Offset = 1950;
        } else if (NDL <= 2649) {
            FDL_Low = 869;
            NDL_Offset = 2400;
        } else if (NDL <= 2749) {
            FDL_Low = 875;
            NDL_Offset = 2650;
        } else if (NDL <= 3449) {
            FDL_Low = 2620;
            NDL_Offset = 2750;
        } else if (NDL <= 3799) {
            FDL_Low = 925;
            NDL_Offset = 3450;
        } else if (NDL <= 4149) {
            FDL_Low = 1844.9;
            NDL_Offset = 3800;
        } else if (NDL <= 4749) {
            FDL_Low = 2110;
            NDL_Offset = 4150;
        } else if (NDL <= 4999) {
            FDL_Low = 1475;
            NDL_Offset = 4750;
        } else if (NDL <= 5179) {
            FDL_Low = 728;
            NDL_Offset = 5000;
        } else if (NDL <= 5279) {
            FDL_Low = 746;
            NDL_Offset = 5180;
        } else if (NDL <= 5379) {
            FDL_Low = 758;
            NDL_Offset = 5280;
        } else {
            // SEB: Don't know the formula for this case
            if (NDL >= 6400) {
                return 800;
            } else {
                FDL_Low = 0.0;
                NDL_Offset = 0.0;
            }
        }

        float normalizedValue = FDL_Low + (0.1 * (NDL - NDL_Offset));
        return normalizedValue;
    }
}

+(NSString*) mapViewTitleForMapMode:(MapModeEnabled) mode {
    switch (mode) {
        case MapModeDefault: {
            return @"Cell Monitoring";
        }
        case MapModeNavMultiCell: {
            return @"Cell Monitoring (Navigation)";
        }
        case MapModeNeighbors: {
            return @"Cell Monitoring (Neighbors)";
        }
        case MapModeRoute: {
            return @"Cell Monitoring (Route)";
        }
        case MapModeZone: {
            return @"Cell Monitoring (Zone)";
        }
            
        default:
            return @"";
    }

}

+(NSString*) hudLoadingLabelForMapMode:(MapModeEnabled) mode {
    switch (mode) {
        case MapModeZone: {
            return @"Loading Cells from zone";
        }
        case MapModeNavMultiCell: {
            return @"Loading Cells from Navigation";
        }
        case MapModeNeighbors: {
            return  @"Loading Neighbors and target Cells";
        }
        case MapModeRoute: {
            return @"Loading Cells around Route";
        }
        case MapModeDefault: {
            return @"Loading Cells";
        }
        default: {
            return @"Loading";
        }
    }
}

+(UIImage*) imageFromJSONByteString:(NSArray*) imageByteString {
    NSUInteger imageSize = imageByteString.count;
    uint8_t *bytes = malloc(sizeof(*bytes) * imageSize);
    
    unsigned i;
    for (i = 0; i < imageSize; i++)
    {
        NSString *str = [imageByteString objectAtIndex:i];
        int byte = [str intValue];
        bytes[i] = byte;
    }
    
    NSData *imageData = [NSData dataWithBytesNoCopy:bytes length:imageSize freeWhenDone:YES];
    return [UIImage imageWithData:imageData];
}

+ (UIImage *)normalizedImage:(UIImage*) sourceImage {
    if (sourceImage.imageOrientation == UIImageOrientationUp) return sourceImage;
    
    UIGraphicsBeginImageContextWithOptions(sourceImage.size, NO, sourceImage.scale);
    [sourceImage drawInRect:(CGRect){0, 0, sourceImage.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

+(UIColor*) getLightColorForBookmark:(UIColor*) theColor {
    if ([theColor isEqual:[UIColor blueColor]]) {
        return [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.1];
    } else if ([theColor isEqual:[UIColor greenColor]]) {
        return [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.1];
    } else if ([theColor isEqual:[UIColor yellowColor]]) {
        return [UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:0.1];
    } else if ([theColor isEqual:[UIColor orangeColor]]) {
        return [UIColor colorWithRed:1.0 green:0.5 blue:1.0 alpha:0.1];
    } else if ([theColor isEqual:[UIColor redColor]]) {
        return [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.1];
    } else {
        return [UIColor clearColor];
    }
}


@end
