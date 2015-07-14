//
//  EndDemoSessionViewController.m
//  iMonitoring
//
//  Created by sébastien brugalières on 15/03/2014.
//
//

#import "EndDemoSessionViewController.h"
#import "RequestLicense.h"

@interface EndDemoSessionViewController ()

@property (nonatomic) RequestLicense* requestALicence;

@end

@implementation EndDemoSessionViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)requestLicensePushed:(UIButton *)sender {
    
    self.requestALicence = [[RequestLicense alloc] init];
    [self.requestALicence requestLicenseByMail:self];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
