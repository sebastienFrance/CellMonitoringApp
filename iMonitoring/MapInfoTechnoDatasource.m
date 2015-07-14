//
//  MapInfoTechnoDatasource.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 12/08/2014.
//
//

#import "MapInfoTechnoDatasource.h"
#import "CellMonitoring.h"

@interface MapInfoTechnoDatasource() {

    NSMutableArray* _cells;

    NSMutableDictionary* _cellsPerFrequencies;
    NSMutableDictionary* _cellsPerReleases;

}

@property(nonatomic) DCTechnologyId theTechno;

@end

@implementation MapInfoTechnoDatasource

-(instancetype) init:(DCTechnologyId) techno {
    if (self = [super init]) {
        _theTechno = techno;
        _cells = [[NSMutableArray alloc] init];
        _cellsPerFrequencies = [[NSMutableDictionary alloc] init];
        _cellsPerReleases = [[NSMutableDictionary alloc] init];

        _numberOfintraFreqNRs = 0;
        _numberOfinterFreqNRs = 0;
        _numberOfinterRATNRs = 0;
    }
    return self;
}

-(void) addCells:(NSArray*) cells {
    if (cells != Nil) {
        for (CellMonitoring* currentCell in cells) {
            [self addCell:currentCell];
        }
    }
}

-(void) addCell:(CellMonitoring*) theCell {
    [_cells addObject:theCell];

    NSMutableArray* cellsPerFreq = _cellsPerFrequencies[@(theCell.normalizedDLFrequency)];
    if (cellsPerFreq == Nil) {
        cellsPerFreq = [[NSMutableArray alloc] init];
        [_cellsPerFrequencies setObject:cellsPerFreq forKey:@(theCell.normalizedDLFrequency)];
    }
    [cellsPerFreq addObject:theCell];

    NSMutableArray* cellsPerRelease = _cellsPerReleases[theCell.releaseName];
    if (cellsPerRelease == Nil) {
        cellsPerRelease = [[NSMutableArray alloc] init];
        [_cellsPerReleases setObject:cellsPerRelease forKey:theCell.releaseName];
    }
    [cellsPerRelease addObject:theCell];

    _numberOfintraFreqNRs += theCell.numberIntraFreqNR;
    _numberOfinterFreqNRs += theCell.numberInterFreqNR;
    _numberOfinterRATNRs += theCell.numberInterRATNR;
}


-(NSArray*) allFrequencies {
    return self.cellsPerFrequencies.allKeys;
}

-(NSArray*) allReleases {
    return self.cellsPerReleases.allKeys;
}

@end
