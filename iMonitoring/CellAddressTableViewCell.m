//
//  CellAddressTableViewCell.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 31/08/2015.
//
//

#import "CellAddressTableViewCell.h"
#import "CellMonitoring.h"
#import "Utility.h"
#import "CellBookmark+MarkedCell.h"


@interface CellAddressTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *theStreet;
@property (weak, nonatomic) IBOutlet UILabel *theCity;
@property (weak, nonatomic) IBOutlet UILabel *theCountry;

// iPhone Only
@property (weak, nonatomic) IBOutlet UIButton *markButton;


@end

@implementation CellAddressTableViewCell

- (void) initializeCellAddress:(CellMonitoring*) theCell showBookmarkButton:(Boolean) withBookmarkButton {

    if (withBookmarkButton) {
        if (self.markButton != Nil) {
            if ([CellBookmark isCellMarked:theCell]) {
                [self.markButton setTitle:@"Unmark" forState:UIControlStateNormal];
                [self.markButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            } else {
                [self.markButton setTitle:@"Mark" forState:UIControlStateNormal];
                [self.markButton setTitleColor:Nil forState:UIControlStateNormal];
            }
        }
    } else {
        self.markButton.hidden = TRUE;
    }


    if ([theCell hasAddress] == false) {
        CLGeocoder* reverseGeoCoder = [[CLGeocoder alloc] init];

        CLLocationCoordinate2D cellCoordinate = [theCell coordinate];
        CLLocation *coordinate = [[CLLocation alloc] initWithLatitude:cellCoordinate.latitude
                                                            longitude:cellCoordinate.longitude];

        [reverseGeoCoder reverseGeocodeLocation:coordinate completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error){
                self.theStreet.text = @"Cannot resolve address";
                self.theCity.text = @"";
                self.theCountry.text = @"";
                self.theTimezone.text = @"";
                return;
            }
            CLPlacemark* currentPlacemark = [placemarks lastObject];

            [theCell initialiazeAddress:currentPlacemark];

            [self setAddressAndTimeZoneInCell:theCell];
        }];
    } else {
        [self setAddressAndTimeZoneInCell:theCell];
    }
}

-(void) setAddressAndTimeZoneInCell:(CellMonitoring*) theCell {
    self.theStreet.text = theCell.street;
    self.theCity.text = theCell.city;
    self.theCountry.text = theCell.country;
    self.theTimezone.text = theCell.timezone;
}


@end
