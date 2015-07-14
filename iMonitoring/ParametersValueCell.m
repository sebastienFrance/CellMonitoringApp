//
//  ParametersValueCell.m
//  iMonitoring
//
//  Created by sébastien brugalières on 07/01/13.
//
//

#import "ParametersValueCell.h"
#import "AttributeNameValue.h"

@implementation ParametersValueCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) initializeWithAttrNameValue:(AttributeNameValue*) attrNameValue {
    self.theParameterName.text = attrNameValue.name;
    self.theParameterValue.text = attrNameValue.value;
}

+(UITableViewCell*) createCellSimpleParameter:(UITableView *)tableView ParameterNameValue:(AttributeNameValue*) theParameterNameValue forIndexPath:(NSIndexPath*) indexPath {
    static NSString *cellParamId = @"CellParameterValueId";
    ParametersValueCell* cell = [tableView dequeueReusableCellWithIdentifier:cellParamId forIndexPath:indexPath];
    
    [cell initializeWithAttrNameValue:theParameterNameValue];
    
    return cell;
}

@end
