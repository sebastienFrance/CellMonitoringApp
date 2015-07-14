//
//  MapInformationLTEANRInfoCell.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 23/08/2014.
//
//

#import <UIKit/UIKit.h>

@class MapInfoDatasource;

@interface MapInformationLTEANRInfoCell : UITableViewCell

-(void) initializeWith:(MapInfoDatasource*) datasource;

@end
