//
//  MapInformationViewController.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 23/08/2014.
//
//

#import <Foundation/Foundation.h>
#import "RequestUtilities.h"
#import "MapInfoDatasource.h"

@interface MapInformationViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, MapInfoDataSourceDelegate>

@property(nonatomic) NSArray* listOfCells;

@end
