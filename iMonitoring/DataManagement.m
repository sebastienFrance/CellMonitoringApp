//
//  DataManagement.m
//  iMonitoring
//
//  Created by sébastien brugalières on 10/03/13.
//
//

#import "DataManagement.h"
#import <CoreData/CoreData.h>

@interface DataManagement() <UIAlertViewDelegate>

@property (nonatomic) NSURL* iCloudURL;
@property (nonatomic) NSURL* documentsURL;
@property (nonatomic) NSURL* documentMetadataURL;
@property (nonatomic) NSURL* appURL;
@property (nonatomic) NSURL* logsURL;
@property (nonatomic) Boolean iCloudUsed;

@end

@implementation DataManagement

NSString *const kiCloudToken            = @"SebCompany.iMonitoring.UbiquityIdentityToken";
NSString *const kFirstLaunchWithiCloud  = @"iCloud.firstLaunchWithiCloud";
NSString *const kuseiCloud              = @"iCloud.useiCloud";

#pragma mark - Singleton

+(DataManagement*)sharedInstance
{
    static dispatch_once_t pred;
    static DataManagement *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[DataManagement alloc] init];
    });
    return sharedInstance;
}

- (id)init{
    if (self = [super init] ) {
    }
    
    return self;
}

- (void) dealloc {
    if (_iCloudUsed) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:_managedDocument.managedObjectContext.persistentStoreCoordinator];
    }
    // implement -dealloc & remove abort() when refactoring for
    // non-singleton use.
    abort();
}

#pragma mark - Database init


- (void) initializeIt {
    
    [self initializationWithLocalStore];
    
}

//- (void) initializeWithiCloud {
//    
//    id currentiCloudToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
//    
//    if (currentiCloudToken) {
//        NSLog(@"%s iCloud is available", __PRETTY_FUNCTION__);
//        NSData *newTokenData = [NSKeyedArchiver archivedDataWithRootObject: currentiCloudToken];
//        [[NSUserDefaults standardUserDefaults] setObject: newTokenData forKey:kiCloudToken];
//    } else {
//        NSLog(@"%s Warning, iCloud is not available", __PRETTY_FUNCTION__);
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kiCloudToken];
//    }
//    
//    
//    [[NSNotificationCenter defaultCenter] addObserver: self
//                                             selector: @selector(iCloudAccountAvailabilityChanged:)
//                                                 name: NSUbiquityIdentityDidChangeNotification
//                                               object: nil];
//    
//    // If iCloud activated then check if user wants to use it!
//    if (currentiCloudToken) {
//        
//        // Check if user has already selected iCloud previously
//        Boolean firstLaunchWithiCloud;
//        if ([[NSUserDefaults standardUserDefaults] objectForKey:kFirstLaunchWithiCloud] != Nil) {
//            firstLaunchWithiCloud = FALSE;
//        } else {
//            firstLaunchWithiCloud = TRUE;
//            [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:kFirstLaunchWithiCloud];
//        }
//        
//        // If first start with iCloud then request what user wants to do
//        if (firstLaunchWithiCloud) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Choose Storage Option"
//                                                            message: @"Should documents be stored in iCloud and available on all your devices?"
//                                                           delegate: self
//                                                  cancelButtonTitle: @"Local Only"
//                                                  otherButtonTitles: @"Use iCloud", nil];
//            [alert show];
//        } else {
//            
//            // Not the first time user start with iCould, so check what was user choice
//            
//            self.iCloudUsed = [[NSUserDefaults standardUserDefaults] boolForKey:kuseiCloud];
//            if (self.iCloudUsed) {
//                [self initializationWithiCloud];
//            } else {
//                [self initializationWithLocalStore];
//            }
//        }
//    } else {
//        // iCloud not available so start with our local store
//        [self initializationWithLocalStore];
//    }
//}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    self.iCloudUsed = FALSE;
   if (buttonIndex != 0) {
        [self initializationWithiCloud];
   } else {
       [self initializationWithLocalStore];
   }
}

- (void) initializationWithLocalStore {
    self.iCloudUsed = FALSE;
    [[NSUserDefaults standardUserDefaults] setBool:self.iCloudUsed forKey:kuseiCloud];
    [self localStoreInitializeURLs];
    [self initializeManagedDocument];
}


- (void) initializationWithiCloud {
    NSLog(@"%s use iCloud", __PRETTY_FUNCTION__);
    self.iCloudUsed = TRUE;
    [[NSUserDefaults standardUserDefaults] setBool:self.iCloudUsed forKey:kuseiCloud];

    
    dispatch_async (dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        
        self.iCloudURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:Nil];
        if (self.iCloudURL != Nil) {
            NSLog(@"%s iCloud is ready! ", __PRETTY_FUNCTION__);
            [self iCloudInitializeURLs];

            dispatch_async (dispatch_get_main_queue (), ^(void) {
                // On the main thread, update UI and state as appropriate
                [self initializeManagedDocument];
            });
        } else {
            NSLog(@"%s Warning ICloud URL is Nil, initialize with a localStore", __PRETTY_FUNCTION__);
            dispatch_async (dispatch_get_main_queue (), ^(void) {
                // On the main thread, update UI and state as appropriate
                [self initializationWithLocalStore];
            });
        }
        
        
    });
}

// This method is common for iCloud and non iCloud
- (void) initializeManagedDocument {
    NSLog(@"%s iCloudURL: %@", __PRETTY_FUNCTION__, self.iCloudURL);
    NSLog(@"%s documentsURL: %@", __PRETTY_FUNCTION__, self.documentsURL);
    NSLog(@"%s documentMetadataURL: %@", __PRETTY_FUNCTION__, self.documentMetadataURL);
    NSLog(@"%s appURL: %@", __PRETTY_FUNCTION__, self.appURL);
    NSLog(@"%s logsURL: %@", __PRETTY_FUNCTION__, self.logsURL);

    _managedDocument = [[UIManagedDocument alloc] initWithFileURL:self.appURL];
    
    if (self.iCloudUsed == TRUE) {
        [self iCloudPersistentStoreOptionsInDocument];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(documentChanged:)
                                                     name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                                                   object:_managedDocument.managedObjectContext.persistentStoreCoordinator];
    } else {
        [self persistentStoreOptionsInDocument];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.appURL path]]) {
        [_managedDocument saveToURL:self.appURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
            if (!success) {
                NSLog(@"Cannot create db successfully");
            } else {
                NSLog(@"%s: saveForCreating has succeeded", __PRETTY_FUNCTION__);
            }
        }];
    }
    else if (_managedDocument.documentState == UIDocumentStateClosed) {
        [_managedDocument openWithCompletionHandler:^(BOOL success)  {
            if (!success) {
                NSLog(@"Cannot open db successfully");
            } else {
                NSLog(@"%s: openWithCompletionHandler has succeeded", __PRETTY_FUNCTION__);
            }
            
        }];
    } else if (_managedDocument.documentState == UIDocumentStateNormal) {
        NSLog(@"%s: ManagedDocument is in Normal state", __PRETTY_FUNCTION__);
    }
}

#pragma mark - URLs initializations
- (void) iCloudInitializeURLs {
    
    // Information !!!
    // $iCloudURL/Documents directory is automatically created when calling URLForUbiquityContainerIdentifier
    // $iCloudURL/Documents is public directory and so visible in iCloud Preferences others directory at
    // $iCloudURL are private
    
    
    // documentsURL: $iCloudURL/Documents
    self.documentsURL = [self.iCloudURL URLByAppendingPathComponent:@"Documents"];
    
    // DocumentMetadataURL: $iCloudURL/DocumentMetadata.plist
    self.documentMetadataURL = [self.documentsURL URLByAppendingPathComponent:@"DocumentMetadata.plist"];
    
    // appURL: $iCloudURL/Documents/iMonitoring
    self.appURL = [self.documentsURL URLByAppendingPathComponent:@"iMonitoring"];
    
    // logsURL: $iCloudURL/CoreData => Warning it should be a directory!
    self.logsURL = [self.iCloudURL URLByAppendingPathComponent:@"iMonitoringLogs"];
    self.logsURL = [self.logsURL URLByAppendingPathComponent:@"CoreData"];
    
}

- (void) localStoreInitializeURLs {
    self.iCloudURL = Nil;
    self.documentMetadataURL = Nil;
    self.logsURL = Nil;

    self.documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    self.appURL = [self.documentsURL URLByAppendingPathComponent:@"iMonitoring"];
}

#pragma mark - PersistentStore options
- (void) persistentStoreOptionsInDocument {
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@YES,
                              NSInferMappingModelAutomaticallyOption:@YES};
    self.managedDocument.persistentStoreOptions = options;
}


- (void) iCloudPersistentStoreOptionsInDocument {
#warning SEB:should use document.fileURL/@"DocumentMedata.plist" from the cloud to fill ContentNameKey value. Should use NSDictionary with URL to read the plist
    
    NSDictionary* documentMedata = [[NSDictionary alloc] initWithContentsOfURL:self.documentMetadataURL];
    if (documentMedata != nil) {
        NSLog(@"%s document metadata %@", __PRETTY_FUNCTION__, documentMedata);
    } else {
        NSLog(@"%s cannot find document metadata", __PRETTY_FUNCTION__);
    }
    
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
                             NSInferMappingModelAutomaticallyOption: @YES,
                             NSPersistentStoreUbiquitousContentNameKey: @"iMonitoring", // Name of the document in the Cloud
                             NSPersistentStoreUbiquitousContentURLKey: self.logsURL}; // Key to log all Changes
    self.managedDocument.persistentStoreOptions = options;
    
}

#pragma mark - iCloud Notifications
- (void) iCloudAccountAvailabilityChanged:(NSNotification*) notification {
    NSLog(@"%s iCould account availability has changed!", __PRETTY_FUNCTION__);
}

- (void) documentChanged:(NSNotification *) notification {
    NSLog(@"%s: documentChanged %@", __PRETTY_FUNCTION__, notification);
    NSLog(@"%s: object %@", __PRETTY_FUNCTION__, notification.object);
    NSLog(@"%s: user info %@", __PRETTY_FUNCTION__, notification.userInfo);
    
     [self.managedDocument.managedObjectContext performBlock:^{
         [_managedDocument.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
     }];
}

#pragma mark - Delete /Save objects in DB

- (void) remove:(NSManagedObject*) object {
    
    if (self.managedDocument.documentState == UIDocumentStateNormal) {
        
        [self.managedDocument.managedObjectContext deleteObject:object];
        [self save];
    } else {
        [self dumpDocumentState];
    }
}

- (void) save {
    [self.managedDocument saveToURL:self.managedDocument.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        if (!success) {
            NSLog(@"%s: Error cannot save object in db", __PRETTY_FUNCTION__);
            [self dumpDocumentState];
        }
    }];
}

- (void) dumpDocumentState {
    if (self.managedDocument.documentState == UIDocumentStateClosed) {
        NSLog(@"%s document is closed", __PRETTY_FUNCTION__);
    } else if (self.managedDocument.documentState == UIDocumentStateEditingDisabled) {
        NSLog(@"%s document is editing disabled", __PRETTY_FUNCTION__);
    } else if (self.managedDocument.documentState == UIDocumentStateInConflict) {
        NSLog(@"%s document is in conflict", __PRETTY_FUNCTION__);
    } else if (self.managedDocument.documentState == UIDocumentStateSavingError) {
        NSLog(@"%s document is saving error", __PRETTY_FUNCTION__);
    } else if (self.managedDocument.documentState == UIDocumentStateNormal) {
        NSLog(@"%s document is normal", __PRETTY_FUNCTION__);
    } else {
        NSLog(@"%s unknown document state", __PRETTY_FUNCTION__);
    }    
}



@end
