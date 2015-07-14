//
//  SimpleHTMLRequest.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 18/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "HTMLRequest.h"
#import "BasicHTMLRequest.h"
#import "BasicTypes.h"
#import "MonitoringPeriodUtility.h"
@class CellMonitoring;

@protocol HTMLDataResponse;

typedef NS_ENUM(NSUInteger, RequestTopologyTypeId) {
    RTCell = 0,
    RTCellAttributes = 1,
    RTCellNR = 2,
};

typedef NS_ENUM(NSUInteger, SiteImageQualityTypeId) {
    HiRes = 0,
    LowRes = 1,
};


static const NSUInteger MAX_OBJECT_PER_REQUEST = 2000;

@interface RequestUtilities : NSObject

#pragma mark - Get zones

+ (void) getZoneList:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId ;
+ (void) getCellsOfZone:(NSString*) zoneName delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId ;

#pragma mark - Get Cells

+ (void) getACell:(NSString*) theCellId delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId;
+ (void) getCells:(NSArray*) navCells delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId ;
+ (void) getCellsAround:(CLLocationCoordinate2D) centerCoordinate distance:(double) dist delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId ;
+ (void) getCellsAroundRoute:(MKRoute*) theRoute distance:(double) dist delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId ;

+ (void) getCellsStartingWith:(NSString*) matching technology:(NSString*) techno maxResults:(NSUInteger) results delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId;
+ (void) getCellWithNeighbors:(id<HTMLDataResponse>) delegate cell:(CellMonitoring*) theCell clientId:(NSString*) theClientId;
+ (void) getCellWithNeighborsWithHistorical:(id<HTMLDataResponse>) delegate cell:(CellMonitoring*) theCell clientId:(NSString*) theClientId;
+ (void) getCellParameters:(CellMonitoring*) theCell delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId;
+ (void) getCellParametersWithHistorical:(CellMonitoring*) theCell delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId;

#pragma mark - generic method to count parameters of an object
+ (void) countParameterWithValues:(NSArray*) cells objectType:(RequestTopologyTypeId) type parameter:(NSString*) name values:(NSArray*) listOfValues delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId;
+ (void) countParameterListWithValues:(NSArray*) cells objectType:(RequestTopologyTypeId) type parametersAndValues:(NSDictionary*) paramValues delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId;
#pragma mark - Get KPIs

+ (void) getCellKPIs:(CellMonitoring*) cell delegate:(id<HTMLDataResponse>) delegate periodicity:(DCMonitoringPeriodView) thePeriodicity clientId:(NSString*) theClientId;
+ (NSUInteger) getCellsKPIsWithDirection:(NSArray*) cells techno:(DCTechnologyId) theTechno periodicity:(DCMonitoringPeriodView) thePeriodicity delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId;


#pragma mark - get Alarms

+ (void) getCellAlarms:(CellMonitoring*) cell delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId;

#pragma mark - send Picture
+(void) sendImageForSitde:(NSString*) siteId image:(UIImage*) theImage quality:(float) theQuality delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId;
+(void) getSiteImageList:(NSString*) siteId delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId;
+(void) getSiteImage:(NSString*) siteId imageName:(NSString*) theImageName quality:(SiteImageQualityTypeId) theQuality delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId;
+(void) getDefaultSiteImage:(NSString*) siteId quality:(SiteImageQualityTypeId) theQuality delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId;
+(void) deleteSiteImage:(NSString*) siteId imageName:(NSString*) theImageName delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId;

#pragma mark - Timezone
+ (void) getTimeZone:(CLLocationCoordinate2D) cell delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId;
+ (void) getYahooTimeZone:(CLLocationCoordinate2D) coordinate delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId;

#pragma mark - Authentications requests
+ (void) connect:(NSString*) thePassword delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId;
+ (void) changePassword:(NSString*) theOldPassword newPassword:(NSString*) theNewPassword delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId;
+ (void) getUsers:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId;
+ (void) addUsers:(NSString*) userName password:(NSString*) thePassword description:(NSString*) theDescription
          isAdmin:(Boolean) isTheAdmin firstName:(NSString*) theFirstName lastName:(NSString*) theLastName email:(NSString*) theEmail
         delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId;
+ (void) deleteUser:(NSString*) userName delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId;
+ (void) updateUser:(NSString*) userName password:(NSString*) thePassword description:(NSString*) theDescription
            isAdmin:(Boolean) isTheAdmin firstName:(NSString*) theFirstName lastName:(NSString*) theLastName email:(NSString*) theEmail
           delegate:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId;


#pragma mark - Others requests
+ (void) getKPIDictionaries:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId;
+ (void) getAbout:(id<HTMLDataResponse>) delegate clientId:(NSString*) theClientId;

@end

