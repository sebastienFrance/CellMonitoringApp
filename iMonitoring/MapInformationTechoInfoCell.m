//
//  MapInformationTechoInfoCell.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 23/08/2014.
//
//

#import "MapInformationTechoInfoCell.h"
#import "MapInfoTechnoDatasource.h"
#import "Utility.h"

@interface MapInformationTechoInfoCell()

@property (weak, nonatomic) IBOutlet UILabel *cellsPerFrequency;
@property (weak, nonatomic) IBOutlet UILabel *cellsPerRelease;
@property (weak, nonatomic) IBOutlet UILabel *countIntraFreqNRs;
@property (weak, nonatomic) IBOutlet UILabel *countInterFreqNRs;
@property (weak, nonatomic) IBOutlet UILabel *countInterRATNRs;

@end

@implementation MapInformationTechoInfoCell

-(void) initializeWith:(MapInfoTechnoDatasource*) theDatasource {
    NSString* cellPerFrequency = @"No cell";
    NSString* cellPerRelease = @"No cell";
    if ((theDatasource.cellsPerFrequencies != Nil) && (theDatasource.cellsPerFrequencies.count  > 0)) {
        cellPerFrequency = [MapInformationTechoInfoCell buildCellsPerFrequencies:theDatasource.cellsPerFrequencies];
        cellPerRelease = [MapInformationTechoInfoCell buildCellsPerRelease:theDatasource.cellsPerReleases];
    }

    self.cellsPerFrequency.text = cellPerFrequency;
    self.cellsPerRelease.text = cellPerRelease;

    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    [formatter setGroupingSeparator:@" "];
    [formatter setGroupingSize:3];
    [formatter setUsesGroupingSeparator:YES];


    self.countIntraFreqNRs.text = [NSString stringWithFormat:@"%@",[formatter stringFromNumber:@((unsigned long)theDatasource.numberOfintraFreqNRs)]];
    self.countInterFreqNRs.text = [NSString stringWithFormat:@"%@",[formatter stringFromNumber:@((unsigned long)theDatasource.numberOfinterFreqNRs)]];
    self.countInterRATNRs.text = [NSString stringWithFormat:@"%@",[formatter stringFromNumber:@((unsigned long)theDatasource.numberOfinterRATNRs)]];
}


#pragma mark - Utilities

+ (NSString*) buildCellsPerFrequencies:(NSDictionary*) cellsPerFrequencies {
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    [formatter setGroupingSeparator:@" "];
    [formatter setGroupingSize:3];
    [formatter setUsesGroupingSeparator:YES];


    NSMutableString* cellsPerFreq = [[NSMutableString alloc] init];
    BOOL isFirst = TRUE;
    for (NSNumber* currentFreq in cellsPerFrequencies) {
        NSArray* cells = cellsPerFrequencies[currentFreq];
        if (isFirst == FALSE) {
            [cellsPerFreq appendString:@" / "];
        } else {
            isFirst = FALSE;
        }
        [cellsPerFreq appendFormat:@"%@ (%@)", [formatter stringFromNumber:@(cells.count)] , [Utility displayShortDLFrequency:[currentFreq floatValue]]];
    }
    return cellsPerFreq;
}

+(NSString*) buildCellsPerRelease:(NSDictionary*) cellsPerReleases {
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    [formatter setGroupingSeparator:@" "];
    [formatter setGroupingSize:3];
    [formatter setUsesGroupingSeparator:YES];

    NSMutableString* cellsPerRel = [[NSMutableString alloc] init];
    Boolean isFirst = TRUE;
    for (NSNumber* currentRelease in cellsPerReleases) {
        NSArray* cells = cellsPerReleases[currentRelease];
        if (isFirst == FALSE) {
            [cellsPerRel appendString:@" / "];
        } else {
            isFirst = FALSE;
        }
        [cellsPerRel appendFormat:@"%@ (%@)", [formatter stringFromNumber:@(cells.count)] , currentRelease];
    }
    return cellsPerRel;
}


@end
