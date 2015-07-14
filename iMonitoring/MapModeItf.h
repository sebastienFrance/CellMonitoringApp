//
//  MapMode.h
//  iMonitoring
//
//  Created by sébastien brugalières on 15/12/2013.
//
//

#import <Foundation/Foundation.h>

@class cellDataSource;

@protocol MapModeItf <NSObject>

typedef NS_ENUM(NSUInteger, MapModeEnabled) {
    MapModeDefault = 0,
    MapModeZone = 1,
    MapModeRoute = 2,
    MapModeNeighbors = 3,
    MapModeNavMultiCell = 4
};


@property (nonatomic) MapModeEnabled currentMapMode;
@property (nonatomic, readonly) cellDataSource* datasource;


@end
