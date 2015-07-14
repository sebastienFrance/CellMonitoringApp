//
//  MarkedTableViewCell.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 28/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MarkedTableViewCell.h"
#import "CellBookmark+MarkedCell.h"
#import "DataCenter.h"
#import "DateUtility.h"
#import "Utility.h"

@interface MarkedTableViewCell()

@property (weak, nonatomic) IBOutlet UIView* theView;
@property (weak, nonatomic) IBOutlet UILabel* theCellName;
@property (weak, nonatomic) IBOutlet UILabel* theDate;
@property (weak, nonatomic) IBOutlet UILabel* theTechno;
@property (weak, nonatomic) IBOutlet UILabel* shortComment;


@end

@implementation MarkedTableViewCell



- (void) initialiazeWithCellBookmark:(CellBookmark*) theCellBookmark {
    self.theCellName.text = theCellBookmark.cellInternalName;
    self.theTechno.text = [BasicTypes getTechnoName:theCellBookmark.theTechnology];
    self.backgroundColor = [Utility getLightColorForBookmark:theCellBookmark.color];
    self.shortComment.text = theCellBookmark.comment;
    self.theDate.text = [DateUtility getDate:theCellBookmark.creationDate option:withHHmm];
}

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


- (void)willTransitionToState:(UITableViewCellStateMask)state {
    [super willTransitionToState:state];
    if ((state == UITableViewCellStateShowingDeleteConfirmationMask) || (state == UITableViewCellStateShowingEditControlMask)) {
        [UIView animateWithDuration:0.5
                         animations:^{self.theTechno.alpha = 0.0; self.accessoryView.alpha = 0.0; }];
    }
}

- (void)didTransitionToState:(UITableViewCellStateMask)state {
    [super didTransitionToState:state];
    if (state == UITableViewCellStateDefaultMask) {
        [UIView animateWithDuration:0.5
                         animations:^{self.theTechno.alpha = 1.0; self.accessoryView.alpha = 1.0;}];
    } 
}

@end
