//
//  NavigationViewCell.h
//  iMonitoring
//
//  Created by sébastien brugalières on 20/02/2014.
//
//

#import <Cocoa/Cocoa.h>
#import <MapKit/MapKit.h>

@interface NavigationViewCell : NSTableCellView

-(void) initWithRoute:(MKRoute*) theRoute buttonId:(NSUInteger) row;

@end
