//
//  BookmarkEntryPoint.m
//  iMonitoring
//
//  Created by sébastien brugalières on 25/11/2013.
//
//

#import "BookmarkEntryPoint.h"
#import "MarkViewController.h"
#import "AroundMeViewItf.h"
#import "DataCenter.h"
#import "AroundMeViewMgt.h"

@interface BookmarkEntryPoint ()

@end

@implementation BookmarkEntryPoint

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
    
    [self.navigationController setToolbarHidden:TRUE animated:FALSE];
    self.navigationController.hidesBarsOnTap = FALSE;

    
	// Do any additional setup after loading the view.
    id<AroundMeViewItf> theAroundMeImpl = [DataCenter sharedInstance].aroundMeItf;
   
    MarkViewController* markView = self.viewControllers[3];
    markView.delegate = theAroundMeImpl.viewMgt;
    markView.bookmark = TRUE;
    [markView theInitialText:theAroundMeImpl.viewMgt.lastSearch];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.navigationController setToolbarHidden:TRUE animated:FALSE];
    self.navigationController.hidesBarsOnTap = FALSE;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
