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

@property (nonatomic) Boolean usedPageControl;

@property (nonatomic) NSArray* currentBarChartViews;

@property (nonatomic) NSMutableArray* barChartViewsDic;

@property (nonatomic) DCMonitoringPeriodView currentMonitoringPeriod;

@property (nonatomic) Boolean isMarked;
@property (nonatomic) Boolean initialMarkedValue;


@property (nonatomic) CGSize cellSizeAtStartPinchGesture;

@end

@implementation iPadCellDetailsAndKPIsViewControllerView


#pragma mark - Initializations
- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder])) {
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.navigationController setToolbarHidden:FALSE];
    self.navigationController.hidesBarsOnTap = FALSE;

    self.theCollectionView.dataSource = self;
    self.theCollectionView.delegate = self;
    
    self.theFlowLayout.itemSize = [UserPreferences sharedInstance].cellKPISize;

    self.numberOfRows = self.numberOfColumns = 1024 / self.theFlowLayout.itemSize.width;
    
    [self initializePages];
    
    
    self.currentMonitoringPeriod = [UserPreferences sharedInstance].CellDashboardDefaultViewScope;
    [self buildChartForCurrentMonitoringPeriod];
    
    [self initializeTitle];
    
    self.isMarked = FALSE;
    
    self.initialMarkedValue = [CellBookmark isCellMarked:_theCell];
    if (self.initialMarkedValue) {
        self.MarkButton.title = @"Unmark";
        
        self.isMarked = TRUE;
    }

    self.viewScopeButton.enabled = FALSE;

    dispatch_queue_t buildImagesQueue = dispatch_queue_create("image builder", NULL);
    dispatch_async(buildImagesQueue, ^{

        for (NSUInteger i = 0; i < self.barChartViewsDic.count; i++) {
            if (self.barChartViewsDic[i] == [NSNull null]) {
                DashboardCellDetailsHelper* helper = [[DashboardCellDetailsHelper alloc] init:306 height:207];
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

- (void) initializePages {
    
    NSDictionary* theKPIsValuesForCurrentPeriod = [self.theDatasource getKPIsForMonitoringPeriod:self.currentMonitoringPeriod];
    
    NSUInteger numberOfKPIs = theKPIsValuesForCurrentPeriod.count;
    
    
    
    NSUInteger numberOfPages = numberOfKPIs / (self.numberOfColumns*self.numberOfRows);
    if ((numberOfKPIs % (self.numberOfColumns*self.numberOfRows)) != 0) {
        numberOfPages++;
    }
    
    _thePageControl.numberOfPages = numberOfPages;
    _thePageControl.currentPage = 0;
}

- (void) initializeTitle {
    NSString* viewScope = [MonitoringPeriodUtility getStringForMonitoringPeriod:[UserPreferences sharedInstance].CellDashboardDefaultViewScope];
    
    self.title = [NSString stringWithFormat:@"Cell %@ / %@", _theCell.id ,viewScope];
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
    //UINavigationController *viewController =
  //  [self.storyboard instantiateViewControllerWithIdentifier:@"PopoverCellBookmarkId"];
    UIStoryboard* theStoryBoard = [UIStoryboard storyboardWithName:@"Bookmark" bundle:Nil];
  //  UINavigationController *viewController = [theStoryBoard instantiateViewControllerWithIdentifier:@"AddCellBookmark"];
    MarkViewController *viewController = [theStoryBoard instantiateViewControllerWithIdentifier:@"AddCellBookmark"];

   // MarkViewController* modal = (MarkViewController*) viewController.topViewController;
    viewController.delegate = self;
    viewController.theCell = _theCell;

    [self presentViewControllerInPopover:viewController item:sender];
}


- (IBAction)moveToPage:(id)sender forEvent:(UIEvent *)event {
 
    self.usedPageControl = TRUE;

    NSInteger page = _thePageControl.currentPage;

	// update the scroll view to the appropriate page
    CGRect frame = _theCollectionView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [_theCollectionView scrollRectToVisible:frame animated:YES];
    
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
    if (cellSize.width < 205) {
        cellSize.width = 205;
    }
    
    // Max Cell size with 1 row & 1 column per page
    if (cellSize.width > 1024) {
        cellSize.width = 1024;
    }

    NSUInteger myRound = round(1024.0 / cellSize.width);
    cellSize.width = 1024.0 / myRound;
    cellSize.height = 636.0 / myRound;
    
    if (cellSize.width == _theFlowLayout.itemSize.width){
        return;
    }
    
    self.numberOfRows = self.numberOfColumns = 1024 / cellSize.width;
    [UserPreferences sharedInstance].cellKPISize = cellSize;
    
    [self initializePages];
    
    
    [UIView transitionWithView:self.theCollectionView
                      duration:0.5f
                       options:UIViewAnimationOptionCurveLinear
                    animations:^() {
                        _theFlowLayout.itemSize = cellSize;
                    }
                    completion:nil];
    
}

#pragma mark - Popover callbacks

- (void) updateDashboardScope {
    [self dismissAllPopovers];
    
    NSUInteger oldMonitoringPeriod = self.currentMonitoringPeriod;
    
    [self updateCharts];
 
    [UIView transitionWithView:self.theCollectionView
                      duration:1.0f
                       options:oldMonitoringPeriod < self.currentMonitoringPeriod ? UIViewAnimationOptionTransitionCurlUp :  UIViewAnimationOptionTransitionCurlDown //UIViewAnimationOptionTransitionFlipFromLeft
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
        DashboardCellDetailsHelper* helper = [[DashboardCellDetailsHelper alloc] init:336 height:207];
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
    
 //   [self dismissAllPopovers];
    
    KPIDictionary* dictionary = [KPIDictionaryManager sharedInstance].defaultKPIDictionary;
#warning SEB:to be completed for alarms export
    MailCellKPI* mailbody = [[MailCellKPI alloc] init:_theCell datasource:self.theDatasource KPIDictionary:dictionary
                                     monitoringPeriod:self.currentMonitoringPeriod alarms:Nil];
    [mailbody setImagesForPDF:self.currentBarChartViews title:_theCell.id];
    
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
