//
//  AzimuthsOverlayRenderer.m
//  CellMonitoring
//
//  Created by sébastien brugalières on 05/04/2014.
//
//

#import "AzimuthsOverlayRenderer.h"
#import "CellMonitoring.h"

@interface AzimuthsOverlayRenderer()

@property (nonatomic) NSSet* azimuthList;
@property (nonatomic) Boolean isDisplaySectorAngle;

@end


@implementation AzimuthsOverlayRenderer


- (id) initWithOverlay:(id <MKOverlay>)overlay cells:(NSArray*) theCells displaySectorAngle:(Boolean) displaySectorAngle {
    self = [super initWithOverlay:overlay];
    if (self) {
        
        _isDisplaySectorAngle = displaySectorAngle;
        
        // Use NSSet to ignore azimuth with the same value
        
        NSMutableSet* azimuthList = [[NSMutableSet alloc] init];
        for (CellMonitoring* currentCell in theCells) {
            [azimuthList addObject:currentCell.azimuth];
        }
        _azimuthList = azimuthList;
    }
    return self;
}

- (void)drawMapRect:(MKMapRect)mapRect
          zoomScale:(MKZoomScale)zoomScale
          inContext:(CGContextRef)context {
    
    
    for (NSString* currentAzimuth in self.azimuthList) {
        [self buildCellAzimuth:currentAzimuth context:context zoomScale:zoomScale];
    }
    
    
}

- (void) buildCellAzimuth:(NSString*) cellAzimuth context:(CGContextRef)context zoomScale:(MKZoomScale)zoomScale {
    NSInteger azimuth = [cellAzimuth doubleValue];
#if TARGET_OS_IPHONE
    UIGraphicsPushContext(context);
#else
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:FALSE]];
    [NSGraphicsContext saveGraphicsState];
#endif
    CGContextSaveGState(context);
    
    CGContextSetStrokeColorWithColor(context, [self azimuthStrokeColor:azimuth].CGColor);
    CGContextSetFillColorWithColor(context, [self azimuthFillColor:azimuth].CGColor);
    CGContextSetLineWidth(context, 1.2/zoomScale);
    
    CGFloat unit = MKMapRectGetWidth([self.overlay boundingMapRect])/4.0;
    
    // Create the triangle for the Azimuth
    CGMutablePathRef p = CGPathCreateMutable();
    CGPoint start = CGPointMake(unit * 2.0,unit * 2.0);
    CGPoint p1 = CGPointMake(unit * 4.0, unit * 2.0);
    
    double radius = unit * 2.0;
    double openAngle = 20.0;
    
    double x = unit * 2.0 + (radius * cos(openAngle*(M_PI/180.0)));
    double y = unit * 2.0 + (radius * sin(openAngle*(M_PI/180.0)));
    CGPoint p2 = CGPointMake(x, y);
    
    CGPoint points[] = {
        start, p1, p2
    };
    
    if (self.isDisplaySectorAngle) {
        [self addAzimuthText:context zoomScale:zoomScale azimuth:azimuth unit:unit angle:openAngle];
    }
    
    CGAffineTransform t1 = CGAffineTransformMakeTranslation(unit*2.0, unit*2.0);
    CGAffineTransform t2 = CGAffineTransformRotate(t1,(M_PI * azimuth) / 180.0);
    CGAffineTransform t3 = CGAffineTransformTranslate(t2, -unit*2.0, -unit*2.0);
    CGPathAddLines(p, &t3, points, 3);
    CGPathCloseSubpath(p);
    
    CGContextAddPath(context, p);
    CGContextDrawPath(context, kCGPathFillStroke);
    CGPathRelease(p);
 
    CGContextRestoreGState(context);
#if TARGET_OS_IPHONE
    UIGraphicsPopContext();
#else
    [NSGraphicsContext restoreGraphicsState];
#endif
}

- (void) addAzimuthText:(CGContextRef)context zoomScale:(MKZoomScale)zoomScale azimuth:(NSInteger) theAzimuth unit:(CGFloat) unit  angle:(double) openAngle{

    if (zoomScale <= 0.04) {
        return;
    }
    
#if TARGET_OS_IPHONE
    UIGraphicsPushContext(context);
#else
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:TRUE]];
    [NSGraphicsContext saveGraphicsState];
#endif
    
    CGContextSaveGState(context);
    
    NSString* azimuthString = [NSString stringWithFormat:@"%lu°", (long)theAzimuth];
 
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];

#if TARGET_OS_IPHONE
    UIFont* font = [UIFont fontWithName:@"Arial"
                                   size:(3.0 * MKRoadWidthAtZoomScale(zoomScale))];
    
    paragraphStyle.alignment = NSTextAlignmentCenter;
#else
    NSFont* font = [NSFont fontWithName:@"Arial"
                                   size:(3.0 * MKRoadWidthAtZoomScale(zoomScale))];
    
    paragraphStyle.alignment = NSCenterTextAlignment;
#endif
    
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSParagraphStyleAttributeName: paragraphStyle};
    
    double radius = unit * 1.4;
    openAngle /= 2.0;
    
    double x = unit * 2.0 + (radius * cos(openAngle*(M_PI/180.0)));
    double y = unit * 2.0 + (radius * sin(openAngle*(M_PI/180.0)));
    CGPoint start = CGPointMake(x, y);
    
    CGAffineTransform t1 = CGAffineTransformMakeTranslation(unit*2.0, unit*2.0);
    CGAffineTransform t2 = CGAffineTransformRotate(t1,(M_PI * theAzimuth) / 180.0);
    CGAffineTransform t3 = CGAffineTransformTranslate(t2, -unit*2.0, -unit*2.0);
    
    start = CGPointApplyAffineTransform(start, t3);
    
    [azimuthString drawAtPoint:start withAttributes:attributes];
    
    CGContextRestoreGState(context);

#if TARGET_OS_IPHONE
    UIGraphicsPopContext();
#else
    [NSGraphicsContext restoreGraphicsState];
#endif
}

#if TARGET_OS_IPHONE

- (UIColor*) azimuthStrokeColor:(NSUInteger) azimuth {
    if (azimuth <= 90)  {
        return [UIColor colorWithRed:1.0 green:0.0 blue:0 alpha:0.6];
    } else if (azimuth <= 180) {
        return [UIColor colorWithRed:0.0 green:1.0 blue:0 alpha:0.6];
    } else if (azimuth <= 270) {
        return [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.6];
    } else {
        return [UIColor colorWithRed:1 green:1.0 blue:0 alpha:0.6];
    }
}

- (UIColor*) azimuthFillColor:(NSUInteger) azimuth {
    if (azimuth <= 90)  {
        return [UIColor colorWithRed:0.7 green:0.0 blue:0 alpha:0.4];
    } else if (azimuth <= 180) {
        return [UIColor colorWithRed:0.0 green:0.7 blue:0 alpha:0.4];
    } else if (azimuth <= 270) {
        return  [UIColor colorWithRed:0.0 green:0.0 blue:0.7 alpha:0.4];
    } else {
        return  [UIColor colorWithRed:0.7 green:0.7 blue:0 alpha:0.4];
    }
}

#else

- (NSColor*) azimuthStrokeColor:(NSUInteger) azimuth {
    if (azimuth <= 90)  {
        return [NSColor colorWithRed:1.0 green:0.0 blue:0 alpha:0.6];
    } else if (azimuth <= 180) {
        return [NSColor colorWithRed:0.0 green:1.0 blue:0 alpha:0.6];
    } else if (azimuth <= 270) {
        return [NSColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.6];
    } else {
        return [NSColor colorWithRed:1 green:1.0 blue:0 alpha:0.6];
    }
}

- (NSColor*) azimuthFillColor:(NSUInteger) azimuth {
    if (azimuth <= 90)  {
        return [NSColor colorWithRed:0.7 green:0.0 blue:0 alpha:0.4];
    } else if (azimuth <= 180) {
        return [NSColor colorWithRed:0.0 green:0.7 blue:0 alpha:0.4];
    } else if (azimuth <= 270) {
        return  [NSColor colorWithRed:0.0 green:0.0 blue:0.7 alpha:0.4];
    } else {
        return  [NSColor colorWithRed:0.7 green:0.7 blue:0 alpha:0.4];
    }
}


#endif



@end
