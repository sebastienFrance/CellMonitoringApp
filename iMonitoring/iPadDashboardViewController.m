//
//  iPadDashboardViewController.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 07/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "iPadDashboardViewController.h"
#import "iPadCellDetailsAndKPIsViewControllerView.h"
#import "iPadDashboardWorstDetailsViewController.h"
#import "WorstKPIDataSource.h"
#import "MBProgressHUD.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "CellMonitoring.h"
#import "MailCellKPI.h"
#import "KPIDictionary.h"
#import "KPI.h"
#import "DateUtility.h"
#import "WorstKPIChart.h"
#import "CellWithKPIValues.h"
#import "iPadDashboardScopeViewController.h"
#import "AroundMeViewMgt.h"
#import "ZoneKPI.h"
#import "KPIBarChart.h"
#import "iPadDashboardZoneAverageViewController.h"
#import "ZoneKPIsAverageMail.h"
#import "MailOverviewWorstCellsKPIs.h"
#import "UserPreferences.h"
#import "iPadAroundMeImpl.h"
#import "iPadImonitoringViewController.h"
#import "iPadDashboardViewImageCollection.h"
#import "DashboardGraphicsHelper.h"
#import "UserHelp.h"

@interface iPadDashboardViewController()

@property(nonatomic) DCMonitoringPeriodView currentMonitoringPeriod;

@property(nonatomic) UIViewController* currentPopover;

@property(nonatomic) Boolean pageControlUsed;

@property(nonatomic) NSArray* worstAverageCharts;
@property(nonatomic) NSArray* worstLastGPCharts;
@property(nonatomic) NSArray* averageOnZoneCharts;

@property (nonatomic) CGSize cellSizeAtStartPinchGesture;
@property (nonatomic) NSUInteger numberOfRows;
@property (nonatomic) NSUInteger numberOfColumns;
@property (nonatomic) DashboardScopeId currentScope;


// New
@property(nonatomic) CellKPIsDataSource* cellDatasource;

@end

@implementation iPadDashboardViewController
@synthesize thePageControl;
@synthesize theCollectionView;


#pragma mark - Initializations


- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.theCollectionView.dataSource = self;
    self.theCollectionView.delegate = self;
    
    _theFlowLayout.itemSize = [UserPreferences sharedInstance].zoneCellSize;
    
    self.numberOfRows = self.numberOfColumns = 1024 / _theFlowLayout.itemSize.width;

    
    self.currentMonitoringPeriod = [MonitoringPeriodUtility sharedInstance].monitoringPeriod;

    [self.theCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"MY_CELL"];
    
    [self displayChartForCurrentScope];
    [self initialisePageController];
    
    
    [[UserHelp sharedInstance] iPadHelpForDashboardView:self];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.navigationController setToolbarHidden:FALSE];
    self.navigationController.hidesBarsOnTap  = FALSE;
}

#pragma mark - Worst Chart


- (void) displayChartForCurrentScope {

    self.currentScope = [UserPreferences sharedInstance].ZoneDashboardDefaultScope;
    switch (self.currentScope) {
        case DSScopeLastGP: {
            if (self.worstLastGPCharts == Nil) {
                DashboardGraphicsHelper* graphicHelper = [[DashboardGraphicsHelper alloc] init:336 height:207];
                self.worstLastGPCharts = [graphicHelper createAllWorstCharts:self.theDatasource.KPIs scope:DSScopeLastGP];
            }
            break;
        }
        case DSScopeLastPeriod: {
            if (self.worstAverageCharts == Nil) {
                DashboardGraphicsHelper* graphicHelper = [[DashboardGraphicsHelper alloc] init:336 height:207];
                self.worstAverageCharts = [graphicHelper createAllWorstCharts:self.theDatasource.worstAverageKPIs scope:DSScopeLastPeriod];
            }
            break;
        }
        case DSScopeAverageZoneAndPeriod: {
            if (self.averageOnZoneCharts == Nil) {
                DashboardGraphicsHelper* graphicHelper = [[DashboardGraphicsHelper alloc] init:336 height:207];
                
                self.averageOnZoneCharts = [graphicHelper createAllChartsWithAverageOnZone:self.theDatasource.zoneKPIs.objectEnumerator.allObjects
                                                                               requestDate:self.theDatasource.requestDate
                                                                          monitoringPeriod:self.currentMonitoringPeriod];
                
            }
            break;
        }
    }
}


#pragma mark - initializations

- (void) initializeTitle {
    MonitoringPeriodUtility* dc = [MonitoringPeriodUtility sharedInstance];
    NSString* period;
    
    DashboardScopeId defaultScope = [UserPreferences sharedInstance].ZoneDashboardDefaultScope;
    switch (defaultScope) {
        case DSScopeLastGP: {
            period = [MonitoringPeriodUtility getStringForGranularityPeriodName:dc.monitoringPeriod];
            break;
        }
        case DSScopeLastPeriod: {
            period = [MonitoringPeriodUtility getStringForGranularityPeriodDuration:dc.monitoringPeriod];
            break;
        }
        case DSScopeAverageZoneAndPeriod: {
            period = [NSString stringWithFormat:@"KPI average for %@",[MonitoringPeriodUtility getStringForGranularityPeriodDuration:dc.monitoringPeriod]];
            break;
        }
        default: {
            
        }
    }
    
    self.title = [NSString stringWithFormat:@"Dashboard %@ / %@",[BasicTypes getTechnoName:self.theDatasource.technology] ,period];
}



#pragma mark - Button callbacks
- (void) updateDashboardScope {
    [self dismissAllPopovers];
    [self initializeTitle];
    
    DashboardScopeId oldScope = self.currentScope;
    
    [self displayChartForCurrentScope];
    
    [self initialisePageController];
    
    [UIView transitionWithView:self.theCollectionView
                      duration:1.0f
                       options:oldScope < self.currentScope ? UIViewAnimationOptionTransitionCurlUp : UIViewAnimationOptionTransitionCurlDown
                    animations:^() {
                        [self.theCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
                    }
                    completion:nil];

}

- (IBAction)scopeButtonPressed:(UIBarButtonItem *)sender {
    iPadDashboardScopeViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DashboardScopeViewControllerId"];
    [viewController initialize:self];
    [self presentViewControllerInPopover:viewController item:sender];
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

- (IBAction)moveToPage:(id)sender forEvent:(UIEvent *)event {
    NSInteger page = self.thePageControl.currentPage;
	
	// update the scroll view to the appropriate page
    CGRect frame = self.theCollectionView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.theCollectionView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    self.pageControlUsed = YES;
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
    [UserPreferences sharedInstance].zoneCellSize = cellSize;
    
    [self initialisePageController];
    
    [UIView transitionWithView:self.theCollectionView
                      duration:0.1f
                       options:UIViewAnimationOptionCurveLinear
                    animations:^() {
                        _theFlowLayout.itemSize = cellSize;
                    }
                    completion:nil];
}

#pragma - Create dashboard

- (void) initialisePageController {

    DashboardScopeId defaultScope = [UserPreferences sharedInstance].ZoneDashboardDefaultScope;
    NSUInteger KPICount = 0;
    switch (defaultScope) {
        case DSScopeLastGP: {
            KPICount = self.worstLastGPCharts.count;
            break;
        }
        case DSScopeLastPeriod: {
            KPICount = self.worstAverageCharts.count;
            break;
        }
        case DSScopeAverageZoneAndPeriod: {
            KPICount = self.averageOnZoneCharts.count;
            break;
        }
    }

    NSUInteger numberOfPages = KPICount / (self.numberOfColumns*self.numberOfRows);
    if (KPICount % (self.numberOfColumns*self.numberOfRows)) {
        numberOfPages++;
    }
    
    self.thePageControl.numberOfPages = numberOfPages;
    self.thePageControl.currentPage = 0;
}


#pragma mark - UICollectionViewDataSource Protocol
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DashboardScopeId defaultScope = [UserPreferences sharedInstance].ZoneDashboardDefaultScope;
    switch (defaultScope) {
        case DSScopeLastGP: {
            return self.worstLastGPCharts.count;
        }
        case DSScopeLastPeriod: {
            return self.worstAverageCharts.count;
        }
        case DSScopeAverageZoneAndPeriod: {
            return self.averageOnZoneCharts.count;
        }
    }

    return self.theDatasource.worstAverageKPIs.objectEnumerator.allObjects.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellId = @"KPIChartCollectionImageId";
    
    iPadDashboardViewImageCollection* cell = [self.theCollectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    DashboardScopeId defaultScope = [UserPreferences sharedInstance].ZoneDashboardDefaultScope;
    UIImage* currentImage = Nil;
    switch (defaultScope) {
        case DSScopeLastGP: {
            currentImage = self.worstLastGPCharts[indexPath.row];
            break;
        }
        case DSScopeLastPeriod: {
            currentImage = self.worstAverageCharts[indexPath.row];
            break;
        }
        case DSScopeAverageZoneAndPeriod: {
            currentImage =  self.averageOnZoneCharts[indexPath.row];
            break;
        }
    }

    cell.theImage.image = currentImage;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate Protocol
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    // Return the list of KPIs and for each KPI the list of values
    DashboardScopeId  defaultScope = [UserPreferences sharedInstance].ZoneDashboardDefaultScope;
    switch (defaultScope) {
        case DSScopeLastGP: {
            [self performSegueWithIdentifier:@"iPadOpenWorstDetails" sender:indexPath];
            break;
        }
        case DSScopeLastPeriod: {
            [self performSegueWithIdentifier:@"iPadOpenWorstDetails" sender:indexPath];
            break;
        }
        case DSScopeAverageZoneAndPeriod: {
            [self performSegueWithIdentifier:@"iPadDashboardOpenAverageKPIDetails" sender:indexPath];
            break;
        }
    }
}


#pragma mark - UIScrollViewDelegate Protocol

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.pageControlUsed = FALSE;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.pageControlUsed) return;
    
    CGFloat pageWidth = scrollView.frame.size.width;
    
    NSUInteger xoffset = scrollView.contentOffset.x;
    int page = floor((xoffset - (pageWidth / 2)) / pageWidth) + 1;
    
    // Check if we are before the last page
    if ((page == (self.thePageControl.numberOfPages - 2)) && (xoffset>0)) {
        
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
    
    self.thePageControl.currentPage = page;
}

#pragma mark - Mail
- (IBAction)sendMail:(UIBarButtonItem *)sender {
    
    DashboardScopeId defaultScope = [UserPreferences sharedInstance].ZoneDashboardDefaultScope;
    
    MailAbstract* mail;
    switch (defaultScope) {
        case DSScopeLastPeriod: {
            mail = [[MailOverviewWorstCellsKPIs alloc] init:self.theDatasource];
            [mail setImagesForPDF:self.worstAverageCharts title:@"Dashboard"];
            break;
        }
        case DSScopeLastGP: {
             mail = [[MailOverviewWorstCellsKPIs alloc] init:self.theDatasource];
            [mail setImagesForPDF:self.worstLastGPCharts title:@"Dashboard"];
            break;
        }
        case DSScopeAverageZoneAndPeriod: {
            mail = [[ZoneKPIsAverageMail alloc] init:self.theDatasource];
            [mail setImagesForPDF:self.averageOnZoneCharts title:@"Dashboard"];
            break;
        }
        default: {
            
        }
    }
    
    [self presentViewControllerInPopover:[mail getActivityViewController] item:sender];
}

#pragma mark - Segue
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"iPadOpenWorstDetails"]) {
        iPadDashboardWorstDetailsViewController* vc = segue.destinationViewController;
        vc.parentDashboard = self;
        
        DashboardScopeId defaultScope = [UserPreferences sharedInstance].ZoneDashboardDefaultScope;
        Boolean isAverageValue = FALSE;
        switch (defaultScope) {
            case DSScopeLastGP: {
                isAverageValue = FALSE;
                break;
            }
            case DSScopeLastPeriod: {
                isAverageValue = TRUE;
                break;
            }
            case DSScopeAverageZoneAndPeriod: {
                // Not applicable
                break;
            }
        }
        
        NSIndexPath* indexOfCurrentKPI = (NSIndexPath*) sender;
        
        [vc initialize:self.theDatasource initialIndex:indexOfCurrentKPI.row isAverage:isAverageValue];
        self.currentMonitoringPeriod = [[MonitoringPeriodUtility sharedInstance] monitoringPeriod];
        
    } if ([segue.identifier isEqualToString:@"iPadDashboardOpenAverageKPIDetails"]) {
        iPadDashboardZoneAverageViewController* modal = segue.destinationViewController;
        
        self.currentMonitoringPeriod = [[MonitoringPeriodUtility sharedInstance] monitoringPeriod];

        NSIndexPath* indexOfCurrentKPI = (NSIndexPath*) sender;
        [modal initialize:self.theDatasource initialIndex:indexOfCurrentKPI.row];
    } else if ([segue.identifier isEqualToString:@"DashboardToCellKPIs"]) {
        iPadCellDetailsAndKPIsViewControllerView* controller = segue.destinationViewController;
        controller.theCell = self.cellDatasource.theCell;
        controller.theDatasource = self.cellDatasource;
    }
        
}

#pragma mark - CellDetailsItf protocol
// iPad Specific
- (void) dataIsLoaded {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self performSegueWithIdentifier:@"DashboardToCellKPIs" sender:Nil];
}



// iPad Specific
- (void) dataLoadingFailure {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertController* alert = [Utility getSimpleAlertView:@"Communication Error"
                                                   message:@"Cannot get KPIs from the server."
                                               actionTitle:@"OK"];
    [self presentViewController:alert animated:YES completion:nil];
}

// iPad Specific
- (void) timezoneIsLoaded:(NSString*) theTimeZone {
    // Nothing has to be done
}



#pragma mark - Navigation from detailed worst KPI modal view

- (void) displayCellOnMap:(CellMonitoring*) theCellonMap {

    iPadAroundMeImpl* aroundMe = (iPadAroundMeImpl*) [DataCenter sharedInstance].aroundMeItf;
    
    [self.navigationController popToViewController:aroundMe.aroundMeViewController animated:YES];
    
    [aroundMe showSelectedCellOnMap:theCellonMap];
}

- (void) displayCellKPIs:(CellMonitoring*) theCell {
    
    if (theCell.getCache != Nil) {
        self.cellDatasource = theCell.getCache;
        [self performSegueWithIdentifier:@"DashboardToCellKPIs" sender:Nil];
    } else {
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Loading KPIs";
        
        self.cellDatasource = [[CellKPIsDataSource alloc] init:self];
        
        [self.cellDatasource loadData:theCell];
    }
}




@end
