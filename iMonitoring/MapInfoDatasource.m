//
//  MapInfoDatasource.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 12/08/2014.
//
//

#import "MapInfoDatasource.h"
#import "CellMonitoring.h"
#import "MapInfoTechnoDatasource.h"
#import "RequestUtilities.h"

@interface MapInfoDatasource()

@property(nonatomic) MapInfoTechnoDatasource* LTEInfo;
@property(nonatomic) MapInfoTechnoDatasource* WCDMAInfo;
@property(nonatomic) MapInfoTechnoDatasource* GSMInfo;

@property(nonatomic) NSUInteger requestsInProgress;

@property(nonatomic, weak) id<MapInfoDataSourceDelegate> delegate;

@end

@implementation MapInfoDatasource

NSString *const kCellParamlteIntraFrequencyAnrEnabled = @"lteIntraFrequencyAnrEnabled";
NSString *const kCellParamlteInterFrequencyAnrEnabled = @"lteInterFrequencyAnrEnabled";
NSString *const kCellParamutraAnrEnabled = @"utraAnrEnabled";
NSString *const kCellParamNoHO = @"NOHO";
NSString *const kCellParamNoRemove = @"NOREMOVE";
NSString *const kCellParamMeasuredByANR = @"MEASUREDBYANR";

NSString* const kClientIdCellParameters = @"CountCellParameters";
NSString* const kClientIdNeighborParameters = @"CountNeighborParameters";

-(instancetype) init {
    if (self = [super init]) {
        _LTEInfo = [[MapInfoTechnoDatasource alloc] init:DCTechnologyLTE];
        _WCDMAInfo = [[MapInfoTechnoDatasource alloc] init:DCTechnologyWCDMA];
        _GSMInfo = [[MapInfoTechnoDatasource alloc] init:DCTechnologyGSM];
    }

    return self;
}

- (void) loadMapInfoFor:(NSArray*) listOfCells delegate:(id<MapInfoDataSourceDelegate>) theDelegate {

    self.delegate = theDelegate;

    for (CellMonitoring* currentCell in listOfCells) {

        switch (currentCell.cellTechnology) {
            case DCTechnologyLTE: {
                [self.LTEInfo addCell:currentCell];
                break;
            }
            case DCTechnologyWCDMA: {
                [self.WCDMAInfo addCell:currentCell];
                break;
            }
            case DCTechnologyGSM: {
                [self.GSMInfo addCell:currentCell];
                break;
            }
            default: {
            }
        }
    }

    [self getCountRequests];
}

-(void) getCountRequests {
    
    NSArray* listOfCellForTechno = self.LTEInfo.cells;
    if (listOfCellForTechno != 0) {
        
        self.requestsInProgress = 0;
        
        NSDictionary* cellParamListValues = @{kCellParamlteIntraFrequencyAnrEnabled: @[@"true"],
                                              kCellParamlteInterFrequencyAnrEnabled: @[@"true"],
                                              kCellParamutraAnrEnabled: @[@"true"]};
        
        [RequestUtilities countParameterListWithValues:listOfCellForTechno
                                            objectType:RTCellAttributes
                                   parametersAndValues:cellParamListValues
                                              delegate:self clientId:kClientIdCellParameters];
        
        self.requestsInProgress++;
        NSDictionary* neighborParamListValues = @{kCellParamNoHO: @[@"true"],
                                                  kCellParamNoRemove: @[@"true"],
                                                  kCellParamMeasuredByANR: @[@"true"]};

        [RequestUtilities countParameterListWithValues:listOfCellForTechno
                                            objectType:RTCellNR
                                   parametersAndValues:neighborParamListValues
                                              delegate:self clientId:kClientIdNeighborParameters];
        
        self.requestsInProgress++;
   }
}

-(MapInfoTechnoDatasource*) getTechnoInfo:(DCTechnologyId)techno {
    switch (techno) {
        case DCTechnologyLTE: {
            return self.LTEInfo;
        }
        case DCTechnologyWCDMA: {
            return self.WCDMAInfo;
        }
        case DCTechnologyGSM: {
            return self.GSMInfo;
        }
        default: {
            return Nil;
        }

    }
}

#pragma mark - HTMLDataResponse

- (void) dataReady:(id) theData clientId:(NSString*) theClientId {
    NSDictionary* data = theData;
    
    if ([theClientId isEqualToString:kClientIdCellParameters]) {
        NSNumber* value;
        
        value = data[kCellParamlteIntraFrequencyAnrEnabled];
        _LTECountANRIntraFreq = [value integerValue];
        
        value = data[kCellParamlteInterFrequencyAnrEnabled];
        _LTECountANRInterFreq = [value integerValue];

        value = data[kCellParamutraAnrEnabled];
        _LTECountANRInterRAT = [value integerValue];
    } else if ([theClientId isEqualToString:kClientIdNeighborParameters]) {
        NSNumber* value;
        
        value = data[kCellParamNoHO];
        _LTECountNoHo = [value integerValue];
        
        value = data[kCellParamNoRemove];
        _LTECountNoRemove = [value integerValue];

        value = data[kCellParamMeasuredByANR];
        _LTEMeasuredByANR = [value integerValue];
       
   } else {
        NSLog(@"%s unknown response %@", __PRETTY_FUNCTION__, theClientId);
    }
                
    self.requestsInProgress--;
    if (self.requestsInProgress == 0) {
        [self.delegate mapInfoLoaded:Nil];
    }
}

- (void) connectionFailure:(NSString*) theClientId {
    NSLog(@"%s Get failure response",__PRETTY_FUNCTION__);

    if (self.requestsInProgress != 0) {
        self.requestsInProgress = 0;
        
        NSError* error = [[NSError alloc] initWithDomain:@"Communication Error" code:1 userInfo:Nil];
        [self.delegate mapInfoLoaded:error];
    }

}

@end
