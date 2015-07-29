//
//  iPadBookmarkMenuViewController.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 07/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "iPadBookmarkMenuViewController.h"
#import "MarkViewController.h"
#import "DataCenter.h"
#import "AroundMeViewItf.h"
#import "AroundMeViewMgt.h"

@interface iPadBookmarkMenuViewController ()

@end

@implementation iPadBookmarkMenuViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void) viewDidAppear:(BOOL)animated {
    [self.navigationController setToolbarHidden:TRUE];
    self.navigationController.hidesBarsOnTap = FALSE;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addRegionBookmark"]) {
        MarkViewController* controller = segue.destinationViewController;
        id<AroundMeViewItf> aroundMe = [DataCenter sharedInstance].aroundMeItf;
        
        AroundMeViewMgt* delegate = aroundMe.viewMgt; 
        controller.delegate = delegate; 
        controller.bookmark = TRUE;
        [controller theInitialText:delegate.lastSearch];
    } 
}


@end
