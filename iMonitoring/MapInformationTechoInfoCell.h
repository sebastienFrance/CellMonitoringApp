//
//  MapInformationTechoInfoCell.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 23/08/2014.
//
//

#import <UIKit/UIKit.h>

@class MapInfoTechnoDatasource;

@interface MapInformationTechoInfoCell : UITableViewCell

-(void) initializeWith:(MapInfoTechnoDatasource*) theDatasource;
@end
