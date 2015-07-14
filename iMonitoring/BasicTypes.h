//
//  BasicTypes.h
//  iMonitoring
//
//  Created by sébastien brugalières on 09/12/2013.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DCTechnologyId) {
    DCTechnologyLTE = 0,
    DCTechnologyWCDMA = 1,
    DCTechnologyGSM = 2,
    DCTechnologyLatestUsed = 98,
    DCTechnologyUNKNOWN = 99
};

typedef NS_ENUM(NSUInteger, DCZoneTypeId) {
    DCWorkingZone = 0,
    DCObjectZone = 1,
};

typedef NS_ENUM(NSUInteger, DashboardScopeId) {
    DSScopeLastGP = 0,
    DSScopeLastPeriod = 1,
    DSScopeAverageZoneAndPeriod = 2,
};

typedef NS_ENUM(NSUInteger, NRTypeId) {
    NRIntraFreq = 0,
    NRInterFreq = 1,
    NRInterRAT = 2
};

typedef NS_ENUM(NSUInteger, NeighborModeChoiceId) {
    NeighborModeDistance = 0,
    NeighborModeIntraFreq = 1,
    NeighborModeInterFreq = 2,
    NeighborModeInterRAT = 3,
    NeighborModeByANR = 4,
};


FOUNDATION_EXPORT  NSString *const kTechnoLTE;
FOUNDATION_EXPORT  NSString *const kTechnoWCDMA;
FOUNDATION_EXPORT  NSString *const kTechnoGSM;
FOUNDATION_EXPORT  NSString *const kTechnoUNKNOWN;

FOUNDATION_EXPORT  NSString *const kZoneTypeWorking;
FOUNDATION_EXPORT  NSString *const kZoneTypeObject;



@interface BasicTypes : NSObject

+ (NSString*) getTechnoName:(DCTechnologyId) theTechno;
+ (DCTechnologyId) getTechnoFromName:(NSString*) theTechno;
+ (NSString*) getZoneName:(DCZoneTypeId) theZone;
+ (NSString*) getNRType:(NRTypeId) neighborType;
+ (NRTypeId)  getNRTypeFromSource:(DCTechnologyId) sourceTechno sourceCellFrequency:(NSString*) sourceFrequency
                 targetCellTechno:(DCTechnologyId) targetTechno targetCellFrequency:(NSString*) targetFrequency;

@end
