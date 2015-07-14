//
//  RequestParameters.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 07/03/2015.
//
//

#import "RequestParameters.h"
#import "CellMonitoring.h"
#import "NavCell.h"
#import "RequestUtilities.h"
#import "KPIDictionaryManager.h"
#import "KPIDictionary.h"
#import "KPI.h"
#import "MonitoringPeriod.h"
#import "UserPreferences.h"

@interface RequestParameters ()

@property(nonatomic) NSMutableString* parameterURL;

@end


@implementation RequestParameters

-(instancetype) init:(NSString*) methodName {
    if (self = [super init] ) {
        _parameterURL = [NSMutableString stringWithFormat:@"Method=%@", methodName];
    }

    return self;
}

-(instancetype) initWithCell:(NSString*) methodName cell:(CellMonitoring*) theCell  {
    if (self = [super init] ) {
        _parameterURL = [NSMutableString stringWithFormat:@"Method=%@", methodName];
        [self appendId:theCell.id];
        [self appendTechno:theCell.techno];
    }
    
    return self;
}

-(void) appendParameter:(NSString*) name value:(NSString*) theValue {
    [self.parameterURL appendFormat:@"&%@=%@",name, theValue];
}

-(void) appendParameterULong:(NSString*) name value:(unsigned long) theValue {
    [self.parameterURL appendFormat:@"&%@=%lu",name, theValue];
}

-(void) appendParameterDouble:(NSString*) name value:(double) theValue {
    [self.parameterURL appendFormat:@"&%@=%f",name, theValue];
}

-(void) appendParameterFloat:(NSString*) name value:(float) theValue {
    [self.parameterURL appendFormat:@"&%@=%f",name, theValue];
}

-(void) appendParameterUInteger:(NSString*) name value:(NSUInteger) theValue {
    [self.parameterURL appendFormat:@"&%@=%lu",name, (unsigned long)theValue];
}

-(void) appendParameterBoolean:(NSString*) name value:(Boolean) theValue {
    if (theValue) {
        [self.parameterURL appendFormat:@"&%@=true",name];
    } else {
        [self.parameterURL appendFormat:@"&%@=false",name];
    }
}

-(void) appendId:(NSString*) value {
    [self appendParameter:@"id" value:value];
}

-(void) appendTechno:(NSString*) value {
    [self appendParameter:@"techno" value:value];
}

-(void) appendSiteId:(NSString*) value {
    [self appendParameter:@"siteId" value:value];
}

-(void) appendImageQuality:(SiteImageQualityTypeId) theQuality {
    NSString* theStringQuality = Nil;
    switch (theQuality) {
        case LowRes: {
            theStringQuality = @"LowRes";
            break;
        }
        case HiRes: {
            theStringQuality = @"HiRes";
            break;
        }
        default: {
            theStringQuality = @"LowRes";
        }
    }
    
    [self appendParameter:@"imageQuality" value:theStringQuality];

}

-(void) appendImageName:(NSString*) imageName {
    [self appendParameter:@"imageName" value:imageName];
}

-(void) appendListOfCellIds:(NSArray*) cells {
    [self.parameterURL appendString:@"&objectIds="];
    
    CellMonitoring* lastCell = cells.lastObject;
    for (CellMonitoring* currentCell in cells) {
        if (currentCell != lastCell) {
            [self.parameterURL appendFormat:@"%@,",currentCell.id];
        } else {
            [self.parameterURL appendString:currentCell.id];
        }
    }
}

-(void) appendListOfNavCells:(NSArray*) navCells {
    [self.parameterURL appendString:@"&cells="];

    for (NavCell* currentNavCell in navCells) {
        [self.parameterURL appendFormat:@"%@,", currentNavCell.cellId];
    }
}

-(void) appendParameterValues:(NSArray*) listOfValues {
    [self.parameterURL  appendString:@"&paramValues="];
    NSString* lastValue = listOfValues.lastObject;
    for (NSString* currentValue in listOfValues) {
        if (currentValue != lastValue) {
            [self.parameterURL appendFormat:@"%@,",currentValue];
        } else {
            [self.parameterURL appendString:currentValue];
        }
    }
}

-(void) appendListOfParametersValues:(NSDictionary*) paramValues {
    // paramListValues
    [self.parameterURL appendString:@"&paramListValues="];
    for (NSString* parameterName in paramValues.allKeys) {
        [self.parameterURL appendFormat:@"_PNAME_%@", parameterName];
        [self.parameterURL appendFormat:@"_PVALUES_"];
        NSArray* parameterValues = paramValues[parameterName];
        NSString* lastValue = parameterValues.lastObject;
        for (NSString* currentValue in parameterValues) {
            if (currentValue != lastValue) {
                [self.parameterURL appendFormat:@"%@,",currentValue];
            } else {
                [self.parameterURL appendString:currentValue];
            }
        }
    }
}

-(void) appendKPIsForCell:(CellMonitoring*) cell {
    [self.parameterURL appendString:@"&KPIs="];
    
    KPIDictionaryManager* center = [KPIDictionaryManager sharedInstance];
    
    NSArray* theKPIs = [center.defaultKPIDictionary getKPIs:cell.cellTechnology];
    
    Boolean isTheFirstKPI = TRUE;
    for (KPI* currentKPI in theKPIs) {
        if (isTheFirstKPI) {
            isTheFirstKPI = FALSE;
        } else {
            [self.parameterURL appendString:@","];
        }
        
        [self.parameterURL appendFormat:@"%@", currentKPI.internalName];
    }
}

-(void) appendMonitoringPeriod:(MonitoringPeriod*) theMonitoringPeriod {
    [self appendParameter:@"periodicity" value:theMonitoringPeriod.periodicity];
    [self appendParameter:@"startDate" value:theMonitoringPeriod.fromDate];
    [self appendParameter:@"endDate" value:theMonitoringPeriod.endDate];

}

-(void) appendCoordinates:(CLLocationCoordinate2D) theCoordinate {
    [self appendParameterDouble:@"lat" value:theCoordinate.latitude];
    [self appendParameterDouble:@"long" value:theCoordinate.longitude];
}

-(void) appendDistance:(double)theDistance {
    [self appendParameterDouble:@"dist" value:theDistance];
}

-(void) appendUseGeoIndex {
    [self appendParameterBoolean:@"useGeoIndex" value:[UserPreferences sharedInstance].isGeoIndexLookup];
}


-(void) appendRoute:(MKRoute*) theRoute {
    MKPolyline* thePolyline = theRoute.polyline;
    MKMapPoint* thePoints = thePolyline.points;
    
    NSMutableString* routeToString = [[NSMutableString alloc] init];
    
    for (int i = 0 ; i < thePolyline.pointCount; i++) {
        MKMapPoint currentPoint = thePoints[i];
        CLLocationCoordinate2D newCoordinateForAPoint = MKCoordinateForMapPoint(currentPoint);
        
        if (i > 0) {
            [routeToString appendString:@";"];
        }
        
        [routeToString appendFormat:@"%f_%f",newCoordinateForAPoint.latitude, newCoordinateForAPoint.longitude];
    }

    [self appendParameter:@"route" value:routeToString];
}

-(void) appendTopologyType:(RequestTopologyTypeId) theType {
    [self appendParameterULong:@"objectType" value:(unsigned long) theType];
}

-(void) appendParameterName:(NSString*) name {
    [self appendParameter:@"paramName" value:name];
}

-(void) appendACell:(NSString *) theCell {
    [self appendParameter:@"cells" value:theCell];
}

-(void) appendZoneName:(NSString*) zoneName {
    [self appendParameter:@"zoneName" value:zoneName];
}

-(void) appendUserInfosParameters:(NSString*) userName
                         password:(NSString*) thePassword
                      description:(NSString*) theDescription
                          isAdmin:(Boolean) isTheAdmin
                        firstName:(NSString*) theFirstName
                         lastName:(NSString*) theLastName
                            email:(NSString*) theEmail {
    
    NSUInteger isAdminInt = isTheAdmin ? 1 : 0;
    
    [self appendParameter:@"userName" value:userName];
    [self appendParameter:@"userPassword" value:thePassword];
    [self appendParameter:@"userDescription" value:theDescription];
    [self appendParameterUInteger:@"isAdmin" value:isAdminInt];
    [self appendParameter:@"firstName" value:theFirstName];
    [self appendParameter:@"lastName" value:theLastName];
    [self appendParameter:@"email" value:theEmail];
}


-(NSString*) URLParameters {
    return self.parameterURL;
}

@end
