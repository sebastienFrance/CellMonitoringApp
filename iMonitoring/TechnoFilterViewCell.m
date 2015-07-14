//
//  TechnoFilterViewCell.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 30/08/2014.
//
//

#import "TechnoFilterViewCell.h"
@interface TechnoFilterViewCell()

@property (weak, nonatomic) IBOutlet UILabel *FrequencyDescription;
@property (weak, nonatomic) IBOutlet UILabel *cellCountForFrequency;

@end

@implementation TechnoFilterViewCell

-(void) initializeWith:(NSInteger) theCellCount freqOrRelease:(NSString*) theFrequencyOrReleaseName {
    self.FrequencyDescription.text = theFrequencyOrReleaseName;
    self.cellCountForFrequency.text = [NSString stringWithFormat:@"%lu", (long)theCellCount];
}


@end
