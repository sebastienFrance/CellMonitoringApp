//
//  TechnoFilterViewCell.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 30/08/2014.
//
//

#import <UIKit/UIKit.h>

@interface TechnoFilterViewCell : UITableViewCell

-(void) initializeWith:(NSInteger) theCellCount freqOrRelease:(NSString*) theFrequencyOrReleaseName;

@end
