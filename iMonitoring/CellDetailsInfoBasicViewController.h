//
//  CellDetailsInfoBasicViewController.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 03/01/2015.
//
//

#import <UIKit/UIKit.h>
#import "CellAlarmDatasource.h"
#import "CellParametersDataSource.h"
#import "CellKPIsDataSource.h"
#import "CellMonitoring.h"
#import "AroundMeViewItf.h"
#import "CellTimezoneDataSource.h"



@interface CellDetailsInfoBasicViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, CellAlarmListener, CellParametersDataSourceDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, HTMLDataResponse, MarkedCell, CellKPIsLoadingItf, CellTimezoneDataSourceDelegate>


@property(nonatomic, readonly) CellMonitoring* theCell;
@property(nonatomic,weak, readonly) id<AroundMeViewItf> delegate;
@property(nonatomic, readonly) Boolean isBasicCellInfos;
@property(nonatomic, readonly) CellAlarmDatasource* alarmDatasource;


-(void) initialize:(CellMonitoring*) theCell delegate:(id<AroundMeViewItf>) theDelegate;
-(void) initializeWithSimpleCellInfo:(CellMonitoring *)theCell;

-(UITableViewCell *) buildCellForKPIsSection:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
