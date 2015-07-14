//
//  AroundMeProtocols.h
//  iMonitoring
//
//  Created by sébastien brugalières on 31/10/12.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class NeighborOverlay;
@class CellMonitoring;

@protocol DisplayRegion <NSObject>

- (void) showRegionFromAddress:(CLLocationCoordinate2D) coordinate address:(NSString*) theAddress;
- (void) showRegionFromSelectedCell:(CLLocationCoordinate2D) coordinate withSelectedCell:(NSString*) cellName;
- (void) showNeighborInRegion:(NeighborOverlay*) theNeighbor;

- (MKMapView*) getMapView;

@end

@protocol MarkedCell
#if TARGET_OS_IPHONE
- (void) marked:(UIColor*) theColor userText:(NSString*) theText;
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE
- (void) marked:(NSColor*) theColor userText:(NSString*) theText;
#endif
- (void) cancel;


@end
