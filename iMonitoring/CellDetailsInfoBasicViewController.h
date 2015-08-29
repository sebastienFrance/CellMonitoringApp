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
#import "CellMonitoring.h"
#import "AroundMeViewItf.h"

static const NSInteger SECTION_ADDRESS = 0;
static const NSInteger SECTION_ADDRESS_ROW_CELL_ADDRESS = 0;
static const NSInteger SECTION_GENERAL = 1;
static const NSInteger SECTION_GENERAL_ROW_NEIGHBORS_RELATIONS = 0;
static const NSInteger SECTION_GENERAL_ROW_PARAMETERS = 1;
static const NSInteger SECTION_GENERAL_ROW_ALARMS = 2;
static const NSInteger SECTION_GENERAL_ROW_ACTIONS_KPIS = 3; // Specific for iPad
static const NSInteger SECTION_KPIS = 2; // Specific for iPhone



@interface CellDetailsInfoBasicViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, CellAlarmListener, CellParametersDataSourceDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, HTMLDataResponse, MarkedCell>


@property(nonatomic, readonly) CellMonitoring* theCell;
@property(nonatomic,weak, readonly) id<AroundMeViewItf> delegate;
@property(nonatomic, readonly) Boolean isBasicCellInfos;
@property(nonatomic, readonly) CellAlarmDatasource* alarmDatasource;


-(void) initialize:(CellMonitoring*) theCell delegate:(id<AroundMeViewItf>) theDelegate;
-(void) initializeWithSimpleCellInfo:(CellMonitoring *)theCell;

-(void) displayCellTimezone:(NSString*) timeZone;

- (UITableViewCell *) buildCellForGeneralSection:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;


@end
