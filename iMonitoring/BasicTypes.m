//
//  BasicTypes.m
//  iMonitoring
//
//  Created by sébastien brugalières on 09/12/2013.
//
//

#import "BasicTypes.h"

@implementation BasicTypes

NSString *const kTechnoLTE                    = @"LTE";
NSString *const kTechnoWCDMA                  = @"WCDMA";
NSString *const kTechnoGSM                    = @"GSM";
NSString *const kTechnoUNKNOWN                = @"UNKNOWN";

NSString *const kZoneTypeWorking              = @"WZ";
NSString *const kZoneTypeObject               = @"OZ";

+ (NSString*) getTechnoName:(DCTechnologyId) theTechno {
    NSString* technoName = Nil;
    
    switch (theTechno) {
        case DCTechnologyLTE: {
            technoName = kTechnoLTE;
            break;
        }
        case DCTechnologyWCDMA: {
            technoName = kTechnoWCDMA;
            break;
        }
        case DCTechnologyGSM: {
            technoName = kTechnoGSM;
            break;
        }
        default: {
            technoName = kTechnoUNKNOWN;
            break;
        }
    }
    return technoName;
}

+ (DCTechnologyId) getTechnoFromName:(NSString*) theTechno {
    if ([theTechno isEqualToString:@"LTE"]) {
        return DCTechnologyLTE;
    } else if ([theTechno isEqualToString:@"WCDMA"]) {
        return DCTechnologyWCDMA;
    }  else if ([theTechno isEqualToString:@"GSM"]) {
        return DCTechnologyGSM;
    } else {
        return DCTechnologyUNKNOWN;
    }
}

+ (NSString*) getZoneName:(DCZoneTypeId) theZone {
    switch (theZone) {
        case DCObjectZone: {
            return @"Object zone";
        }
        case DCWorkingZone: {
            return @"Working zone";
        }
    }
}

+ (NSString*) getNRType:(NRTypeId) neighborType {
    switch (neighborType) {
        case NRIntraFreq: {
            return @"Intra-Freq";
        }
        case NRInterFreq: {
            return @"Inter-Freq";
        }
        case NRInterRAT: {
            return @"Inter-RAT";
        }
        default:
            return @"Unknown";
    }
}

+(NRTypeId) getNRTypeFromSource:(DCTechnologyId) sourceTechno sourceCellFrequency:(NSString*) sourceFrequency
               targetCellTechno:(DCTechnologyId) targetTechno targetCellFrequency:(NSString*) targetFrequency {
    if (sourceTechno != targetTechno) {
        return NRInterRAT;
    } else {
        if ([sourceFrequency isEqualToString:targetFrequency]) {
            return NRIntraFreq;
        } else {
            return NRInterFreq;
        }
    }
}

@end
