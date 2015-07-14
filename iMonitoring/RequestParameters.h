//
//  RequestParameters.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 07/03/2015.
//
//

#import <Foundation/Foundation.h>
#import "RequestUtilities.h"

@class CellMonitoring;
@class MonitoringPeriod;

@interface RequestParameters : NSObject

@property(nonatomic, readonly) NSString* URLParameters;

-(instancetype) init:(NSString*) methodName;
-(instancetype) initWithCell:(NSString*) methodName cell:(CellMonitoring*) theCell;

-(void) appendId:(NSString*) value;
-(void) appendTechno:(NSString*) value;
-(void) appendSiteId:(NSString*) value;
-(void) appendImageQuality:(SiteImageQualityTypeId) theQuality;
-(void) appendImageName:(NSString*) imageName;

// CellMonitoring*
-(void) appendListOfCellIds:(NSArray*) cells;
-(void) appendKPIsForCell:(CellMonitoring*) cell;

-(void) appendMonitoringPeriod:(MonitoringPeriod*) theMonitoringPeriod;
-(void) appendCoordinates:(CLLocationCoordinate2D) theCoordinate;
-(void) appendDistance:(double) theDistance;
-(void) appendRoute:(MKRoute*) theRoute;
-(void) appendUseGeoIndex;

// NavCell*
-(void) appendListOfNavCells:(NSArray*) navCells;

-(void) appendParameterValues:(NSArray*) listOfValues;
-(void) appendListOfParametersValues:(NSDictionary*) paramValues;
-(void) appendParameter:(NSString*) name value:(NSString*) theValue;
-(void) appendParameterULong:(NSString*) name value:(unsigned long) theValue;
-(void) appendParameterUInteger:(NSString*) name value:(NSUInteger) theValue;
-(void) appendParameterFloat:(NSString*) name value:(float) theValue;

-(void) appendTopologyType:(RequestTopologyTypeId) theType;

-(void) appendParameterName:(NSString*) name;
-(void) appendACell:(NSString*) theCell;
-(void) appendZoneName:(NSString*) zoneName;

-(void) appendUserInfosParameters:(NSString*) userName
                         password:(NSString*) thePassword
                      description:(NSString*) theDescription
                          isAdmin:(Boolean) isTheAdmin
                        firstName:(NSString*) theFirstName
                         lastName:(NSString*) theLastName
                            email:(NSString*) theEmail;

@end
