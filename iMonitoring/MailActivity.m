//
//  MailActivity.m
//  iMonitoring
//
//  Created by sébastien brugalières on 28/09/13.
//
//

#import "MailActivity.h"

@interface MailActivity()
@property (nonatomic) UIImage* myMailImage;

@end

@implementation MailActivity

- (NSString *)activityType {
    return @"Mail activity";
}

- (NSString *)activityTitle {
    return @"Mail";
}

- (UIImage *)activityImage {
    self.myMailImage = [UIImage imageNamed:@"3_yellow.png"];
    return self.myMailImage;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return TRUE;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    
}

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryShare;
}

@end
