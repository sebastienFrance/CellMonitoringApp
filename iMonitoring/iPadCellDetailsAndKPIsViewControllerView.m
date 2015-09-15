//
//  iPadCellDetailsAndKPIsViewControllerView.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 17/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "iPadCellDetailsAndKPIsViewControllerView.h"
#import "iPadDetailsCellWithChartViewControllerView.h"
#import "CellKPIsDataSource.h"
#import "MBProgressHUD.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "CellMonitoring.h"
#import "MailCellKPI.h"
#import "KPIDictionary.h"
#import "KPI.h"
#import "DateUtility.h"
#import "KPIBarChart.h"
#import "MarkViewController.h"
#import "iPadCellDetailsAndKPIsViewTableViewController.h"
#import "CellBookmark+MarkedCell.h"
#import "UserPreferences.h"
#import "CorePlot-CocoaTouch.h"
#import "iPadDashboardViewImageCollection.h"
#import "KPIDictionaryManager.h"
#import "DashboardCellDetailsHelper.h"
#import "UserHelp.h"
#import "CellDetailsInfoBasicViewController.h"

@interface iPadCellDetailsAndKPIsViewControllerView () 

@property (nonatomic) UIViewController* currentPopover;

@property (nonatomic) NSUInteger numberOfRows;
@property (nonatomic) NSUInteger numberOfColumns;
@property (nonatomic) CGSize cellSizeAtStartPinchGesture;

@property (nonatomic) Boolean usedPageControl;

@property (nonatomic) NSArray<UIImage*>* currentBarChartViews;
@property (nonatomic) NSMutableArray<NSArray<UIImage*>*> *barChartViewsDic;

@property (nonatomic) DCMonitoringPeriodView currentMonitoringPeriod;

@property (nonatomic) Boolean isMarked;
@property (nonatomic) Boolean initialMarkedValue;

@property (weak, nonatomic) IBOutlet UIPageControl *thePageControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *MarkButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *viewScopeButton;

@property (weak, nonatomic) IBOutlet UICollectionView *theCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *theFlowLayout;
@property (nonatomic) Boolean isViewInitialization;

@end

@implementation iPadCellDetailsAndKPIsViewControllerView

static const NSUInteger SCREEN_SIZE = 1024;
static const NSUInteger CHART_INIT_WIDTH = 336;
static const NSUInteger CHART_INIT_HEIGHT = 207;
static const NSUInteger CELL_SIZE_MIN = 205; // Min cell size

#pragma mark - Initializations

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Bars initialization
    [self.navigationController setToolbarHidden:FALSE];
    self.navigationController.hidesBarsOnTap = FALSE;

    self.theCollectionView.dataSource = self;
    self.theCollectionView.delegate = self;
    self.isViewInitialization = TRUE;


    self.currentMonitoringPeriod = [UserPreferences sharedInstance].CellDashboardDefaultViewScope;
    [self buildChartForCurrentMonitoringPeriod];
    
    [self initializeTitle];
    [self initializeBookmark];

    self.viewScopeButton.enabled = FALSE;

    dispatch_queue_t buildImagesQueue = dispatch_queue_create("image builder", NULL);
    dispatch_async(buildImagesQueue, ^{

        for (NSUInteger i = 0; i < self.barChartViewsDic.count; i++) {
            if (self.barChartViewsDic[i] == (NSArray<UIImage*>*)[NSNull null]) {
                DashboardCellDetailsHelper* helper = [[DashboardCellDetailsHelper alloc] init:CHART_INIT_WIDTH height:CHART_INIT_HEIGHT];
                self.barChartViewsDic[i] = [helper createChartForMonitoringPeriod:self.theDatasource
                                                                 monitoringPeriod:i];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.viewScopeButton.enabled = TRUE;
        });
    });
    
    [[UserHelp sharedInstance] iPadHelpForCellDashboardView:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSLog(@"%s CollectionView ========== > height:%f width:%f", __PRETTY_FUNCTION__,self.theCollectionView.bounds.size.height, self.theCollectionView.bounds.size.width);

}

- (void)viewDidLayoutSubviews {
    [self intializeCollectionView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%s CollectionView ========== > height:%f width:%f", __PRETTY_FUNCTION__,self.theCollectionView.bounds.size.height, self.theCollectionView.bounds.size.width);

}

-(void) intializeCollectionView {

    if (self.isViewInitialization == TRUE) {
        NSLog(@"%s CollectionView ========== > height:%f width:%f", __PRETTY_FUNCTION__,self.theCollectionView.bounds.size.height, self.theCollectionView.bounds.size.width);
        CGSize defaultSize = CGSizeMake(self.theCollectionView.bounds.size.width / 4, (self.theCollectionView.bounds.size.height / 4) - 30);

        self.theFlowLayout.itemSize = defaultSize; //[UserPreferences sharedInstance].cellKPISize;

        self.numberOfRows = self.numberOfColumns = 4; //SCREEN_SIZE / self.theFlowLayout.itemSize.width;

        [self updatePageControl];
        self.isViewInitialization = FALSE;
    } else {
        NSLog(@"%s with transition", __PRETTY_FUNCTION__);
    }
}

- (IBAction)pinchGestureCalled:(UIPinchGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.cellSizeAtStartPinchGesture = _theFlowLayout.itemSize;
        return;
    }

    // base size is the cell size when the Pinch Gesture has started
    CGSize cellSize;
    cellSize.width = self.cellSizeAtStartPinchGesture.width * sender.scale;

    if ((sender.scale <= 1) && (cellSize.width > _theFlowLayout.itemSize.width)) {
        return;
    }

    if ((sender.scale >= 1) && (cellSize.width < _theFlowLayout.itemSize.width)) {
        return;
    }

    // Min Cell size with 5 rows & 5 columns per page
    if (cellSize.width < CELL_SIZE_MIN) {
        cellSize.width = CELL_SIZE_MIN;
    }

    // Max Cell size with 1 row & 1 column per page
    if (cellSize.width > self.theCollectionView.bounds.size.width) {
        cellSize.width = self.theCollectionView.bounds.size.width;
    }

    NSUInteger myRound = round(self.theCollectionView.bounds.size.width / cellSize.width);
    cellSize.width = self.theCollectionView.bounds.size.width / myRound;
    cellSize.height = self.theCollectionView.bounds.size.height / myRound;
    //    if (self.thePageControl.numberOfPages > 1) {
    //    cellSize.height -= self.thePageControl.bounds.size.height;
    //    }

    if (cellSize.width == _theFlowLayout.itemSize.width){
        return;
    }

    self.numberOfRows = self.numberOfColumns = self.theCollectionView.bounds.size.width / cellSize.width;
    [UserPreferences sharedInstance].cellKPISize = cellSize;

    [self updatePageControl];

    NSLog(@"%s CollectionView ========== > height:%f width:%f", __PRETTY_FUNCTION__,self.theCollectionView.bounds.size.height, self.theCollectionView.bounds.size.width);


    [UIView transitionWithView:self.theCollectionView
                      duration:0.5f
                       options:UIViewAnimationOptionCurveLinear
                    animations:^() {
                        _theFlowLayout.itemSize = cellSize;
                    }
                    completion:Nil];
}


// The number of Pages is computed from the total number of KPIs and number of rows & columns we want to display per pages
- (void) updatePageControl {
    
    NSDictionary<NSString*,NSArray<NSNumber*>*>* theKPIsValuesForCurrentPeriod = [self.theDatasource getKPIsForMonitoringPeriod:self.currentMonitoringPeriod];
    
    NSUInteger numberOfKPIs = theKPIsValuesForCurrentPeriod.count;

    NSUInteger numberOfPages = numberOfKPIs / (self.numberOfColumns*self.numberOfRows);
    if ((numberOfKPIs % (self.numberOfColumns*self.numberOfRows)) != 0) {
        numberOfPages++;
    }
    
    self.thePageControl.numberOfPages = numberOfPages;
    self.thePageControl.currentPage = 0;
}

- (void) initializeTitle {
    NSString* viewScope = [MonitoringPeriodUtility getStringForMonitoringPeriod:[UserPreferences sharedInstance].CellDashboardDefaultViewScope];
    self.title = [NSString stringWithFormat:@"Cell %@ / %@", _theCell.id ,viewScope];
}

-(void) initializeBookmark {
    self.isMarked = FALSE;

    self.initialMarkedValue = [CellBookmark isCellMarked:self.theCell];
    if (self.initialMarkedValue) {
        self.MarkButton.title = @"Unmark";

        self.isMarked = TRUE;
    }
}

#pragma mark - Popover Mgt

- (void) dismissAllPopovers{
    if (self.currentPopover != Nil) {
        [self.currentPopover dismissViewControllerAnimated:TRUE completion:Nil];
        self.currentPopover = Nil;
    }
}


-(void) presentViewControllerInPopover:(UIViewController*) contentController item:(UIBarButtonItem *)theItem {
    [self dismissAllPopovers];

    self.currentPopover = contentController;

    contentController.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController* popPC = contentController.popoverPresentationController;
    popPC.barButtonItem = theItem;
    popPC.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popPC.delegate = self;
    [self presentViewController:contentController animated:TRUE completion:Nil];
}

#pragma mark - UIPopoverPresentationControllerDelegate protocol

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController * _Nonnull)popoverPresentationController {
    [self dismissAllPopovers];
}

#pragma mark - MarkedCell protocol
- (void) marked:(UIColor*) theColor userText:(NSString*) theText {
    [self dismissAllPopovers];
    self.MarkButton.title = @"Unmark";
    
    [CellBookmark createCellBookmark:_theCell comments:theText color:theColor];
    
    self.isMarked = TRUE;
}

- (void) cancel {
    [self dismissAllPopovers];
}

#pragma mark - Button callback
- (IBAction)markButtonPushed:(id)sender {
    if (self.isMarked) {
        self.MarkButton.title = @"mark";      
        self.isMarked = FALSE;
        [CellBookmark removeCellBookmark:_theCell.id];
    } else { 
        [self displayMarkViewController:sender];
    }
}

-(void) displayMarkViewController:(UIBarButtonItem *) sender  {
    UIStoryboard* theStoryBoard = [UIStoryboard storyboardWithName:@"Bookmark" bundle:Nil];
    MarkViewController *viewController = [theStoryBoard instantiateViewControllerWithIdentifier:@"AddCellBookmark"];

    viewController.delegate = self;
    viewController.theCell = _theCell;

    [self presentViewControllerInPopover:viewController item:sender];
}

#pragma mark - Collection view management
- (IBAction)moveToPage:(id)sender forEvent:(UIEvent *)event {
 
    self.usedPageControl = TRUE;

    NSInteger page = _thePageControl.currentPage;

	// update the scroll view to the appropriate page
    CGRect frame = _theCollectionView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [_theCollectionView scrollRectToVisible:frame animated:YES];
    
}

#pragma mark - Popover callbacks

- (void) updateDashboardScope {
    [self dismissAllPopovers];
    
    NSUInteger oldMonitoringPeriod = self.currentMonitoringPeriod;
    
    [self updateCharts];
 
    [UIView transitionWithView:self.theCollectionView
                      duration:1.0f
                       options:oldMonitoringPeriod < self.currentMonitoringPeriod ? UIViewAnimationOptionTransitionCurlUp :  UIViewAnimationOptionTransitionCurlDown
                    animations:^() {
                        [self.theCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
                    }
                    completion:nil];
}


#pragma mark - Dashboard charts
- (void) updateCharts {
    [self initializeTitle];
    self.currentMonitoringPeriod = [UserPreferences sharedInstance].CellDashboardDefaultViewScope;

    [self buildChartForCurrentMonitoringPeriod];
}

- (void) buildChartForCurrentMonitoringPeriod {
    if (self.barChartViewsDic == Nil) {
        self.barChartViewsDic = [[NSMutableArray alloc] initWithObjects:[NSNull null], [NSNull null] , [NSNull null], [NSNull null], [NSNull null], nil];
    }
    
    self.currentBarChartViews = self.barChartViewsDic[self.currentMonitoringPeriod];
    if ([self.currentBarChartViews isEqual:[NSNull null]]) {
        DashboardCellDetailsHelper* helper = [[DashboardCellDetailsHelper alloc] init:CHART_INIT_WIDTH height:CHART_INIT_HEIGHT];
        self.currentBarChartViews = [helper createChartForMonitoringPeriod:self.theDatasource
                                                          monitoringPeriod:self.currentMonitoringPeriod];
        
        self.barChartViewsDic[self.currentMonitoringPeriod]= self.currentBarChartViews;
    }
}



#pragma mark - UICollectionViewDataSource Protocol
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.currentBarChartViews.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellId = @"KPIChartCollectionImageId";
    
    iPadDashboardViewImageCollection* cell = [self.theCollectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    UIImage* currentImage = self.currentBarChartViews[indexPath.row];
    cell.theImage.image = currentImage;
    
    return cell;
}


#pragma mark - UICollectionViewDelegate Protocol
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    KPIDictionary* dictionary = [KPIDictionaryManager sharedInstance].defaultKPIDictionary;

    NSIndexPath* indexOfCurrentKPI = [NSIndexPath indexPathForRow:0 inSection:0];
    for (NSUInteger i = 0; i < indexPath.row; i++) {
        indexOfCurrentKPI = [dictionary getNextKPIByDomain:indexOfCurrentKPI techno:_theCell.cellTechnology];
    }
    [self performSegueWithIdentifier:@"iPadOpenKPIDetails" sender:indexOfCurrentKPI];
}

#pragma mark - UIScrollViewDelegate Protocol

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.usedPageControl = FALSE;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.usedPageControl) return;

    CGFloat pageWidth = scrollView.frame.size.width;
    
    NSUInteger xoffset = scrollView.contentOffset.x;
    int page = floor((xoffset - (pageWidth / 2)) / pageWidth) + 1;
    
    // Check if we are before the last page
    if ((page == (_thePageControl.numberOfPages - 2)) && (xoffset>0)) {
        
        // compute the first index of the last page if we have
        NSUInteger numberOfKPIs = [self  collectionView:self.theCollectionView numberOfItemsInSection:0];
        
        // check if we have an incomplete final page
        if ((numberOfKPIs % (self.numberOfColumns*self.numberOfRows)) != 0) {
            NSUInteger numberOfPages = numberOfKPIs / (self.numberOfColumns*self.numberOfRows);
            NSUInteger indexForLastPage = (self.numberOfColumns*self.numberOfRows) * numberOfPages;
            
            NSArray* visibleCellIndexPath = [self.theCollectionView indexPathsForVisibleItems];
            for (NSIndexPath* currentIndex in visibleCellIndexPath) {
                if (currentIndex.row > (indexForLastPage)) {
                    page++;
                    break;
                }
            }
        }
    }
    
    _thePageControl.currentPage = page;
}

#pragma mark - Mail methods
- (IBAction)sendMail:(UIBarButtonItem *)sender {

    KPIDictionary* dictionary = [KPIDictionaryManager sharedInstance].defaultKPIDictionary;
#warning SEB:to be completed for alarms export
    MailCellKPI* mailbody = [[MailCellKPI alloc] init:self.theCell datasource:self.theDatasource KPIDictionary:dictionary
                                     monitoringPeriod:self.currentMonitoringPeriod alarms:Nil];
    [mailbody setImagesForPDF:self.currentBarChartViews title:self.theCell.id];
    
    [self presentViewControllerInPopover:[mailbody getActivityViewController] item:sender];
}


#pragma mark - prepareForSegue
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"iPadOpenKPIDetails"]) {
        iPadDetailsCellWithChartViewControllerView* modal = segue.destinationViewController;
        
        self.currentMonitoringPeriod = [UserPreferences sharedInstance].CellDashboardDefaultViewScope;
        NSIndexPath* index = (NSIndexPath*) sender;
        [modal initialize:self.theDatasource initialMonitoringPeriod:[UserPreferences sharedInstance].CellDashboardDefaultViewScope initialIndex:index];
    } else if ([segue.identifier isEqualToString:@"openViewScopeKPIsPopoverId"]) {
        iPadCellDetailsAndKPIsViewTableViewController *viewControllerForPopover =segue.destinationViewController;
        [viewControllerForPopover initialize:self];

        [self preparePopover:segue.destinationViewController];
    } else if ([segue.identifier isEqualToString:@"openCellInfoPopoverId"]) {
        UINavigationController *detailsMap = segue.destinationViewController;

        CellDetailsInfoBasicViewController* topView = (CellDetailsInfoBasicViewController* )detailsMap.topViewController;

        [topView initializeWithSimpleCellInfo:_theCell];
        [self preparePopover:segue.destinationViewController];
    }
}

-(void) preparePopover:(UIViewController*) contentController {
    [self dismissAllPopovers];
    self.currentPopover = contentController;
    UIPopoverPresentationController* popPC = self.currentPopover.popoverPresentationController;
    popPC.delegate = self;
}


@end
