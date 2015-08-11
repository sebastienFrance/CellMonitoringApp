//
//  AboutViewController.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 14/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AboutViewController.h"
#import "MBProgressHUD.h"
#import "RequestUtilities.h"
#import "SWRevealViewController/SWRevealViewController.h"
#import "Utility.h"

@interface AboutViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewLogo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *CodeAndDesignBottomHeightConstraint;

@property (nonatomic) NSLayoutConstraint* heightCon;

@property (nonatomic, strong) UIPanGestureRecognizer *dynamicTransitionPanGesture;

@end

@implementation AboutViewController

// {"LTECellCount":7005,"LTENeighborCount":0,"WCDMACellCount":54993,"WCDMANeighborCount":0}
@synthesize LTECellNumber;
@synthesize LTENeighborsNumber;
@synthesize WCDMACellNumber;
@synthesize WCDMANeighborsNumber;
@synthesize GSMCellNumber;
@synthesize GSMNeighborsNumber;


- (void) dataReady:(id) theData clientId:(NSString*) theClientId {
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    NSDictionary* data = theData;

    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    [formatter setGroupingSeparator:@" "];
    [formatter setGroupingSize:3];
    [formatter setUsesGroupingSeparator:YES];
    
    NSNumber* value = data[@"LTECellCount"];
    LTECellNumber.text = [formatter stringFromNumber:value];
    value = data[@"LTENeighborCount"];
    LTENeighborsNumber.text = [formatter stringFromNumber:value];
    value = data[@"WCDMACellCount"];
    WCDMACellNumber.text = [formatter stringFromNumber:value];
    value = data[@"WCDMANeighborCount"];
    WCDMANeighborsNumber.text = [formatter stringFromNumber:value];
    value = data[@"GSMCellCount"];
    GSMCellNumber.text = [formatter stringFromNumber:value];
    value = data[@"GSMNeighborCount"];
    GSMNeighborsNumber.text = [formatter stringFromNumber:value];

}

- (void) connectionFailure:(NSString*) theClientId {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertController* alert = [Utility getSimpleAlertView:@"Communication Error"
                                                   message:@"Cannot get data from the server."
                                               actionTitle:@"OK"];
    [self presentViewController:alert animated:YES completion:nil];
}
- (IBAction)menuButtonPushed:(UIBarButtonItem *)sender {
    [self.revealViewController revealToggle:Nil];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Update constraint for UIImage to match orientation
    [self.imageViewLogo removeConstraint:self.imageHeightConstraint];
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    [self initializeConstraintsForOrientation:orientation];

    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading data";  
    [RequestUtilities getAbout:self clientId:@"about"];

    // Can be Nil on the iPad
    if (self.revealViewController != Nil) {
        // Set the gesture
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }

	// Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void) initializeConstraintsForOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
        (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
        [self.view removeConstraint:self.heightCon];
        self.heightCon = [NSLayoutConstraint constraintWithItem:self.imageViewLogo attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:.20 constant:0];
        [self.view addConstraint:self.heightCon];
        self.CodeAndDesignBottomHeightConstraint.constant = 10.0;
    } else {
        [self.view removeConstraint:self.heightCon];
        self.heightCon = [NSLayoutConstraint constraintWithItem:self.imageViewLogo attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:.24 constant:0];
        [self.view addConstraint:self.heightCon];
        self.CodeAndDesignBottomHeightConstraint.constant = 60.0;
    }

}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self initializeConstraintsForOrientation:toInterfaceOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
