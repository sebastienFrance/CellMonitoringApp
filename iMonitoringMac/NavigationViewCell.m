//
//  NavigationViewCell.m
//  iMonitoring
//
//  Created by sébastien brugalières on 20/02/2014.
//
//

#import "NavigationViewCell.h"
#import "DateUtility.h"

@interface NavigationViewCell()

@property (nonatomic) IBOutlet NSButton* showButton;
@property (nonatomic) IBOutlet NSTextField* routeName;
@property (nonatomic) IBOutlet NSTextField* distance;
@property (nonatomic) IBOutlet NSTextField* advisory;

@end

@implementation NavigationViewCell

-(void) initWithRoute:(MKRoute*) theRoute buttonId:(NSUInteger) row {
    self.routeName.stringValue = theRoute.name;
    
    NSUInteger distanceKM = (theRoute.distance)/1000;
    
    NSString* duration = [DateUtility getDurationToString:theRoute.expectedTravelTime withSeconds:FALSE];
    
    self.distance.stringValue = [NSString stringWithFormat:@"%ldkm / %@",distanceKM, duration];
    
    if (theRoute.advisoryNotices != Nil) {
        if (theRoute.advisoryNotices.count > 0) {
            self.advisory.stringValue = theRoute.advisoryNotices[0];
        }
    }
    
    self.showButton.tag = row;
}

@end
