//
//  MapInfoDatasource.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 12/08/2014.
//
//

#import <Foundation/Foundation.h>
#import "BasicTypes.h"
#import "HTMLRequest.h"

@class MapInfoTechnoDatasource;
@protocol MapInfoDataSourceDelegate;

@interface MapInfoDatasource : NSObject<HTMLDataResponse>

- (void) loadMapInfoFor:(NSArray*) listOfCells delegate:(id<MapInfoDataSourceDelegate>) theDelegate;

-(MapInfoTechnoDatasource*) getTechnoInfo:(DCTechnologyId) techno;

@property(nonatomic, readonly) NSUInteger LTECountANRIntraFreq;
@property(nonatomic, readonly) NSUInteger LTECountANRInterFreq;
@property(nonatomic, readonly) NSUInteger LTECountANRInterRAT;

@property(nonatomic, readonly) NSUInteger LTECountNoHo;
@property(nonatomic, readonly) NSUInteger LTECountNoRemove;
@property(nonatomic, readonly) NSUInteger LTEMeasuredByANR;

@end

@protocol MapInfoDataSourceDelegate <NSObject>

- (void) mapInfoLoaded:(NSError*) theError;

@end
