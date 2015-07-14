//
//  UserListViewCell.m
//  iMonitoring
//
//  Created by Sébastien Brugalières on 21/10/13.
//
//

#import "UserListViewCell.h"
#import "DateUtility.h"

@interface UserListViewCell() 
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *isAdmin;
@property (weak, nonatomic) IBOutlet UILabel *lastLogin;
@property (weak, nonatomic) IBOutlet UILabel *realName;

@end

@implementation UserListViewCell

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

- (void) initializeWithUser:(UserDescription*) user {
    self.userName.text = user.name;
    
    if (user.isAdmin) {
        self.isAdmin.text = @"Administrator";
        self.isAdmin.textColor = [UIColor redColor];
    } else {
        self.isAdmin.text = @"Simple user";
        self.isAdmin.textColor = [UIColor darkGrayColor];
    }
    
    NSDate* lastConnectionDate = user.LastConnectionDate;
    if (lastConnectionDate == Nil) {
        self.lastLogin.text = @"Never connected";
    } else {
        self.lastLogin.text = [DateUtility getDate:lastConnectionDate option:withHHmmss];
    }
    
    
    self.realName.text = [NSString stringWithFormat:@"%@ %@",user.firstName, user.lastName];
}

@end
