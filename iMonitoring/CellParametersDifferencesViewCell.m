//
//  CellParametersDifferencesViewCell.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 15/03/2015.
//
//

#import "CellParametersDifferencesViewCell.h"
#import "HistoricalParameters.h"
#import "Parameters.h"

@interface CellParametersDifferencesViewCell()

@property (weak, nonatomic) IBOutlet UILabel *theNewValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *oldValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *parameterNameLabel;

@end

@implementation CellParametersDifferencesViewCell


-(void) initializeWith:(HistoricalParameters*) historicalData sectionName:(NSString*) theSectionName parameterName:(NSString*) theParameterName highlightDifferences:(Boolean) highlight {
    NSString* theNewValue = [historicalData.theParameters parameterValue:theSectionName name:theParameterName];
    NSString* theOldValue = [historicalData.theOtherParameters parameterValue:theSectionName name:theParameterName];

    self.parameterNameLabel.text = theParameterName;
    self.theNewValueLabel.text = theNewValue;
    self.oldValueLabel.text = theOldValue;
    
    if (highlight) {
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.1];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }

}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
