//
//  MailAbsract.h
//  iMonitoring
//
//  Created by sébastien brugalières on 07/10/12.
//
//

#import <Foundation/Foundation.h>
#import <MessageUI/MFMailComposeViewController.h>

@class CPTXYGraph;

@interface MailAbstract : NSObject

@property (nonatomic) NSData* graphToPNGImage;
@property (nonatomic) NSString* graphImageName;


- (void) setGraphImageAttachment:(CPTXYGraph*) theGrah title:(NSString*) graphTitleName;
- (void) setImagesForPDF:(NSArray*) images title:(NSString*) PDFTitle;

- (void) presentActivityViewFrom:(UIViewController*) currentView;
-(UIActivityViewController*) getActivityViewController;

// Private methods
- (NSString*) buildMailBody;
- (NSData*) buildNavigationData;

- (NSString*) getMailTitle;
- (NSString*) getAttachmentFileName;





@end
