//
//  RequestUtilities.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 18/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RequestUtilities.h"
#import "CellMonitoring.h"
#import "KPI.h"
#import "KPIDictionary.h"
#import "DateUtility.h"
#import "NavCell.h"
#import "KPIDictionaryManager.h"
#import "RequestURLUtilities.h"
#import "RequestParameters.h"
#import "MonitoringPeriod.h"


@implementation RequestUtilities

#pragma mark - Generic requests

+(void) sendRequestToServer:(RequestParameters*) parameters
                   isZipped:(Boolean) zipped
                   delegate:(id<HTMLDataResponse>) delegate
                   clientId:(NSString*) theClientId {
    
    id<HTMLRequest> request = [RequestURLUtilities instantiateRequest:delegate clientId:theClientId];
    
    [request sendRequest:parameters.URLParameters zipped:zipped];
}

+(void) sendRequestToServer:(RequestParameters*) parameters
                   isZipped:(Boolean) zipped
                   delegate:(id<HTMLDataResponse>) delegate
                   clientId:(NSString*) theClientId
                    timeout:(NSTimeInterval) theTimeout {
    
    id<HTMLRequest> request = [RequestURLUtilities instantiateRequest:delegate clientId:theClientId];
    
    [request sendRequest:parameters.URLParameters zipped:zipped timeout:theTimeout];
}

#pragma mark - Topology requests
+ (void) getZoneList:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId {
    
    RequestParameters* parametersURL = [[RequestParameters alloc] init:@"getZoneList"];
    
    [RequestUtilities sendRequestToServer:parametersURL isZipped:TRUE delegate:delegate clientId:theClientId timeout:5.0];
}

+ (void) getCellsOfZone:(NSString*) zoneName delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId {
    
    RequestParameters* parametersURL = [[RequestParameters alloc] init:@"getCellsOfZone"];
    [parametersURL appendZoneName:zoneName];
    
    [RequestUtilities sendRequestToServer:parametersURL isZipped:TRUE delegate:delegate clientId:theClientId timeout:5.0];
}


+ (void) getACell:(NSString*) theCellId delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId {
    
    RequestParameters* parametersURL = [[RequestParameters alloc] init:@"getCells"];
    [parametersURL appendACell:theCellId];
    
    [RequestUtilities sendRequestToServer:parametersURL isZipped:TRUE delegate:delegate clientId:theClientId];
}


+ (void) getCells:(NSArray*) navCells delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId {
  
    RequestParameters* parametersURL = [[RequestParameters alloc] init:@"getCells"];
    [parametersURL appendListOfNavCells:navCells];

    [RequestUtilities sendRequestToServer:parametersURL isZipped:TRUE delegate:delegate clientId:theClientId];
}

+ (void) getCellsAround:(CLLocationCoordinate2D) centerCoordinate distance:(double) dist delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId {
    // Request the list of cells located around this point

    RequestParameters* parametersURL = [[RequestParameters alloc] init:@"cellsAroundPosition"];
    [parametersURL appendCoordinates:centerCoordinate];
    [parametersURL appendDistance:dist];
    [parametersURL appendUseGeoIndex];
    [RequestUtilities sendRequestToServer:parametersURL isZipped:TRUE delegate:delegate clientId:theClientId];
}

+ (void) getCellsAroundRoute:(MKRoute*) theRoute distance:(double) dist delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId {
    
    //[RequestUtilities displayRouteInfo:theRoute];
    
    RequestParameters* parametersURL = [[RequestParameters alloc] init:@"cellsAroundRoute"];
    [parametersURL appendRoute:theRoute];
    [parametersURL appendDistance:dist];
    
    [RequestUtilities sendRequestToServer:parametersURL isZipped:TRUE delegate:delegate clientId:theClientId];
}

+(void) displayRouteInfo:(MKRoute*) theRoute {
    
    NSLog(@"======== Advisory");
    for (NSString* currentAdvisory in theRoute.advisoryNotices) {
        NSLog(@"%@", currentAdvisory);
    }
    
    NSLog(@"========= Others");
    NSLog(@"Distance %f Meters",theRoute.distance);
    NSLog(@"Time to travel %f seconds",theRoute.expectedTravelTime);
    NSLog(@"Route Name: %@",theRoute.name);
    
    NSLog(@"========= Route step");
    for (MKRouteStep* currentStep in theRoute.steps) {
        [RequestUtilities displayRouteStep:currentStep];
    }
    
}

+(void) displayRouteStep:(MKRouteStep*) theStep {

    NSLog(@"======== Step ");
    NSLog(@"Instructions %@", theStep.instructions);
    NSLog(@"Notice %@", theStep.notice);
    NSLog(@"Distance %f Meters",theStep.distance);
    NSLog(@"======== End of Step ");
}

+ (void) getCellsStartingWith:(NSString*) matching technology:(NSString*) techno maxResults:(NSUInteger) results delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId {
    // Request the list of cells located around this point
    RequestParameters* parametersURL = [[RequestParameters alloc] init:@"getCellsStartingWith"];
    [parametersURL appendParameter:@"matching" value:matching];
    [parametersURL appendParameterULong:@"maxResults" value:(unsigned long)results];
    [parametersURL appendTechno:techno];
    

    [RequestUtilities sendRequestToServer:parametersURL isZipped:TRUE delegate:delegate clientId:theClientId];
}

+ (void) getCellWithNeighbors:(id<HTMLDataResponse>) delegate cell:(CellMonitoring*) theCell clientId:(NSString*) theClientId {
    RequestParameters* parametersURL = [[RequestParameters alloc] initWithCell:@"cellWithNeighbors" cell:theCell];
    
    [RequestUtilities sendRequestToServer:parametersURL isZipped:TRUE delegate:delegate clientId:theClientId];
}

+ (void) getCellWithNeighborsWithHistorical:(id<HTMLDataResponse>) delegate cell:(CellMonitoring*) theCell clientId:(NSString*) theClientId {
    RequestParameters* parametersURL = [[RequestParameters alloc] initWithCell:@"cellWithNeighborsHistorical" cell:theCell];
    
    [RequestUtilities sendRequestToServer:parametersURL isZipped:TRUE delegate:delegate clientId:theClientId];
}


+ (void) getCellParameters:(CellMonitoring*) theCell delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId {
 
    RequestParameters* parametersURL = [[RequestParameters alloc] initWithCell:@"getCellParameters" cell:theCell];
    
    [RequestUtilities sendRequestToServer:parametersURL isZipped:TRUE delegate:delegate clientId:theClientId];
}

+ (void) getCellParametersWithHistorical:(CellMonitoring*) theCell delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId {
    
    RequestParameters* parametersURL = [[RequestParameters alloc] initWithCell:@"getCelParametersHistorical" cell:theCell];
    
    [RequestUtilities sendRequestToServer:parametersURL isZipped:TRUE delegate:delegate clientId:theClientId];
}

+ (void) countParameterWithValues:(NSArray*) cells
                       objectType:(RequestTopologyTypeId) type
                        parameter:(NSString*) name
                           values:(NSArray*) listOfValues
                         delegate:(id<HTMLDataResponse>) delegate
                         clientId:(NSString*) theClientId {

    RequestParameters* parametersURL = [[RequestParameters alloc] init:@"getCountParameter"];
    [parametersURL appendParameterName:name];
    [parametersURL appendTopologyType:type];
    [parametersURL appendListOfCellIds:cells];
    [parametersURL appendParameterValues:listOfValues];

    [RequestUtilities sendRequestToServer:parametersURL isZipped:TRUE delegate:delegate clientId:theClientId];
}

+ (void) countParameterListWithValues:(NSArray*) cells
                           objectType:(RequestTopologyTypeId) type
                  parametersAndValues:(NSDictionary*) paramValues
                             delegate:(id<HTMLDataResponse>) delegate
                             clientId:(NSString*) theClientId {
    if ((cells == Nil) || (cells.count == 0)) {
        return;
    }
    
    
    RequestParameters* parametersURL = [[RequestParameters alloc] init:@"getCountParameterList"];
    [parametersURL appendTopologyType:type];
    [parametersURL appendListOfCellIds:cells];
    [parametersURL appendListOfParametersValues:paramValues];
    
    [RequestUtilities sendRequestToServer:parametersURL isZipped:TRUE delegate:delegate clientId:theClientId];
}


#pragma mark - KPIs requests
+ (void) getCellKPIs:(CellMonitoring*) cell delegate:(id<HTMLDataResponse>) delegate periodicity:(DCMonitoringPeriodView) thePeriodicity clientId:(NSString*) theClientId {

    MonitoringPeriod* theMonitoringPeriod = [[MonitoringPeriod alloc] initWith:thePeriodicity];

    RequestParameters* parametersURL = [[RequestParameters alloc] initWithCell:@"getCellKPIs" cell:cell];
    [parametersURL appendKPIsForCell:cell];
    [parametersURL appendMonitoringPeriod:theMonitoringPeriod];
    
    [RequestUtilities sendRequestToServer:parametersURL isZipped:TRUE delegate:delegate clientId:theClientId];
}


+ (NSUInteger) getCellsKPIsWithDirection:(NSArray*) cells techno:(DCTechnologyId) theTechno periodicity:(DCMonitoringPeriodView) thePeriodicity delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId {
    return [RequestUtilities getCellsKPIs:cells techno:theTechno delegate:delegate periodicity:thePeriodicity clientId:theClientId direction:TRUE];
}


+ (NSUInteger) getCellsKPIs:(NSArray*) cells techno:(DCTechnologyId) theTechno delegate:(id<HTMLDataResponse>) delegate periodicity:(DCMonitoringPeriodView) thePeriodicity clientId:(NSString*) theClientId direction:(Boolean) KPIWithDirectionOnly {
    
    // all cells from the list have the same technology
    CellMonitoring* cell = cells[0];
    NSString* KPIs;
    if (KPIWithDirectionOnly) {
        KPIs = [RequestUtilities getKPIsWithDirectionForCell:cell];
    } else {
        KPIs = [RequestUtilities getKPIsForCell:cell];
    }    
    
    MonitoringPeriod* theMonitoringPeriod = [[MonitoringPeriod alloc] initWith:thePeriodicity];
    
    NSMutableString* ids = [[NSMutableString alloc] init];
    int j = 0;
    NSUInteger requestNumber = 0;
    for (int i = 0 ; i < cells.count; i++) {
        CellMonitoring* currCell = cells[i];
        if (i < (cells.count - 1)) {
            [ids appendFormat:@"%@,",currCell.id];
        } else {
            [ids appendFormat:@"%@",currCell.id];            
        }
        
        j++;
        if (j == MAX_OBJECT_PER_REQUEST) {
            [RequestUtilities sendCellsKPIs:ids KPIs:KPIs techno:theTechno monitoringPeriod:theMonitoringPeriod delegate:delegate clientId:theClientId];
            j = 0;
            ids = [[NSMutableString alloc] init];
            requestNumber++;
        }
    }
    
    if (j > 0) {
        [RequestUtilities sendCellsKPIs:ids KPIs:KPIs techno:theTechno monitoringPeriod:theMonitoringPeriod  delegate:delegate clientId:theClientId];
        requestNumber++;
    }
    
    return requestNumber;    
}
             
+ (void) sendCellsKPIs:(NSString*) ids KPIs:(NSString*) theKPIs techno:(DCTechnologyId) theTechno monitoringPeriod:(MonitoringPeriod*) theMonitoringPeriod delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId {
    NSString* theTechnoName = [BasicTypes getTechnoName:theTechno];
    
    RequestParameters* parametersURL = [[RequestParameters alloc] init:@"getKPIsForCells"];
    [parametersURL appendParameter:@"ids" value:ids];
    [parametersURL appendTechno:theTechnoName];
    [parametersURL appendParameter:@"KPIs" value:theKPIs];
    [parametersURL appendMonitoringPeriod:theMonitoringPeriod];
    
    [RequestUtilities sendRequestToServer:parametersURL isZipped:TRUE delegate:delegate clientId:theClientId];
}

#pragma mark - Get cell Alarms

+ (void) getCellAlarms:(CellMonitoring*) cell delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId {
    RequestParameters* parametersURL = [[RequestParameters alloc] initWithCell:@"getCellAlarms" cell:cell];
    
    [RequestUtilities sendRequestToServer:parametersURL isZipped:TRUE delegate:delegate clientId:theClientId];
}

#pragma mark - send Picture
+(void) sendImageForSitde:(NSString*) siteId image:(UIImage*) theImage quality:(float) theQuality delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId {
 
    RequestParameters* parametersURL = [[RequestParameters alloc] init:@"addImage"];
    [parametersURL appendSiteId:siteId];
    
    id<HTMLRequest> request = [RequestURLUtilities instantiateRequest:delegate clientId:theClientId];
    
    [request sendRequestWithImage:theImage quality:theQuality url:parametersURL.URLParameters zipped:FALSE];

}

+(void) getSiteImageList:(NSString*) siteId delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId {
    
    RequestParameters* parametersURL = [[RequestParameters alloc] init:@"getSiteImageList"];
    [parametersURL appendSiteId:siteId];
    
    [RequestUtilities sendRequestToServer:parametersURL isZipped:TRUE delegate:delegate clientId:theClientId];
}

+(void) getDefaultSiteImage:(NSString*) siteId quality:(SiteImageQualityTypeId) theQuality delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId {
    
    RequestParameters* parametersURL = [[RequestParameters alloc] init:@"getDefaultSiteImage"];
    [parametersURL appendSiteId:siteId];
    [parametersURL appendImageQuality:theQuality];
    
    [RequestUtilities sendRequestToServer:parametersURL isZipped:FALSE delegate:delegate clientId:theClientId];
}


+(void) getSiteImage:(NSString*) siteId imageName:(NSString*) theImageName quality:(SiteImageQualityTypeId) theQuality delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId {
    RequestParameters* parametersURL = [[RequestParameters alloc] init:@"getSiteImage"];
    [parametersURL appendSiteId:siteId];
    [parametersURL appendImageName:theImageName];
    [parametersURL appendImageQuality:theQuality];
    
    [RequestUtilities sendRequestToServer:parametersURL isZipped:FALSE delegate:delegate clientId:theClientId];
}

+(void) deleteSiteImage:(NSString*) siteId imageName:(NSString*) theImageName delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId {
    
    RequestParameters* parametersURL = [[RequestParameters alloc] init:@"deleteSiteImage"];
    [parametersURL appendSiteId:siteId];
    [parametersURL appendImageName:theImageName];
    
    [RequestUtilities sendRequestToServer:parametersURL isZipped:TRUE delegate:delegate clientId:theClientId];
}

#pragma mark - Authentications requests

+ (void) connect:(NSString*) thePassword delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId{
    
    RequestParameters* parametersURL = [[RequestParameters alloc] init:@"connect"];
    
#if TARGET_OS_IPHONE
    id<HTMLRequest> request = [RequestURLUtilities instantiateRequest:delegate clientId:theClientId];

#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
    id<HTMLRequest> request = [RequestURLUtilities instantiateRequestForModal:delegate clientId:theClientId];
#endif
    
    [request sendRequest:parametersURL.URLParameters zipped:FALSE];
}

+ (void) changePassword:(NSString*) theOldPassword newPassword:(NSString*) theNewPassword delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId {
    
    RequestParameters* parametersURL = [[RequestParameters alloc] init:@"changePassword"];
    [parametersURL appendParameter:@"oldPasswd" value:theOldPassword];
    [parametersURL appendParameter:@"newPasswd" value:theNewPassword];
    
    [RequestUtilities sendRequestToServer:parametersURL isZipped:FALSE delegate:delegate clientId:theClientId];
}

+ (void) getUsers:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId {
    RequestParameters* parametersURL = [[RequestParameters alloc] init:@"getUsers"];
    
    [RequestUtilities sendRequestToServer:parametersURL isZipped:FALSE delegate:delegate clientId:theClientId];
}

+ (void) addUsers:(NSString*) userName password:(NSString*) thePassword description:(NSString*) theDescription
          isAdmin:(Boolean) isTheAdmin firstName:(NSString*) theFirstName lastName:(NSString*) theLastName email:(NSString*) theEmail
         delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId {
    
    RequestParameters* parametersURL = [[RequestParameters alloc] init:@"addUser"];
    [parametersURL appendUserInfosParameters:userName password:thePassword description:theDescription isAdmin:isTheAdmin firstName:theFirstName lastName:theLastName email:theEmail];
    
    [RequestUtilities sendRequestToServer:parametersURL isZipped:FALSE delegate:delegate clientId:theClientId];
}

+ (void) updateUser:(NSString*) userName password:(NSString*) thePassword description:(NSString*) theDescription
          isAdmin:(Boolean) isTheAdmin firstName:(NSString*) theFirstName lastName:(NSString*) theLastName email:(NSString*) theEmail
         delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId {
    
    RequestParameters* parametersURL = [[RequestParameters alloc] init:@"updateUser"];
    [parametersURL appendUserInfosParameters:userName password:thePassword description:theDescription isAdmin:isTheAdmin firstName:theFirstName lastName:theLastName email:theEmail];
    
    [RequestUtilities sendRequestToServer:parametersURL isZipped:FALSE delegate:delegate clientId:theClientId];
}


+ (void) deleteUser:(NSString*) userName delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId {
    
    RequestParameters* parametersURL = [[RequestParameters alloc] init:@"deleteUser"];
    [parametersURL appendParameter:@"userName" value:userName];
    
    
    [RequestUtilities sendRequestToServer:parametersURL isZipped:FALSE delegate:delegate clientId:theClientId];
}

#pragma mark - Misc requests

+ (void) getAbout:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId {
    RequestParameters* parametersURL = [[RequestParameters alloc] init:@"about"];
    
    [RequestUtilities sendRequestToServer:parametersURL isZipped:FALSE delegate:delegate clientId:theClientId];
}

+ (void) getKPIDictionaries:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId {
    
    RequestParameters* parametersURL = [[RequestParameters alloc] init:@"getKPIDictionaries"];
    
#if TARGET_OS_IPHONE
    id<HTMLRequest> request = [RequestURLUtilities instantiateRequest:delegate clientId:theClientId];
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
    id<HTMLRequest> request = [RequestURLUtilities instantiateRequestForModal:delegate clientId:theClientId];
#endif

    [request sendRequest:parametersURL.URLParameters zipped:TRUE timeout:20.0];
}



#pragma mark - Timezone

+ (void) getTimeZone:(CLLocationCoordinate2D) coordinate delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId {
   // [RequestUtilities getYahooTimeZone:coordinate delegate:delegate clientId:theClientId];
   // [RequestUtilities getGoogleTimeZone:coordinate delegate:delegate clientId:theClientId];
    [RequestUtilities getAppleTimeZone:coordinate delegate:delegate clientId:theClientId];
}


+ (void) getYahooTimeZone:(CLLocationCoordinate2D) coordinate delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId {
    // http://query.yahooapis.com/v1/public/yql?q=select%20timezone.timezoneId%20from%20xml%20where%20url%3D'http%3A%2F%2Fws.geonames.org%2Ftimezone%3Flat%3D33.917%26lng%3D-118.1234'&format=json
    
    // Expected answer: {"query":{"count":1,"created":"2013-04-17T20:00:17Z","lang":"en-US","results":{"geonames":{"timezone":{"timezoneId":"America/Los_Angeles"}}}}}
    NSString* firstPart = @"http://query.yahooapis.com/v1/public/yql?q=select timezone.timezoneId from xml where url='";
    NSString* latitude  = [NSString stringWithFormat:@"http://ws.geonames.org/timezone?lat=%f",coordinate.latitude];
    NSString* longitude = [NSString stringWithFormat:@"lng=%f",coordinate.longitude];
    NSString* lastPart  = @"'&format=json";

    [firstPart stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    latitude  = [latitude stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    longitude = [longitude stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    lastPart  = [lastPart stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    // Warning: & character must be escaped with %%26 between lat & long
    NSString* url = [NSString stringWithFormat:@"%@%@%%26%@%@", firstPart, latitude, longitude, lastPart];
    
    id<HTMLRequest> request = [RequestURLUtilities instantiateRequest:delegate clientId:theClientId];
    [request sendBasicRequest:url];
}

+(void) getAppleTimeZone:(CLLocationCoordinate2D) coordinate delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId{
    CLGeocoder* reverseGeoCoder = [[CLGeocoder alloc] init];

    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude
                                                        longitude:coordinate.longitude];

    [reverseGeoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error){
            [delegate connectionFailure:theClientId];
        } else {
            CLPlacemark* currentPlacemark = [placemarks lastObject];

            [delegate dataReady:currentPlacemark.timeZone clientId:theClientId];
        }
    }];

}

+(void) getGoogleTimeZone:(CLLocationCoordinate2D) coordinate delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId {
    // https://maps.googleapis.com/maps/api/timezone/json?location=39.6034810,-119.6822510&timestamp=1331161200
    /*
     {
     "dstOffset" : 0.0,
     "rawOffset" : -28800.0,
     "status" : "OK",
     "timeZoneId" : "America/Los_Angeles",
     "timeZoneName" : "Pacific Standard Time"
     }
     */
    
    NSDate* timestamp = [NSDate date];
    
    NSString* GoogleURL = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/timezone/json?location=%f,%f&timestamp=%f&sensor=false",
                           coordinate.latitude,
                           coordinate.longitude,
                           [timestamp timeIntervalSince1970]];
    GoogleURL = [GoogleURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSLog(@"sending URL Timezone request: %@", GoogleURL);
    id<HTMLRequest> request = [RequestURLUtilities instantiateRequest:delegate clientId:theClientId];
    [request sendBasicRequest:GoogleURL];
}

+ (void) getOldYahooTimeZone:(CLLocationCoordinate2D) coordinate delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId {
    
    // http://where.yahooapis.com/geocode?location=37.787082+-122.400929&appid=yourappid&flags=JT&gflags=R
    
    // flag JT means:
    // J is to get a JSON response
    // T is to get the timezone in the response
    
    // gflags with R for Reverse geo-coding => must provide latitude + longitude in location parameter
    NSString* url = [NSString stringWithFormat:@"http://where.yahooapis.com/geocode?appid=yourappid&flags=JT&gflags=R&location=%f+%f",
                     coordinate.latitude,
                     coordinate.longitude];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    id<HTMLRequest> request = [RequestURLUtilities instantiateRequest:delegate clientId:theClientId];
    [request sendBasicRequest:url];
}



#pragma mark - KPIs utilities
// Return a string that give the list of all KPIs for a cell depending on its Technology
+ (NSString*) getKPIsForCell:(CellMonitoring*) cell {
    KPIDictionaryManager* center = [KPIDictionaryManager sharedInstance];
  
    NSArray<KPI*>* theKPIs = [center.defaultKPIDictionary getKPIs:cell.cellTechnology];
    
    NSMutableString* KPIs = [[NSMutableString alloc] init];
    Boolean isTheFirstKPI = TRUE;
    for (KPI* currKPI in theKPIs) {
        if (isTheFirstKPI) {
            isTheFirstKPI = FALSE;
        } else {
            [KPIs appendString:@","];
        }
        
        [KPIs appendFormat:@"%@", currKPI.internalName];
    }
    
    return KPIs;
}

// Return a string that give the list of all KPIs with direction
+ (NSString*) getKPIsWithDirectionForCell:(CellMonitoring*) cell {
    KPIDictionaryManager* center = [KPIDictionaryManager sharedInstance];
    
    NSArray<KPI*>* theKPIs = [center.defaultKPIDictionary getKPIs:cell.cellTechnology];
    
    NSMutableString* KPIs = [[NSMutableString alloc] init];
    Boolean isTheFirstKPI = TRUE;
    for (KPI* currKPI in theKPIs) {
        
        if (currKPI.hasDirection == FALSE) {
            continue;
        }
        
        if (isTheFirstKPI) {
            isTheFirstKPI = FALSE;
        } else {
            
            [KPIs appendString:@","];
        }
        
        [KPIs appendFormat:@"%@", currKPI.internalName];
    }
    
    return KPIs;
}



@end
