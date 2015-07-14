//
//  NavigationViewCell.h
//  iMonitoring
//
//  Created by sébastien brugalières on 25/02/2014.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface NavigationViewCell : UITableViewCell

-(void) initWithRoute:(MKRoute*) theRoute buttonId:(NSUInteger) row;

@end
