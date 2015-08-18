//
//  MailAbsract.m
//  iMonitoring
//
//  Created by sébastien brugalières on 07/10/12.
//
//

#import "MailAbstract.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "CorePlot-CocoaTouch.h"
#import "iMonNavigationDataActivity.h"
#import "iMonImageActivity.h"
#import "iMonPDFActivity.h"
#import "iMonMailContentActivity.h"

@interface MailAbstract()
    

@property (nonatomic) NSData* pdf;
@property (nonatomic) NSString* pdfFileName;

@end

@implementation MailAbstract

- (NSString*) buildMailBody {
    NSMutableString* HTMLheader = [[NSMutableString alloc] init];
    [HTMLheader appendString:@"<style type=\"text/css\"> h2 {color:blue;} p {color:black;} </style>"];
    
    [HTMLheader appendString:@"<br><br><br>"];
    [HTMLheader appendFormat:@"%@", [self buildSpecificBody]];
    
    return HTMLheader;
}

- (NSString*) buildSpecificBody {
    return @"Not implemented";
}

- (NSData*) buildNavigationData {
    return Nil;
}


- (void) setGraphImageAttachment:(CPTXYGraph*) theGrah title:(NSString*) graphTitleName {
    UIImage* newImage = [theGrah imageOfLayer];
    self.graphToPNGImage = UIImagePNGRepresentation(newImage);
    self.graphImageName = [NSString stringWithFormat:@"%@.png",graphTitleName];
}

- (void) setImagesForPDF:(NSArray*) images title:(NSString*) PDFTitle {
    
    self.pdfFileName = [NSString stringWithFormat:@"%@.pdf", PDFTitle];
    self.pdf = [MailAbstract buildPDFFromImages:images];
}

+ (NSData*) buildPDFFromImages:(NSArray*) images {
    NSMutableData* pdfData = [[NSMutableData alloc] init];
    
    UIGraphicsBeginPDFContextToData(pdfData, CGRectZero, nil);
    
    double currentHeight = 0.0;
    
    for (UIImage* currentImage in images)
    {
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, currentImage.size.width, currentImage.size.height), nil);
        
        [currentImage drawInRect:CGRectMake(0, currentHeight, currentImage.size.width, currentImage.size.height)];
    }
    UIGraphicsEndPDFContext();
    return pdfData;
}


- (NSString*) getMailTitle {
    return @"No title";
}

- (NSString*) getAttachmentFileName {
    return @"NoFileName";
}

- (void) presentActivityViewFrom:(UIViewController*) currentView {

    UIActivityViewController* activityViewController = [self buildActivity];
    
    [currentView presentViewController:activityViewController animated:YES completion:nil];
}

- (UIPopoverController*) presentActivityViewFromPopover:(UIBarButtonItem*) button {
    
    UIActivityViewController* activityViewController = [self buildActivity];
    
    UIPopoverController* thePopover = [[UIPopoverController alloc]
                       initWithContentViewController:activityViewController];
    [thePopover presentPopoverFromBarButtonItem:button permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
    return thePopover;
}

-(UIActivityViewController*) getActivityViewController {
    return [self buildActivity];
}


- (UIActivityViewController*) buildActivity {
    NSMutableArray* activityItems = [[NSMutableArray alloc] init];
    
    NSString* mailContent = [NSString stringWithFormat:@"<html> %@ </html>", self.buildMailBody];
    [activityItems addObject:[[iMonMailContentActivity alloc] initWithData:mailContent]];
    

    if (self.graphImageName != Nil) {
        [activityItems addObject:[[iMonImageActivity alloc] initWithData:self.graphToPNGImage]];
    }
    if (self.pdfFileName != Nil) {
        [activityItems addObject:[[iMonPDFActivity alloc] initWithData:self.pdf]];
    }
    
    NSData* navData = self.buildNavigationData;
    if (navData != Nil) {
        iMonNavigationDataActivity* itemNavData = [[iMonNavigationDataActivity alloc] initWithData:navData];
        [activityItems addObject:itemNavData];
    }
    
    UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:Nil];
    
    // Exclude all except : UIActivityTypeAirDrop & UIActivityTypeMail
    NSArray* excludedActivities = @[UIActivityTypePostToFacebook,
                                    UIActivityTypePostToTwitter,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypeMessage,
                                    UIActivityTypePrint,
                                    UIActivityTypeCopyToPasteboard,
                                    UIActivityTypeAssignToContact,
                                    UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList,
                                    UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo,
                                    UIActivityTypePostToTencentWeibo];
    
    activityViewController.excludedActivityTypes = excludedActivities;
    
    [activityViewController setValue:[self getMailTitle] forKey:@"subject"];

    return activityViewController;
}


@end
