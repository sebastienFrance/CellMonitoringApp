//
//  HistoricalParameter.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 09/03/2015.
//
//

#import "HistoricalParameterCell.h"
#import "HistoricalParameters.h"
#import "DateUtility.h"

@interface HistoricalParameterCell() 
@property (weak, nonatomic) IBOutlet UILabel *theDate;
@property (weak, nonatomic) IBOutlet UILabel *numberOfChanges;
@end

@implementation HistoricalParameterCell

-(void) initializeWith:(HistoricalParameters*) parametersHistorical {
    self.theDate.text = [DateUtility getSimpleLocalizedDate:parametersHistorical.theDate];

    if (parametersHistorical.hasParameters == FALSE) {
        self.numberOfChanges.text = @"No data";
        self.numberOfChanges.textColor = [UIColor redColor];
        self.accessoryType = UITableViewCellAccessoryNone;
    } else {
        if (parametersHistorical.theDifferences.count == 0) {
            self.numberOfChanges.text = @"No changes";
            self.numberOfChanges.textColor = [UIColor greenColor];
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            self.numberOfChanges.text = [NSString stringWithFormat:@"Parameters with differences: %lu", (unsigned long)[parametersHistorical differencesCount]];
            self.numberOfChanges.textColor = [UIColor blackColor];
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
}

@end
