//
//  ZoneViewController.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 07/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ZoneViewController.h"
#import "DataCenter.h"
#import "RequestUtilities.h"
#import "MBProgressHUD.h"
#import "Zone.h"
#import "ZoneTableViewCell.h"
#import "AroundMeViewController.h"
#import "ZonesDatasSource.h"
#import "Utility.h"

@interface ZoneViewController()

@property (nonatomic) ZonesDatasSource* datasource;
@property (nonatomic) NSDictionary* listOfWorkingZones;
@property (nonatomic) NSDictionary* listOfObjectZones;

@property (nonatomic) DCTechnologyId currentTechno;

@end

@implementation ZoneViewController
@synthesize theTable;


- (IBAction)segmentPushed:(UISegmentedControl *)sender {
    
    switch (sender.selectedSegmentIndex) {
        case 0: {
            // order by color
            self.currentTechno = DCTechnologyLTE;
            break;
        }
        case 1: {
            // order by date            
            self.currentTechno = DCTechnologyWCDMA;
            break;
        }
        case 2: {
            // order by Name
            self.currentTechno = DCTechnologyGSM;
            break;
        }
        default: {
            NSLog(@"ZoneViewController::Error, unknown selected segment");
            return;
        }
    }
    [theTable reloadData];
    NSMutableArray* workingZones = self.listOfWorkingZones[@(self.currentTechno)];
    if (workingZones != Nil && workingZones.count > 0) {
        [theTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:TRUE];
    }
    
}


- (void)viewWillAppear:(BOOL)animated
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.navigationController setToolbarHidden:YES animated:YES];
    }

    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.navigationController setToolbarHidden:FALSE];
        self.navigationController.hidesBarsOnTap = FALSE;
    }
    
    self.currentTechno = DCTechnologyLTE;
    
    theTable.delegate = self;
    theTable.dataSource = self;
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading Zones";  

    self.datasource = [[ZonesDatasSource alloc] init:self];
    [self.datasource downloadZones];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - ZonesDatasSourceDelegate protocol
-(void) zonesResponse:(NSError*) theError {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (theError != Nil) {
        UIAlertController* alert = [Utility getSimpleAlertView:@"Connection Failure"
                                                       message:@"Cannot get Object & Working Zones."
                                                   actionTitle:@"OK"];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        self.listOfWorkingZones = self.datasource.listOfWorkingZones;
        self.listOfObjectZones = self.datasource.listOfObjectZones;
        [theTable reloadData];
    }
}

#pragma mark - UITableViewDataSource protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    NSString* headerName;
    switch (section) {
        case DCObjectZone: {
            headerName = @"Object Zone";
            break;
        }
        case DCWorkingZone: {
            headerName = @"Working Zone";
            break;
        }
        default: {
            headerName = @"unknown section";
            break;
        }
    }
    return headerName;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case DCObjectZone: {
            if (self.listOfObjectZones == Nil) {
                return 0;
            }

            NSMutableArray* objectZones = self.listOfObjectZones[@(self.currentTechno)];
            if (objectZones != Nil) {
                return objectZones.count;
            } else {
                return 0;
            }
        }
        case DCWorkingZone: {
            if (_listOfWorkingZones == Nil) {
                return 0;
            }
            
            NSMutableArray* workingZones = self.listOfWorkingZones[@(self.currentTechno)];
            if (workingZones != Nil) {
                return workingZones.count;
            } else {
                return 0;
            }
        }
        default: {
            return 0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"zoneCellId";
    ZoneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == Nil) {
        cell = [[ZoneTableViewCell alloc] init];     
    }
    
    
    NSMutableArray* zones;
    switch (indexPath.section) {
        case DCObjectZone: {
            zones = self.listOfObjectZones[@(self.currentTechno)];
            break;
        }
        case DCWorkingZone: {
            zones = self.listOfWorkingZones[@(self.currentTechno)];
            break;
         }
        default: {
            return Nil;
        }
    }
    
    Zone* currentZone = zones[indexPath.row];

    [cell initWithZone:currentZone];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSMutableArray* zones;
    switch (indexPath.section) {
        case DCObjectZone: {
            zones = self.listOfObjectZones[@(self.currentTechno)];
            break;
        }
        case DCWorkingZone: {
            zones = self.listOfWorkingZones[@(self.currentTechno)];
            break;
        }
        default: {
            return;
        }
    }

    Zone* currentZone = zones[indexPath.row];       
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) { 
        [self.navigationController popViewControllerAnimated:TRUE];
    }
    
    id<AroundMeViewItf> vc = [[DataCenter sharedInstance] aroundMeItf];
    [vc initiliazeWithZone:currentZone.name];
    

}


@end
