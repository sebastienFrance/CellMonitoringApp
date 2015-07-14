//
//  CellParametersDifferencesViewCell.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 15/03/2015.
//
//

#import <UIKit/UIKit.h>
@class HistoricalParameters;

@interface CellParametersDifferencesViewCell : UITableViewCell

-(void) initializeWith:(HistoricalParameters*) historicalData sectionName:(NSString*) theSectionName parameterName:(NSString*) theParameterName highlightDifferences:(Boolean) highlight;

@end
