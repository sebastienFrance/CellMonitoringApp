//
//  MailWorstCellsKPI.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 20/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MailWorstCellsKPI.h"
#import "CellWithKPIValues.h"
#import "KPI.h"
#import "WorstKPIItf.h"
#import "CellMonitoring.h"
#import "NavCell.h"

@interface MailWorstCellsKPI()

@property (nonatomic) NSArray* KPIValuesPerCell;
@property (nonatomic) Boolean isTheAverageKPIs;
@property (nonatomic, weak) id<WorstKPIItf> theWorstItf;
@property (nonatomic) NSString* KPIName;

@end

@implementation MailWorstCellsKPI


- (id) init:(NSArray*) KPIValuesPerCell isAverageKPIs:(Boolean) isTheAverageKPIs worstItf:(id<WorstKPIItf>) theWorstItf KPIName:(NSString*) theKPIName {
    if (self = [super init]) {
        _KPIValuesPerCell = KPIValuesPerCell;
        _isTheAverageKPIs = isTheAverageKPIs;
        _theWorstItf = theWorstItf;
        _KPIName = theKPIName;
    }
    
    return self;
}

- (NSData*) buildNavigationData {
    return [NavCell buildNavigationDataFromCellKPIs:self.KPIValuesPerCell worstItf:self.theWorstItf];
}

- (NSString*) getMailTitle {
    return [NSString stringWithFormat:@"KPI %@", self.KPIName];
  
}

- (NSString*) getAttachmentFileName {
    return [NSString stringWithFormat:@"%@.iMon", self.KPIName];
}


- (NSString*) buildSpecificBody {
    NSMutableString* HTMLheader = [[NSMutableString alloc] init];
    
    CellWithKPIValues* firstCell = self.KPIValuesPerCell[0];
    [HTMLheader appendFormat:@"%@",[firstCell.theKPI KPIDescriptionToHTML]];
    
    [HTMLheader appendFormat:@"<h2>Worst Cells</h2>"];
    [HTMLheader appendFormat:@"<table border=\"1\">"];
    [HTMLheader appendFormat:@"<tr><th>Cell Name</th><th>KPI Value</th></tr>"];
    
//    NSArray* sortedKPIValuesPerCell = [self.KPIValuesPerCell sortedArrayUsingSelector:@selector(compareWithLastKPIValue:)];
    
    for (CellWithKPIValues* currCell in self.KPIValuesPerCell) {
  //      for (CellWithKPIValues* currCell in sortedKPIValuesPerCell) {
        [HTMLheader appendFormat:@"%@",[currCell export2HTML:self.isTheAverageKPIs]];
    }
    
    [HTMLheader appendFormat:@"</table>"];
    
    return HTMLheader; 
}




@end
