//
//  WebsiteViewController.m
//  iMonitoring
//
//  Created by sébastien brugalières on 05/03/2014.
//
//

#import "WebsiteViewController.h"

@interface WebsiteViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *theWebView;

@end

@implementation WebsiteViewController

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
	// Do any additional setup after loading the view.
    
    NSURLRequest* theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://sebbrugalieres.fr/ios/iMonitoring/Presentation.html"]];
    
    [self.theWebView loadRequest:theRequest];
    [self.theWebView setScalesPageToFit:TRUE];
}
- (IBAction)closePushed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:TRUE completion:Nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
