//
//  CellAddressDetails.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 20/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CellAddressDetails.h"
#import "CellMonitoring.h"
#import "Utility.h"
#import "CellBookmark+MarkedCell.h"

@implementation CellAddressDetails


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) initializeWithCell:(CellMonitoring*) theCell {
    // Initialization code
    self.directionButton.hue = 0.62f;
    self.directionButton.saturation = 1.0f;
    self.directionButton.brightness = 0.94f;
    
    self.cellName.text = theCell.id;
    self.techno.text = theCell.techno;
    self.cellRelease.text = theCell.releaseName;
    self.cellSite.text = theCell.fullSiteName;

    self.dlFrequency.text = [Utility displayLongDLFrequency:theCell.normalizedDLFrequency earfcn:theCell.dlFrequency];


    [self initializeCellAddress:theCell];

    if (self.markButton != Nil) {
        if ([CellBookmark isCellMarked:theCell]) {
            [self.markButton setTitle:@"Unmark" forState:UIControlStateNormal];
            [self.markButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        } else {
            [self.markButton setTitle:@"Mark" forState:UIControlStateNormal];
            [self.markButton setTitleColor:Nil forState:UIControlStateNormal];
        }
    }
}

- (void) initializeCellAddress:(CellMonitoring*) theCell {
    if ([theCell hasAddress] == false) {
        CLGeocoder* reverseGeoCoder = [[CLGeocoder alloc] init];
        
        CLLocationCoordinate2D cellCoordinate = [theCell coordinate];
        CLLocation *coordinate = [[CLLocation alloc] initWithLatitude:cellCoordinate.latitude
                                                            longitude:cellCoordinate.longitude];
        
        [reverseGeoCoder reverseGeocodeLocation:coordinate completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error){
                self.street.text = @"Cannot resolve address";
                self.city.text = @"";
                self.country.text = @"";
                self.timezone.text = @"";
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
    self.street.text = theCell.street;
    self.city.text = theCell.city;
    self.country.text = theCell.country;
    self.timezone.text = theCell.timezone;
}


@end
