//
//  ParametersValueCell.h
//  iMonitoring
//
//  Created by sébastien brugalières on 07/01/13.
//
//

#import <UIKit/UIKit.h>

@class AttributeNameValue;

@interface ParametersValueCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *theParameterName;
@property (weak, nonatomic) IBOutlet UILabel *theParameterValue;

-(void) initializeWithAttrNameValue:(AttributeNameValue*) attrNameValue;

+(UITableViewCell*) createCellSimpleParameter:(UITableView *)tableView ParameterNameValue:(AttributeNameValue*) theParameterNameValue forIndexPath:(NSIndexPath*) indexPath ;


@end
