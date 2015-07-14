//
//  NavigationViewCell.m
//  iMonitoring
//
//  Created by sébastien brugalières on 25/02/2014.
//
//

#import "NavigationViewCell.h"
#import "DateUtility.h"

@interface NavigationViewCell()
@property (weak, nonatomic) IBOutlet UILabel *routeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceAndDurationLabel;
@property (weak, nonatomic) IBOutlet UILabel *advisoryLabel;

@end

@implementation NavigationViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void) initWithRoute:(MKRoute*) theRoute buttonId:(NSUInteger) row {
    self.routeNameLabel.text = theRoute.name;
    
    NSUInteger distanceKM = (theRoute.distance)/1000;
    
    NSString* duration = [DateUtility getDurationToString:theRoute.expectedTravelTime withSeconds:FALSE];
    
    self.distanceAndDurationLabel.text = [NSString stringWithFormat:@"%lukm / %@",(unsigned long)distanceKM, duration];
    
    if (theRoute.advisoryNotices != Nil) {
        if (theRoute.advisoryNotices.count > 0) {
            self.advisoryLabel.text = theRoute.advisoryNotices[0];
        }
    }

}


@end
