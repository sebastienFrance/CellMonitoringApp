//
//  MapInformationGeneralInfoCell.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 23/08/2014.
//
//

#import "MapInformationGeneralInfoCell.h"
#import "MapInfoDatasource.h"
#import "MapInfoTechnoDatasource.h"

@interface MapInformationGeneralInfoCell()
@property (weak, nonatomic) IBOutlet UILabel *countLTECells;
@property (weak, nonatomic) IBOutlet UILabel *countWCDMACells;
@property (weak, nonatomic) IBOutlet UILabel *countGSMCells;

@end

@implementation MapInformationGeneralInfoCell

-(void) initializeWith:(MapInfoDatasource*) datasource {
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    [formatter setGroupingSeparator:@" "];
    [formatter setGroupingSize:3];
    [formatter setUsesGroupingSeparator:YES];

    MapInfoTechnoDatasource* LTEDatasource = [datasource getTechnoInfo:DCTechnologyLTE];
    MapInfoTechnoDatasource* WCDMADatasource = [datasource getTechnoInfo:DCTechnologyWCDMA];
    MapInfoTechnoDatasource* GSMDatasource = [datasource getTechnoInfo:DCTechnologyGSM];

    NSInteger totalCells = LTEDatasource.cells.count + WCDMADatasource.cells.count + GSMDatasource.cells.count;

    float percentageLTE = 0;
    float percentageWCDMA = 0;
    float percentageGSM = 0;
    if (totalCells > 0) {
        percentageLTE = ((float)(LTEDatasource.cells.count) / totalCells) * 100.0;
        percentageWCDMA = ((float)(WCDMADatasource.cells.count) / totalCells) * 100.0;
        percentageGSM = ((float)(GSMDatasource.cells.count) / totalCells) * 100.0;
    }


    self.countLTECells.text = [NSString stringWithFormat:@"%@ (%.2f%%)", [formatter stringFromNumber:@((unsigned long)LTEDatasource.cells.count)], percentageLTE];
    self.countWCDMACells.text = [NSString stringWithFormat:@"%@ (%.2f%%)", [formatter stringFromNumber:@((unsigned long)WCDMADatasource.cells.count)], percentageWCDMA];
    self.countGSMCells.text = [NSString stringWithFormat:@"%@ (%.2f%%)", [formatter stringFromNumber:@((unsigned long)GSMDatasource.cells.count)], percentageGSM];
}
@end
