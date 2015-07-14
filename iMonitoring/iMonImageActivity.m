//
//  iMonImageActivity.m
//  iMonitoring
//
//  Created by sébastien brugalières on 01/10/13.
//
//

#import "iMonImageActivity.h"

@interface iMonImageActivity()

@property (nonatomic) NSData* theImageData;

@end

@implementation iMonImageActivity

- (id) initWithData:(NSData*) theData {
    if (self = [super init]) {
        _theImageData = theData;
    }
    return self;
    
}

// called to determine data type. only the class of the return type is consulted. it should match what -itemForActivityType: returns later
- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
	return self.theImageData;
}

// called to fetch data after an activity is selected. you can return nil.
- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    
    if ([activityType isEqualToString:UIActivityTypeMail]) {
        return self.theImageData;
    } else {
        return Nil;
    }
}


// if activity supports a Subject field. iOS 7.0
//- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType {
//    return @"the iMon PDF";
//}
//// UTI for item if it is an NSData. iOS 7.0. will be called with nil activity and then selected activity
//- (NSString *)activityViewController:(UIActivityViewController *)activityViewController dataTypeIdentifierForActivityType:(NSString *)activityType {
//    return @"com.alu.iMonitoring.Message";
//}

// if activity supports preview image. iOS 7.0
//- (UIImage *)activityViewController:(UIActivityViewController *)activityViewController thumbnailImageForActivityType:(NSString *)activityType suggestedSize:(CGSize)size {
//
//}
@end