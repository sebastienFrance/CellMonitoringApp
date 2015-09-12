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


@end
