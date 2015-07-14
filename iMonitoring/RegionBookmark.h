//
//  RegionBookmark.h
//  iMonitoring
//
//  Created by sébastien brugalières on 04/08/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RegionBookmark : NSManagedObject

@property (nonatomic, retain) id color;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * pitch;
@property (nonatomic, retain) NSNumber * altitude;
@property (nonatomic, retain) NSNumber * heading;

@end
