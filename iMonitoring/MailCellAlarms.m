//
//  MailCellAlarms.m
//  iMonitoring
//
//  Created by sébastien brugalières on 11/09/13.
//
//

#import "MailCellAlarms.h"
#import "CellMonitoring.h"
#import "CellAlarms2HTMLTable.h"

@interface MailCellAlarms()

@property (nonatomic) CellMonitoring* theCell;
@property (nonatomic) NSArray* alarms;

@end


@implementation MailCellAlarms

- (id) init:(CellMonitoring*) theCell alarms:(NSArray*) theAlarms {
    if (self = [super init]) {
        _theCell = theCell;
        _alarms = theAlarms;
    }
    
    return self;
    
}


- (NSData*) buildNavigationData {
    return [NavCell buildNavigationDataForCell:self.theCell];
}

- (NSString*) getMailTitle {
    return [NSString stringWithFormat:@"Cell %@ (%@)", self.theCell.id, self.theCell.techno];
}

- (NSString*) getAttachmentFileName {
    return [NSString stringWithFormat:@"%@.iMon", self.theCell.id];
}


- (NSString*) buildSpecificBody {
    NSMutableString* HTMLheader = [[NSMutableString alloc] init];
    [HTMLheader appendFormat:@"%@",[_theCell cellInfoToHTML]];
    
    [HTMLheader appendFormat:@"%@",[CellAlarms2HTMLTable exportCellAlarms:self.alarms cell:self.theCell]];
    
    return HTMLheader;
}




@end
