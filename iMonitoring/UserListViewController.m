//
//  UserListViewController.m
//  iMonitoring
//
//  Created by Sébastien Brugalières on 21/10/13.
//
//

#import "UserListViewController.h"
#import "MBProgressHUD.h"
#import "UserDescription.h"
#import "UserListViewCell.h"
#import "CreateUserViewController.h"
#import "DisplayAndModifyUserViewController.h"
#import "Utility.h"

#import "SWRevealViewController/SWRevealViewController.h"

@interface UserListViewController ()
@property (weak, nonatomic) IBOutlet UITableView *theTable;
@property (weak, nonatomic) IBOutlet UISegmentedControl *theSegmentedControl;

@property (nonatomic) NSArray* users;
@property (nonatomic) NSIndexPath* deletedUserIndex;


@property (nonatomic, strong) UIPanGestureRecognizer *dynamicTransitionPanGesture;

@end

@implementation UserListViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
    
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.theTable.delegate = self;
    self.theTable.dataSource = self;

    // Can be Nil on the iPad
    if (self.revealViewController != Nil) {
        // Set the gesture
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }

    [self loadUsers];
    
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.navigationController setToolbarHidden:FALSE];
        self.navigationController.hidesBarsOnTap = FALSE;
    }
}



- (void) loadUsers {
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading Users";
    
    [RequestUtilities getUsers:self clientId:@"getUsers"];
 }


#define SEGMENT_USER_NAME 0
#define SEGMENT_LAST_NAME 1
#define SEGMENT_USER_ROLE 2
#define SEGMENT_LAST_CONNECTION_DATE 3

- (IBAction)menuButtonPushed:(UIBarButtonItem *)sender {
    [self.revealViewController revealToggle:Nil];
}

- (IBAction)segmentedPushed:(UISegmentedControl *)sender {
    [self reorderAndDisplayUserList:sender.selectedSegmentIndex];
}

- (void) reorderAndDisplayUserList:(NSUInteger) index {
    switch (index) {
        case SEGMENT_USER_NAME: {
            // order by Name
            self.users = [self.users sortedArrayUsingSelector:@selector(compareByName:)];
            break;
        }
        case SEGMENT_LAST_NAME: {
            // order by Last name
            self.users = [self.users sortedArrayUsingSelector:@selector(compareByLastName:)];
            break;
        }
        case SEGMENT_USER_ROLE: {
            // order by Role
            self.users = [self.users sortedArrayUsingSelector:@selector(compareByRole:)];
            break;
        }
        case SEGMENT_LAST_CONNECTION_DATE: {
            // order by Last connection date
            self.users = [self.users sortedArrayUsingSelector:@selector(compareByLastConnectionDate:)];
            break;
            
        }
        default: {
            NSLog(@"%s:Error, unknown selected segment", __PRETTY_FUNCTION__);
            break;
        }
    }
    [self.theTable reloadData];
    
    if (self.users > 0) {
        [self.theTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:TRUE];
    }
  
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"userListCellId";
    UserListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == Nil) {
        cell = [[UserListViewCell alloc] init];
    }

    [cell initializeWithUser:self.users[indexPath.row]];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"displayAndModifyUser" sender:self];

}

// To be analysed!!!!
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.theTable setEditing:editing animated:YES];
    
    
}

// Method called when the "Edit" button is pressed to delete or move a row from the table

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        UserDescription* userToBeDeleted = (UserDescription*) self.users[indexPath.row];
        if ([userToBeDeleted.name isEqualToString:@"admin"]) {
            UIAlertController* alert = [Utility getSimpleAlertView:@"Error"
                                                           message:@"admin user cannot be deleted."
                                                       actionTitle:@"OK"];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
      
        
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = [NSString stringWithFormat:@"Delete User %@", userToBeDeleted.name];
        
        [RequestUtilities deleteUser:userToBeDeleted.name delegate:self clientId:@"deleteUser"];

        self.deletedUserIndex = indexPath;
        
    }
}


#pragma mark - HTMLResponse

- (void) dataReady: (id) theData clientId:(NSString *)theClientId {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
   
    if ([theClientId isEqualToString:@"getUsers"]) {
        NSArray* data = theData;
        
        NSMutableArray* newUsers = [[NSMutableArray alloc] initWithCapacity:data.count];
        
        for (NSDictionary* currentUser in data) {
            [newUsers addObject:[[UserDescription alloc]initWithDictionary:currentUser]];
        }
        
        self.users = newUsers;
        
        [self reorderAndDisplayUserList:self.theSegmentedControl.selectedSegmentIndex];
    } else if ([theClientId isEqualToString:@"deleteUser"]) {
        [self userDeleted];
        
     } else {
        NSLog(@"UserListViewController: unknown clientId");
    }
}

- (void) userDeleted {
    NSMutableArray* newUserList = [[NSMutableArray alloc] initWithArray:self.users];
    
    [newUserList removeObjectAtIndex:self.deletedUserIndex.row];
    self.users = newUserList;
    
    [self.theTable beginUpdates];
    [self.theTable deleteRowsAtIndexPaths:@[self.deletedUserIndex] withRowAnimation:UITableViewRowAnimationFade];
    [self.theTable endUpdates];
}


//  ----------- Cannot retreive the KPI dictionaries from the server ----------
- (void) connectionFailure:(NSString*) theClientId {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    UIAlertController* alert = Nil;
    if ([theClientId isEqualToString:@"getUsers"]) {
        alert = [Utility getSimpleAlertView:@"Connection Failure"
                                    message:@"Cannot get users."
                                actionTitle:@"OK"];
        [self presentViewController:alert animated:YES completion:nil];
    } else if ([theClientId isEqualToString:@"deleteUser"]) {
        alert = [Utility getSimpleAlertView:@"Error"
                                    message:@"Cannot delete the user."
                                actionTitle:@"OK"];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        alert = [Utility getSimpleAlertView:@"Failure"
                                    message:@"Unknown error."
                                actionTitle:@"OK"];
    }

    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"openCreateUserId"]) {
        CreateUserViewController* controller = segue.destinationViewController;
        controller.delegateUserList = self;
    } else if ([segue.identifier isEqualToString:@"displayAndModifyUser"]) {
        NSIndexPath* indexPath = [self.theTable indexPathForSelectedRow];
        
        UserDescription* theSelectedUser = self.users[indexPath.row];
        
        DisplayAndModifyUserViewController* controller = segue.destinationViewController;
        [controller initializeWithUser:theSelectedUser delegate:self];
    }
}

- (void) updateUserList {
    [self loadUsers];
}

@end
