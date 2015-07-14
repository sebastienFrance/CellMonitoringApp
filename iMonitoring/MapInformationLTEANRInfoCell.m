//
//  MapInformationLTEANRInfoCell.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 23/08/2014.
//
//

#import "MapInformationLTEANRInfoCell.h"
#import "MapInfoDatasource.h"
#import "MapInfoTechnoDatasource.h"

@interface MapInformationLTEANRInfoCell()
@property (weak, nonatomic) IBOutlet UILabel *countANRIntraFrequencyNRs;
@property (weak, nonatomic) IBOutlet UILabel *countANRInterFrequencyNRs;
@property (weak, nonatomic) IBOutlet UILabel *countANRInterRATNRs;
@property (weak, nonatomic) IBOutlet UILabel *countANRNoHo;
@property (weak, nonatomic) IBOutlet UILabel *countANRNoRemove;
@property (weak, nonatomic) IBOutlet UILabel *countANRMeasuredBy;

@end

@implementation MapInformationLTEANRInfoCell

-(void) initializeWith:(MapInfoDatasource*) datasource {

    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    [formatter setGroupingSeparator:@" "];
    [formatter setGroupingSize:3];
    [formatter setUsesGroupingSeparator:YES];

    MapInfoTechnoDatasource* theDatasource = [datasource getTechnoInfo:DCTechnologyLTE];

    float percentageIntraFreq = 0;
    float percentageInterFreq = 0;
    float percentageInterRAT = 0;

    if (theDatasource.cells.count > 0) {
        percentageIntraFreq = ((float)(datasource.LTECountANRIntraFreq) / theDatasource.cells.count) * 100.0;
        percentageInterFreq = ((float)(datasource.LTECountANRInterFreq) / theDatasource.cells.count) * 100.0;
        percentageInterRAT = ((float)(datasource.LTECountANRInterRAT) / theDatasource.cells.count) * 100.0;
    }

    self.countANRIntraFrequencyNRs.text = [NSString stringWithFormat:@"%@ (%.2f%%)", [formatter stringFromNumber:@(datasource.LTECountANRIntraFreq)], percentageIntraFreq];

    self.countANRInterFrequencyNRs.text = [NSString stringWithFormat:@"%@ (%.2f%%)", [formatter stringFromNumber:@(datasource.LTECountANRInterFreq)], percentageInterFreq];
    self.countANRInterRATNRs.text = [NSString stringWithFormat:@"%@ (%.2f%%)", [formatter stringFromNumber:@(datasource.LTECountANRInterRAT)], percentageInterRAT];
    self.countANRNoHo.text = [NSString stringWithFormat:@"%@", [formatter stringFromNumber:@(datasource.LTECountNoHo)]];
    self.countANRNoRemove.text = [NSString stringWithFormat:@"%@", [formatter stringFromNumber:@(datasource.LTECountNoRemove)]];
    self.countANRMeasuredBy.text = [NSString stringWithFormat:@"%@", [formatter stringFromNumber:@(datasource.LTEMeasuredByANR)]];
}


@end
