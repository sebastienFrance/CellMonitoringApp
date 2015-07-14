//
//  CellBookmark.h
//  iMonitoring
//
//  Created by sébastien brugalières on 15/03/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CellBookmark : NSManagedObject

@property (nonatomic, retain) NSString * cellInternalName;
@property (nonatomic, retain) id color;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * techno;

@end
