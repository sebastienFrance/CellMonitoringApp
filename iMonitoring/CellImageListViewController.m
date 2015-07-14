//
//  CellImageListViewController.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 22/02/2015.
//
//

#import "CellImageListViewController.h"
#import "RequestUtilities.h"
#import "CellMonitoring.h"
#import "MBProgressHUD.h"
#import "Utility.h"
#import "SiteImageListTableViewCell.h"
#import "SiteImageDetailsViewController.h"
#import "DataCenter.h"

@interface CellImageListViewController ()
@property (weak, nonatomic) IBOutlet UITableView *theTableView;
@property (nonatomic) NSMutableArray* imageList;
@property (nonatomic) CellMonitoring* cell;
@property (nonatomic) NSMutableDictionary *images;

@property (nonatomic) NSIndexPath* deletedImageIndex;
@end

@implementation CellImageListViewController

-(void) initializeWithCell:(CellMonitoring *)theCell {
    self.cell = theCell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.theTableView.dataSource = self;
    self.theTableView.delegate = self;
    
    [self.theTableView setEditing:NO];
    
    self.title = self.cell.id;
    
    
    [RequestUtilities getSiteImageList:self.cell.siteId delegate:self clientId:@"getImageList"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - HTMLDataResponse
- (void) dataReady:(id) theData clientId:(NSString*) theClientId {
    
    if ([theClientId isEqualToString:@"deleteImage"]) {
        NSDictionary* data = theData;
        [self deletedImage:data];
    } else if ([theClientId isEqualToString:@"getImageList"]) {
        
        
        NSDictionary* theImagesData = theData;
        self.imageList = [CellImageListViewController imageListDownloaded:theImagesData];

        // download all thumbails
        self.images = [[NSMutableDictionary alloc] init];
        for (NSString* imageName in self.imageList) {
            [RequestUtilities getSiteImage:self.cell.siteId imageName:imageName quality:LowRes delegate:self clientId:imageName];
        }
    } else {
        NSDictionary* theImageData = theData;
        NSArray* theImageString = theImageData[@"image"];
        self.images[theClientId] = [Utility imageFromJSONByteString:theImageString];
        [self.theTableView reloadData];
    }
}

+(NSMutableArray*) imageListDownloaded:(NSDictionary*) theImagesData {
    NSMutableArray* theImageList = [[NSMutableArray alloc] initWithArray:theImagesData[@"images"]];
    [theImageList sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 integerValue]==[obj2 integerValue])
            return NSOrderedSame;
        
        else if ([obj1 integerValue]<[obj2 integerValue])
            return NSOrderedDescending;
        else
            return NSOrderedAscending;
    }];
    
    return theImageList;
}

-(void) deletedImage:(NSDictionary*) data {
    [MBProgressHUD hideAllHUDsForView:self.view animated:TRUE];
    
    [self.images removeObjectForKey:self.imageList[self.deletedImageIndex.row]];
    [self.imageList removeObjectAtIndex:self.deletedImageIndex.row];
    
    [self.theTableView beginUpdates];
    [self.theTableView deleteRowsAtIndexPaths:@[self.deletedImageIndex] withRowAnimation:UITableViewRowAnimationFade];
    [self.theTableView endUpdates];
}

- (void) connectionFailure:(NSString*) theClientId {
    if ([theClientId isEqualToString:@"deleteImage"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Communication error" message:@"Cannot delete image from server" delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    } else if ([theClientId isEqualToString:@"getImageList"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Communication error" message:@"Cannot get image list from server" delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    } else {
         NSLog(@"%s: Error loading image %@", __PRETTY_FUNCTION__, theClientId);
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.imageList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"imageSiteListId";
    SiteImageListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == Nil) {
        cell = [[SiteImageListTableViewCell alloc] init];
    }
    
    NSString* imageName = self.imageList[indexPath.row];

    [cell initializeWithImage:self.images[imageName] dateAndTime:[NSDate dateWithTimeIntervalSince1970:([imageName integerValue] / 1000)]];
    
    
    return cell;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([DataCenter sharedInstance].isAdminUser == TRUE) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = [NSString stringWithFormat:@"Delete Image"];
        
        [RequestUtilities deleteSiteImage:self.cell.siteId imageName:self.imageList[indexPath.row] delegate:self clientId:@"deleteImage"];
        
        self.deletedImageIndex = indexPath;
        
    }
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"pushImageDetails"]) {
       SiteImageDetailsViewController* controller = segue.destinationViewController;
        
        NSString* imageName = self.imageList[[self.theTableView indexPathForSelectedRow].row];
        
        [controller initializeWithImageName:imageName cell:self.cell];
    }
}



@end
