//
//  CellAddressDetails.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 20/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CellAddressDetails.h"
#import "CellMonitoring.h"
#import "Utility.h"

@implementation CellAddressDetails


- (void) initializeWithCell:(CellMonitoring*) theCell {
    
    self.cellName.text = theCell.id;
    self.techno.text = theCell.techno;
    self.cellRelease.text = theCell.releaseName;
    self.cellSite.text = theCell.fullSiteName;

    self.dlFrequency.text = [Utility displayLongDLFrequency:theCell.normalizedDLFrequency earfcn:theCell.dlFrequency];


}


@end
