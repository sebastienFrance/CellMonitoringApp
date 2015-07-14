//
//  ZonesDatasSource.h
//  iMonitoring
//
//  Created by sébastien brugalières on 30/12/2013.
//
//

#import <Foundation/Foundation.h>
#import "RequestUtilities.h"

@protocol ZonesDatasSourceDelegate;

@interface ZonesDatasSource : NSObject<HTMLDataResponse>

@property(nonatomic, readonly) NSDictionary* listOfWorkingZones;
@property(nonatomic, readonly) NSDictionary* listOfObjectZones;
@property(nonatomic, readonly) NSArray* listOfAllZones;

-(id) init:(id<ZonesDatasSourceDelegate>) delegate;

-(void) downloadZones;


@end


@protocol ZonesDatasSourceDelegate <NSObject>

-(void) zonesResponse:(NSError*) theError;


@end
