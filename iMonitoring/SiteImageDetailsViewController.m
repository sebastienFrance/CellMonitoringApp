//
//  SiteImageDetailsViewController.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 22/02/2015.
//
//

#import "SiteImageDetailsViewController.h"
#import "RequestUtilities.h"
#import "Utility.h"
#import "MBProgressHUD.h"
#import "CellMonitoring.h"

@interface SiteImageDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *theImage;
@property (weak, nonatomic) IBOutlet UIScrollView *theScrollview;

@property(nonatomic) NSString* theImageName;
@property(nonatomic) CellMonitoring* theCell;

@end

@implementation SiteImageDetailsViewController


-(void) initializeWithImageName:(NSString*) imageName  cell:(CellMonitoring*) theCell {
    self.theImageName = imageName;
    self.theCell = theCell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.theCell.id;
    
    self.theScrollview.delegate = self;
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"downloading Image";

    [RequestUtilities getSiteImage:self.theCell.siteId imageName:self.theImageName quality:HiRes delegate:self clientId:self.theImageName];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.theImage;
}

#pragma mark - HTMLDataResponse
- (void) dataReady:(id) theData clientId:(NSString*) theClientId {
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:TRUE];
    
    NSDictionary* theImageData = theData;
    NSArray* theImageString = theImageData[@"image"];
    self.theImage.image = [Utility imageFromJSONByteString:theImageString];
}

- (void) connectionFailure:(NSString*) theClientId {
    [MBProgressHUD hideAllHUDsForView:self.view animated:TRUE];
    NSLog(@"%s: Error loading image %@", __PRETTY_FUNCTION__, theClientId);
}

@end
