//
//  UIColorRGBValueTransformer.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 22/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIColorRGBValueTransformer.h"

@implementation UIColorRGBValueTransformer

// Here we override the method that returns the class of objects that this transformer can convert.
+ (Class)transformedValueClass {
    return [NSData class];
}

// Here we indicate that our converter supports two-way conversions.
// That is, we need  to convert UICOLOR to an instance of NSData and back from an instance of NSData to an instance of UIColor.
// Otherwise, we wouldn't be able to beth save and retrieve values from the persistent store.
+ (BOOL)allowsReverseTransformation {
    return YES;
}

// Takes a UIColor, returns an NSData
- (id)transformedValue:(id)value {
    UIColor *color = value;
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    NSString *colorAsString = [NSString stringWithFormat:@"%f,%f,%f,%f", components[0], components[1], components[2], components[3]];
    return [colorAsString dataUsingEncoding:NSUTF8StringEncoding];
}

// Takes an NSData, returns a UIColor
- (id)reverseTransformedValue:(id)value {
    NSString *colorAsString = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
    NSArray *components = [colorAsString componentsSeparatedByString:@","];
    CGFloat r = [components[0] floatValue];
    CGFloat g = [components[1] floatValue];
    CGFloat b = [components[2] floatValue];
    CGFloat a = [components[3] floatValue];
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

@end