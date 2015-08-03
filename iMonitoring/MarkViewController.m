//
//  MarkViewController.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 20/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MarkViewController.h"
#import "DataCenter.h"
#import "CellMonitoring.h"
#import "RegionBookmark+MarkedRegion.h"

@interface MarkViewController ()

@property (weak, nonatomic) IBOutlet UIView *orangeBackground;
@property (weak, nonatomic) IBOutlet UIView *yellowBackground;
@property (weak, nonatomic) IBOutlet UIView *greenBackground;
@property (weak, nonatomic) IBOutlet UIView *blueBackground;
@property (weak, nonatomic) IBOutlet UIView *redBackground;

@property (weak, nonatomic) IBOutlet UITextField *textLabelForComments;
@property (weak, nonatomic) IBOutlet UILabel *labelForTitle;

@property (nonatomic) UIColor* selectedColor;
@property (nonatomic) NSString* initialText;

typedef NS_ENUM(NSUInteger, BookmarkColorId) {
    redBookmark = 0,
    orangeBookmark = 1,
    yellowBookmark = 2,
    greenBookmark = 3,
    blueBookmark = 4
};

@property (nonatomic) BookmarkColorId selectedBookmarkColor;
@property (nonatomic) NSArray* backgrounds;

@end

@implementation MarkViewController



- (IBAction)cancelButtonPushed:(UIButton *)sender {
    [self cancelAction];
}
- (IBAction)markButtonPushed:(UIButton *)sender {
    [self addNewBookmarkAction];
}

- (IBAction)cancekButton:(UIBarButtonItem *)sender {
    [self cancelAction];
}

- (void) cancelAction {
    [self.delegate cancel];
    if (self.navigationController != nil) {
        [self.textLabelForComments resignFirstResponder];
    } else {
        [self dismissViewControllerAnimated:TRUE completion:Nil];
    }
}

- (IBAction)applyButton:(UIBarButtonItem *)sender {
    [self addNewBookmarkAction];
}

- (void) addNewBookmarkAction {
    [self.delegate marked:self.selectedColor userText:self.textLabelForComments.text];
    
    if (self.navigationController != Nil) {
        self.textLabelForComments.text = @"";
        [self.textLabelForComments resignFirstResponder];
    } else {
        [self dismissViewControllerAnimated:TRUE completion:Nil];
    }
}


-(UIColor*) selectedColor {
    switch (self.selectedBookmarkColor) {
        case redBookmark: {
            return [UIColor redColor];
        }
        case orangeBookmark: {
            return [UIColor orangeColor];
        }
        case yellowBookmark: {
            return [UIColor yellowColor];
        }
        case greenBookmark: {
            return [UIColor greenColor];
        }
        case blueBookmark: {
            return [UIColor blueColor];
        }
    }
}

- (IBAction)redSelected:(UIButton *)sender {
    self.selectedBookmarkColor = redBookmark;
    [self updateBookmarkDisplay];
}

- (IBAction)orangeSelected:(UIButton *)sender {
    self.selectedBookmarkColor = orangeBookmark;
    [self updateBookmarkDisplay];
}

- (IBAction)yellowSelected:(UIButton *)sender {
    self.selectedBookmarkColor = yellowBookmark;
    [self updateBookmarkDisplay];
}

- (IBAction)greenSelected:(UIButton *)sender {
    self.selectedBookmarkColor = greenBookmark;
    [self updateBookmarkDisplay];
}
- (IBAction)blueSelected:(UIButton *)sender {
    self.selectedBookmarkColor = blueBookmark;
    [self updateBookmarkDisplay];
}


- (void) theInitialText:(NSString*) text {
    self.initialText = text;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.selectedColor = [UIColor redColor];
    
    self.selectedBookmarkColor = redBookmark;
    self.backgrounds = @[self.redBackground, self.orangeBackground, self.yellowBackground, self.greenBackground, self.blueBackground];

    [self updateBookmarkDisplay];
   
    if (self.bookmark) {
        self.labelForTitle.text = @"Bookmark";
        self.textLabelForComments.placeholder = @"enter bookmark name";
        
        if (self.initialText != Nil) {
            self.textLabelForComments.text = self.initialText;
        }
    } else {
        self.labelForTitle.text = self.theCell.id;
    }
    
    
    [self.textLabelForComments becomeFirstResponder];

}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.navigationController setToolbarHidden:FALSE];
        self.navigationController.hidesBarsOnTap = FALSE;
    }
}


-(void) updateBookmarkDisplay {
    for (NSUInteger i = 0; i < self.backgrounds.count; i++) {
        UIView* currentView  = self.backgrounds[i];
        if (i == self.selectedBookmarkColor) {
            currentView.backgroundColor = [UIColor blackColor];
        } else {
            currentView.backgroundColor = [UIColor clearColor];
        }
    }
}

@end
