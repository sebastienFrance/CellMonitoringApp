//
//  ZoneKPIsEntryPointViewController.m
//  iMonitoring
//
//  Created by sébastien brugalières on 23/11/2013.
//
//

#import "ZoneKPIsEntryPointViewController.h"
#import "MBProgressHUD.h"
#import "WorstKPIDataSource.h"
#import "KPIsViewController.h"
#import "ZoneKPIsAverageViewController.h"

@interface ZoneKPIsEntryPointViewController ()

@property(nonatomic) WorstKPIDataSource* dataSource;
@property(nonatomic) Boolean loadingData;

@property (weak, nonatomic) IBOutlet UITabBar *theTabBar;

@end

@implementation ZoneKPIsEntryPointViewController


- (void) worstDataIsLoaded:(NSError*) theError {
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    if (theError != Nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Communication Error" message:@"Cannot get KPIs from the server" delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
        
    } else {
        DataCenter* dc = [DataCenter sharedInstance];
        id<AroundMeViewItf> aroundVC = dc.aroundMeItf;
        aroundVC.lastWorstKPIs = self.dataSource;
        
        [self initializeViewControllers];
    }
}

- (IBAction)sendMailButton:(UIBarButtonItem *)sender {
    if (self.selectedIndex == 0) {
        ZoneKPIsAverageViewController* controllerAverage = self.viewControllers[0];
        [controllerAverage sendTheMail];
    } else {
        KPIsViewController* controller = self.viewControllers[1];
        [controller sendTheMail];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder])) {
        _dataSource = [[WorstKPIDataSource alloc] init:self];
    }
    return self;
}

- (void) initialize:(NSArray*) cells techno:(DCTechnologyId) theTechno  centerCoordinate:(CLLocationCoordinate2D) coordinate{
    [_dataSource initialize:cells techno:theTechno centerCoordinate:(CLLocationCoordinate2D) coordinate];
    _loadingData = TRUE;
}

- (void) initialize:(WorstKPIDataSource*) latestWorstKPIs {
    _dataSource = latestWorstKPIs;
    _dataSource.delegate = self;
    _loadingData = FALSE;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setToolbarHidden:TRUE animated:FALSE];
    self.navigationController.hidesBarsOnTap = FALSE;

    
    if (_loadingData == TRUE) {
        [_dataSource loadData:[MonitoringPeriodUtility sharedInstance].monitoringPeriod];
        // Do any additional setup after loading the view.
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = [NSString stringWithFormat:@"Loading %lu cells", (unsigned long)_dataSource.cellIndexedByName.count];
    } else {
        [self initializeViewControllers];
    }
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.navigationController setToolbarHidden:TRUE animated:FALSE];
    self.navigationController.hidesBarsOnTap = FALSE;
}


- (void) initializeViewControllers {
    KPIsViewController* controller = self.viewControllers[1];
    [controller initialize:_dataSource];
    ZoneKPIsAverageViewController* controllerAverage = self.viewControllers[0];
    [controllerAverage initialize:_dataSource];
    [controllerAverage refreshView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
