//
//  HistoricalNRsOverviewCell.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 25/01/2015.
//
//

#import "HistoricalNRsOverviewCell.h"
#import "NeighborsDataSourceUtility.h"
#import "HistoricalCellNeighborsData.h"
#import "DateUtility.h"

@interface HistoricalNRsOverviewCell()
@property (weak, nonatomic) IBOutlet UILabel *theDate;
@property (weak, nonatomic) IBOutlet UILabel *IntraFrequenciesNRs;
@property (weak, nonatomic) IBOutlet UILabel *InterFrequenciesNRs;
@property (weak, nonatomic) IBOutlet UILabel *InterRatNRs;
@property (weak, nonatomic) IBOutlet UIButton *buttonAll;


@end

@implementation HistoricalNRsOverviewCell

-(void) initializeWith:(HistoricalCellNeighborsData*) theNeighborsHistory index:(NSUInteger) theIndex {
    self.buttonAll.tag = theIndex;
    self.theDate.text = [NSDateFormatter localizedStringFromDate:theNeighborsHistory.currentDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    
    // IntraFreq
    if (([theNeighborsHistory addedNRs:NeighborModeIntraFreq].count == 0) &&
        ([theNeighborsHistory removedNRs:NeighborModeIntraFreq].count ==0)) {
        self.IntraFrequenciesNRs.text = [NSString  stringWithFormat:@"%lu (no updates)",
                                         (unsigned long) theNeighborsHistory.currentNeighbors.neighborsIntraFreq.count];
    } else {
        self.IntraFrequenciesNRs.text = [NSString  stringWithFormat:@"%lu (Added: %lu / Removed: %lu)",
                                         (unsigned long) theNeighborsHistory.currentNeighbors.neighborsIntraFreq.count,
                                         (unsigned long) [theNeighborsHistory addedNRs:NeighborModeIntraFreq].count,
                                         (unsigned long) [theNeighborsHistory removedNRs:NeighborModeIntraFreq].count];
    }

    // InterFreq
    if (([theNeighborsHistory addedNRs:NeighborModeInterFreq].count == 0) &&
        ([theNeighborsHistory removedNRs:NeighborModeInterFreq].count == 0)) {
        self.InterFrequenciesNRs.text = [NSString  stringWithFormat:@"%lu (no updates)",
                                         (unsigned long) theNeighborsHistory.currentNeighbors.neighborsInterFreq.count];
    } else {
        self.InterFrequenciesNRs.text = [NSString  stringWithFormat:@"%lu (Added: %lu / Removed: %lu)",
                                         (unsigned long) theNeighborsHistory.currentNeighbors.neighborsInterFreq.count,
                                         (unsigned long) [theNeighborsHistory addedNRs:NeighborModeInterFreq].count,
                                         (unsigned long) [theNeighborsHistory removedNRs:NeighborModeInterFreq].count];
    }
    
    // InterRAT
    if (([theNeighborsHistory addedNRs:NeighborModeInterRAT].count == 0) &&
        ([theNeighborsHistory removedNRs:NeighborModeInterRAT].count == 0)) {
        self.InterRatNRs.text = [NSString  stringWithFormat:@"%lu (no updates)",
                                 (unsigned long)theNeighborsHistory.currentNeighbors.neighborsInterRAT.count];
    } else {
        self.InterRatNRs.text = [NSString  stringWithFormat:@"%lu (Added: %lu / Removed: %lu)",
                                 (unsigned long)theNeighborsHistory.currentNeighbors.neighborsInterRAT.count,
                                 (unsigned long) [theNeighborsHistory addedNRs:NeighborModeInterRAT].count,
                                 (unsigned long) [theNeighborsHistory removedNRs:NeighborModeInterRAT].count];
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
