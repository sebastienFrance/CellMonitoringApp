//
//  RegionBookmark+MarkedRegion.h
//  iMonitoring
//
//  Created by sébastien brugalières on 05/03/13.
//
//

#import "RegionBookmark.h"
#import <MapKit/MapKit.h>
#import "BasicTypes.h"

@interface RegionBookmark (MarkedRegion)
#if TARGET_OS_IPHONE
+ (RegionBookmark*) createMarkedRegion:(MKMapCamera*) theRegion color:(UIColor*) theColor name:(NSString*) theName;
#endif
+ (NSArray*) loadBookmarks;
+ (void) remove:(RegionBookmark*) bookmark;

- (void) setTheRegion:(MKMapCamera*)theRegion;
- (MKMapCamera*) theRegion;

- (NSComparisonResult)compareByName:(RegionBookmark *)otherObject;
- (NSComparisonResult)compareByColor:(RegionBookmark *)otherObject;
- (NSComparisonResult)compareByTechnology:(RegionBookmark*)otherObject;
- (NSComparisonResult)compareByDate:(RegionBookmark *)otherObject;
@end
