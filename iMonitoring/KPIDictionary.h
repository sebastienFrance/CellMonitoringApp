//
//  KPIDictionary.h
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 11/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicTypes.h"

@class KPI;

@interface KPIDictionary : NSObject

@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSString* theDescription;

#pragma mark - Create KPI Dictionary

- (id) init:(NSString *) name description:(NSString*) theDescription;
- (void) addKPI:(KPI*) theKPI;
+ (Boolean) loadKPIsdictionaries:(id) theData;

#pragma mark - get KPIs from Dictionary

- (KPI*) findKPIbyInternalName:(NSString*) theKPIName;
- (KPI*) findKPIbyInternalName:(NSString*) theKPIName forTechno:(DCTechnologyId) technology;

- (NSArray*) getKPIs:(DCTechnologyId) theTechno;
- (NSDictionary*) getKPIsPerDomain:(DCTechnologyId) theTechno;

// currentIndex:
//  - First index is the Domain of the KPI
//  - Second index is the KPI inside de domain
- (NSIndexPath*) getPreviousKPIByDomain:(NSIndexPath*) currentIndex techno:(DCTechnologyId) theTechno;
- (NSIndexPath*) getNextKPIByDomain:(NSIndexPath*) currentIndex techno:(DCTechnologyId) theTechno;
- (NSIndexPath*) getLastKPIbyDomain:(DCTechnologyId) theTechno;
- (KPI*) getKPIbyDomain:(NSIndexPath*) index  techno:(DCTechnologyId) theTechno;

- (NSArray*) getSectionsHeader:(DCTechnologyId) theTechno;
@end
