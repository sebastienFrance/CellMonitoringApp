//
//  CellParametersDifferencesViewController.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 15/03/2015.
//
//

#import <UIKit/UIKit.h>

@class HistoricalParameters;
@class CellMonitoring;

@interface CellParametersDifferencesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>


-(void) initializeWith:(HistoricalParameters*) cellParametersWithDifferences forCell:(CellMonitoring*) sourceCell;

@end
