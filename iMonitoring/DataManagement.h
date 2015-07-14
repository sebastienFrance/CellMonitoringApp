//
//  DataManagement.h
//  iMonitoring
//
//  Created by sébastien brugalières on 10/03/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DataManagement : NSObject

@property (nonatomic, strong) UIManagedDocument* managedDocument;

+(DataManagement*)sharedInstance;

- (void) initializeIt;

- (void) remove:(NSManagedObject*) object;
- (void) save;
@end
