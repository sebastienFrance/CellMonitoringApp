//
//  KNPathTableViewController.m
//
//
//  Created by Kent Nguyen 12/1/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "KNPathTableViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface KNPathTableViewController ()

@property (nonatomic) CGRect   infoPanelInitialFrame;
@property (nonatomic) CGFloat  initalScrollIndicatorHeight;

@property (nonatomic) UIView * infoPanel;

-(void)moveInfoPanelToSuperView;
-(void)moveInfoPanelToIndicatorView;
-(void)slideOutInfoPanel;

@end

@implementation KNPathTableViewController

#pragma mark - Custom init


- (UITableView*) tableView {
    return Nil;
}

-(id)initWithStyle:(UITableViewStyle)style {
    if ((self = [self initWithStyle:style infoPanelSize:KNPathTableOverlayDefaultSize])) {
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    if (self)    {
        _enableInfoPanel = TRUE;
    }
    return self;
}


-(id)initWithStyle:(UITableViewStyle)style infoPanelSize:(CGSize)size {
    if ((self = [super init])) {
        [self initializeInfoPanel:size];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGSize size = self.infoPanelSize;
    size.width += 30.0; // Add padding
    
    [self initializeInfoPanel:size];
    [self initializeDefaultInfoLabel];
}

- (CGSize) infoPanelSize {
    return CGSizeMake([self maxWidthInfoLabel], 32.0);
}

- (void) setEnableInfoPanel:(Boolean)enableInfoPanel {
    if (enableInfoPanel == FALSE) {
        _enableInfoPanel = FALSE;
        [self moveInfoPanelToSuperView];
        //[self.infoPanel removeFromSuperview];
        //[self infoPanelDidDisappear:self.tableView];
    } else {
        _enableInfoPanel = TRUE;
    }
}


- (void) initializeDefaultInfoLabel {
    self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 4, [self maxWidthInfoLabel], 20)];
    self.infoLabel.font = [UIFont boldSystemFontOfSize:12];
    self.infoLabel.textAlignment = NSTextAlignmentLeft;
    self.infoLabel.textColor = [UIColor whiteColor];
    self.infoLabel.shadowColor = [UIColor blackColor];
    self.infoLabel.backgroundColor = [UIColor clearColor];
    self.infoLabel.shadowOffset = CGSizeMake(0, 1);
}

- (float) maxWidthInfoLabel {
    return 150.0;
}

- (void) initializeInfoPanel:(CGSize) size {
    
    // The panel
    self.infoPanelInitialFrame = CGRectMake(-size.width, 0, size.width, size.height);
    self.infoPanel = [[UIView alloc] initWithFrame:self.infoPanelInitialFrame];
    
    // Initialize overlay panel with stretchable background
    UIImageView * bg = [[UIImageView alloc] initWithFrame:self.infoPanel.bounds];
    UIImage * overlay = [UIImage imageNamed:@"KNTableOverlay"];
    bg.image = [overlay stretchableImageWithLeftCapWidth:overlay.size.width/2.0 topCapHeight:overlay.size.height/2.0];
    [self.infoPanel setAlpha:0];
    [self.infoPanel addSubview:bg];
}


#pragma mark - Meant to be override

-(void)infoPanelWillAppear:(UIScrollView *)scrollView {
    if (![self.infoLabel superview]) [self.infoPanel addSubview:self.infoLabel];
}


//-(void)infoPanelWillAppear:(UIScrollView*)scrollView {}
-(void)infoPanelDidAppear:(UIScrollView*)scrollView {}
-(void)infoPanelWillDisappear:(UIScrollView*)scrollView {}
-(void)infoPanelDidDisappear:(UIScrollView*)scrollView {}
-(void)infoPanelDidScroll:(UIScrollView*)scrollView atPoint:(CGPoint)point {}
-(void)infoPanelDidStopScrolling:(UIScrollView*)scrollView {}

#pragma mark - Scroll view delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if (self.enableInfoPanel == FALSE) {
        return;
    }
    
    // Store height of indicator
    UIView * indicator = [[self.tableView subviews] lastObject];
    self.initalScrollIndicatorHeight = indicator.frame.size.height;
    
    // Starting from beginning
    if ([self.infoPanel superview] == nil) {
        // Add it to indicator
        [self moveInfoPanelToIndicatorView];
        
		// Prepare to slide in
        CGRect f = self.infoPanel.frame;
        CGRect f2= f;
        f2.origin.x += KNPathTableSlideInOffset;
		[self.infoPanel setFrame:f2];
        
        // Fade in and slide left
        [self infoPanelWillAppear:scrollView];
        [UIView animateWithDuration:KNPathTableFadeInDuration
                         animations:^{
                             self.infoPanel.alpha = 1;
                             self.infoPanel.frame = f;
                         } completion:^(BOOL finished) {
                             [self infoPanelDidAppear:scrollView];
                         }];
	} else if ([self.infoPanel superview] == self.view) { // If it is waiting to fade out, then maintain position
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(slideOutInfoPanel) object:nil];
        [self moveInfoPanelToIndicatorView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (self.enableInfoPanel == FALSE) {
        return;
    }
    
    
    UIView * indicator = [[scrollView subviews] lastObject];
    UITableView* theTableView = self.tableView;
    
    // Make sure the panel is visible
    if (self.infoPanel.alpha == 0) self.infoPanel.alpha = 1;
    
	// Current position is near bottom
	if (indicator.frame.size.height < self.initalScrollIndicatorHeight) {
        if (scrollView.contentOffset.y > 0 && [self.infoPanel superview] != self.view) {
            // Move panel to a fixed position
            [self.infoPanel removeFromSuperview];
            CGRect f = [self.view convertRect:self.infoPanel.frame fromView:indicator];
            CGRect target = CGRectMake(f.origin.x, theTableView.frame.size.height + theTableView.frame.origin.y -f.size.height, f.size.width, f.size.height);
            self.infoPanel.frame = target;
            [self.view addSubview:self.infoPanel];
        }
	} else if ([self.infoPanel superview] != indicator) { // Return the panel to indicator
        [self moveInfoPanelToIndicatorView];
    }
    
    // The current center of panel
    if (scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height) {
        [self infoPanelDidScroll:scrollView atPoint:CGPointMake(indicator.center.x,scrollView.contentSize.height-1)];
    } else {
        [self infoPanelDidScroll:scrollView atPoint:indicator.center];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // Remove it from indicator view but maintain position
    if (self.enableInfoPanel == FALSE) {
        return;
    }
    
    if ([self.infoPanel superview] != self.view) [self moveInfoPanelToSuperView];
    [self performSelector:@selector(slideOutInfoPanel) withObject:nil afterDelay:KNPathTableFadeOutDelay];
    [self infoPanelDidStopScrolling:scrollView];
}

#pragma mark - Helper methods

-(void)moveInfoPanelToSuperView {
    UITableView* theTableView = self.tableView;
    UIView * indicator = [[theTableView subviews] lastObject];
    CGRect f = [self.view convertRect:self.infoPanel.frame fromView:indicator];
    if ([self.infoPanel superview]) [self.infoPanel removeFromSuperview];
    self.infoPanel.frame = f;
    [self.view addSubview:self.infoPanel];
}

-(void)moveInfoPanelToIndicatorView {
    UITableView* theTableView = self.tableView;
    UIView * indicator = [[theTableView subviews] lastObject];
    CGRect f = self.infoPanelInitialFrame;
    f.origin.y = indicator.frame.size.height/2 - f.size.height/2;
    if ([self.infoPanel superview]) [self.infoPanel removeFromSuperview];
    [indicator addSubview:self.infoPanel];
    self.infoPanel.frame = f;
}

-(void)slideOutInfoPanel {
    UITableView* theTableView = self.tableView;
    CGRect f = self.infoPanel.frame;
    f.origin.x += KNPathTableSlideInOffset;
    [self infoPanelWillDisappear:theTableView];
    [UIView animateWithDuration:KNPathTableFadeOutDuration
                     animations:^{
                         self.infoPanel.alpha = 0;
                         self.infoPanel.frame = f;
                     } completion:^(BOOL finished) {
                         [self.infoPanel removeFromSuperview];
                         [self infoPanelDidDisappear:self.tableView];
                     }];
}


#pragma mark - Blank implementations

// Just to avoid Warning at compile time
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return Nil;
}

@end
