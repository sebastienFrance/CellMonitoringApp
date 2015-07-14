//
//  iMonNavigationDataActivity.m
//  iMonitoring
//
//  Created by sébastien brugalières on 29/09/13.
//
//

#import "iMonNavigationDataActivity.h"
#import "DataCenter.h"
#import "AroundMeViewItf.h"

@interface iMonNavigationDataActivity()

@property (nonatomic) NSData* theNavData;
@property (nonatomic) UIImage* theSmallImage;

@end

@implementation iMonNavigationDataActivity 

- (id) initWithData:(NSData*) theData {
    if (self = [super init]) {
        _theNavData = theData;
    }
    return self;
 
}

// called to determine data type. only the class of the return type is consulted. it should match what -itemForActivityType: returns later
- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
	return self.theNavData;
}

// called to fetch data after an activity is selected. you can return nil.
- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
	return self.theNavData;
}


// if activity supports a Subject field. iOS 7.0
- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType {
    return @"the iMon subject";
}
// UTI for item if it is an NSData. iOS 7.0. will be called with nil activity and then selected activity
- (NSString *)activityViewController:(UIActivityViewController *)activityViewController dataTypeIdentifierForActivityType:(NSString *)activityType {
    return @"com.alu.iMonitoring.iMon";
}

// if activity supports preview image. iOS 7.0

- (UIImage *)activityViewController:(UIActivityViewController *)activityViewController thumbnailImageForActivityType:(NSString *)activityType suggestedSize:(CGSize)size {
    UIImage* bigImage = [iMonNavigationDataActivity getImage:@"IconIMonitoring_v1_120px.png"];
    self.theSmallImage = [iMonNavigationDataActivity scaleToSize:size image:bigImage];
    return self.theSmallImage;
}



#if TARGET_OS_IPHONE
+ (UIImage*) getImage:(NSString*) imageName {
    UIImage * image = [UIImage imageNamed:imageName];
    return image;
}
#else
+ (NSImage*) getImage:(NSString*) imageName {
    NSImage * image = [NSImage imageNamed:[imageName stringByDeletingPathExtension]];
    return image;
}
#endif



+ (UIImage *)imageWithView:(UIView *)view
{
    CGSize size = view.bounds.size;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [view.layer renderInContext:context];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)scaleToSize:(CGSize)size image:(UIImage *) sourceImage{
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), sourceImage.CGImage);
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

@end
