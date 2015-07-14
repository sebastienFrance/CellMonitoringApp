//
//  NavCell.h
//  iMonitoring
//
//  Created by sébastien brugalières on 23/02/13.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "WorstKPIItf.h"

@class CellMonitoring;

@interface NavCell : NSObject<NSCoding>

@property (nonatomic, readonly) NSString* cellId;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id) init:(NSString*) cellId latitude:(NSString*) theLatitude longitude:(NSString*) theLongitude;



+ (NSData*) buildNavigationData:(NSArray*) cells;
+ (NSData*) buildNavigationDataFromCellKPIs:(NSArray*) cellsKPIs  worstItf:(id<WorstKPIItf>) theWorstItf;
+ (NSData*) buildNavigationDataForCell:(CellMonitoring*) theCell;

@end
