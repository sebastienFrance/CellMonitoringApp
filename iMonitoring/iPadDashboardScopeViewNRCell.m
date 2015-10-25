//
//  iPadDashboardScopeViewNRCell.m
//  iMonitoring
//
//  Created by sébastien brugalières on 03/01/13.
//
//

#import "iPadDashboardScopeViewNRCell.h"
#import "CellMonitoring.h"

@implementation iPadDashboardScopeViewNRCell


- (void) initializeWithCell:(CellMonitoring*) theCell {
    self.intraFreqNRs.text = [NSString stringWithFormat:@"%lu", (unsigned long)theCell.numberIntraFreqNR];
    self.interFreqNRs.text = [NSString stringWithFormat:@"%lu", (unsigned long)theCell.numberInterFreqNR];
    self.interRATNRs.text = [NSString stringWithFormat:@"%lu", (unsigned long)theCell.numberInterRATNR];
}

@end
