//
//  MapInfoTechnoDatasource.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 12/08/2014.
//
//

#import <Foundation/Foundation.h>
#import "BasicTypes.h"

@class CellMonitoring;

@interface MapInfoTechnoDatasource : NSObject

@property(nonatomic, readonly) DCTechnologyId theTechno;

@property(nonatomic, readonly) NSMutableArray* cells;

@property(nonatomic, readonly) NSDictionary* cellsPerFrequencies;
@property(nonatomic, readonly) NSDictionary* cellsPerReleases;

@property(nonatomic, readonly) NSArray* allFrequencies;
@property(nonatomic, readonly) NSArray* allReleases;

@property(nonatomic, readonly) NSUInteger numberOfintraFreqNRs;
@property(nonatomic, readonly) NSUInteger numberOfinterFreqNRs;
@property(nonatomic, readonly) NSUInteger numberOfinterRATNRs;


-(instancetype) init:(DCTechnologyId) techno;

-(void) addCell:(CellMonitoring*) theCell;
-(void) addCells:(NSArray*) cells;
@end
