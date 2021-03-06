//
//  SiteImageListTableViewCell.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 22/02/2015.
//
//

#import "SiteImageListTableViewCell.h"
#import "DateUtility.h"

@interface SiteImageListTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *theImage;

@property (weak, nonatomic) IBOutlet UILabel *imageDateAndTime;


@end


@implementation SiteImageListTableViewCell


-(void) initializeWithImage:(UIImage*) theImage dateAndTime:(NSDate*) theDate {
    self.theImage.image = theImage;
    
    
    
    self.imageDateAndTime.text = [NSDateFormatter localizedStringFromDate:theDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
